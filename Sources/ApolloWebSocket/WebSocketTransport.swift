#if !COCOAPODS
import Apollo
import ApolloCore
#endif
import Starscream
import Foundation

// MARK: - Transport Delegate

public protocol WebSocketTransportDelegate: class {
  func webSocketTransportDidConnect(_ webSocketTransport: WebSocketTransport)
  func webSocketTransportDidReconnect(_ webSocketTransport: WebSocketTransport)
  func webSocketTransport(_ webSocketTransport: WebSocketTransport, didDisconnectWithError error:Error?)
}

public extension WebSocketTransportDelegate {
  func webSocketTransportDidConnect(_ webSocketTransport: WebSocketTransport) {}
  func webSocketTransportDidReconnect(_ webSocketTransport: WebSocketTransport) {}
  func webSocketTransport(_ webSocketTransport: WebSocketTransport, didDisconnectWithError error:Error?) {}
}

// MARK: - WebSocketTransport

/// A network transport that uses web sockets requests to send GraphQL subscription operations to a server, and that uses the Starscream implementation of web sockets.
public class WebSocketTransport {
  public static var provider: ApolloWebSocketClient.Type = ApolloWebSocket.self
  public weak var delegate: WebSocketTransportDelegate?

  let connectOnInit: Bool
  let reconnect: Atomic<Bool>
  var websocket: ApolloWebSocketClient
  let error: Atomic<Error?> = Atomic(nil)
  let serializationFormat = JSONSerializationFormat.self
  private let requestBodyCreator: RequestBodyCreator

  private final let protocols = ["graphql-ws"]

  private var acked = false

  private var queue: [Int: String] = [:]
  private var connectingPayload: GraphQLMap?

  private var subscribers = [String: (Result<JSONObject, Error>) -> Void]()
  private var subscriptions : [String: String] = [:]
  private let processingQueue = DispatchQueue(label: "com.apollographql.WebSocketTransport")

  private let sendOperationIdentifiers: Bool
  private let reconnectionInterval: TimeInterval
  private let allowSendingDuplicates: Bool
  fileprivate let sequenceNumberCounter = Atomic<Int>(0)
  fileprivate var reconnected = false

  /// NOTE: Setting this won't override immediately if the socket is still connected, only on reconnection.
  public var clientName: String {
    didSet {
      self.addApolloClientHeaders(to: &self.websocket.request)
    }
  }

  /// NOTE: Setting this won't override immediately if the socket is still connected, only on reconnection.
  public var clientVersion: String {
    didSet {
      self.addApolloClientHeaders(to: &self.websocket.request)
    }
  }

  public var security: SSLTrustValidator? {
    get {
      return websocket.security
    }
    set {
      websocket.security = newValue
    }
  }

  /// Determines whether a SOCKS proxy is enabled on the underlying request.
  /// Mostly useful for debugging with tools like Charles Proxy.
  /// Note: Will return `false` from the getter and no-op the setter for implementations that do not conform to `SOCKSProxyable`.
  public var enableSOCKSProxy: Bool {
    get {
      guard let socket = self.websocket as? SOCKSProxyable else {
        // If it's not proxyable, then the proxy can't be enabled
        return false
      }
      
      return socket.enableSOCKSProxy
    }
    set {
      guard var socket = self.websocket as? SOCKSProxyable else {
        // If it's not proxyable, there's nothing to do here.
        return
      }
      
      socket.enableSOCKSProxy = newValue
    }
  }

  /// Designated initializer
  ///
  /// - Parameter request: The connection URLRequest
  /// - Parameter clientName: The client name to use for this client. Defaults to `Self.defaultClientName`
  /// - Parameter clientVersion: The client version to use for this client. Defaults to `Self.defaultClientVersion`.
  /// - Parameter sendOperationIdentifiers: Whether or not to send operation identifiers with operations. Defaults to false.
  /// - Parameter reconnect: Whether to auto reconnect when websocket looses connection. Defaults to true.
  /// - Parameter reconnectionInterval: How long to wait before attempting to reconnect. Defaults to half a second.
  /// - Parameter allowSendingDuplicates: Allow sending duplicate messages. Important when reconnected. Defaults to true.
  /// - Parameter connectOnInit: Whether the websocket connects immediately on creation. If false, remember to call `resumeWebSocketConnection()` to connect. Defaults to true.
  /// - Parameter connectingPayload: [optional] The payload to send on connection. Defaults to an empty `GraphQLMap`.
  /// - Parameter requestBodyCreator: The `RequestBodyCreator` to use when serializing requests. Defaults to an `ApolloRequestBodyCreator`.
  public init(request: URLRequest,
              clientName: String = WebSocketTransport.defaultClientName,
              clientVersion: String = WebSocketTransport.defaultClientVersion,
              sendOperationIdentifiers: Bool = false,
              reconnect: Bool = true,
              reconnectionInterval: TimeInterval = 0.5,
              allowSendingDuplicates: Bool = true,
              connectOnInit: Bool = true,
              connectingPayload: GraphQLMap? = [:],
              requestBodyCreator: RequestBodyCreator = ApolloRequestBodyCreator()) {
    self.connectingPayload = connectingPayload
    self.sendOperationIdentifiers = sendOperationIdentifiers
    self.reconnect = Atomic(reconnect)
    self.reconnectionInterval = reconnectionInterval
    self.allowSendingDuplicates = allowSendingDuplicates
    self.requestBodyCreator = requestBodyCreator
    self.websocket = WebSocketTransport.provider.init(request: request, protocols: protocols)
    self.clientName = clientName
    self.clientVersion = clientVersion
    self.connectOnInit = connectOnInit
    self.addApolloClientHeaders(to: &self.websocket.request)
    self.websocket.delegate = self
    if connectOnInit {
      self.websocket.connect()
    }
    self.websocket.callbackQueue = processingQueue
  }

  public func isConnected() -> Bool {
    return websocket.isConnected
  }

  public func ping(data: Data, completionHandler: (() -> Void)? = nil) {
    return websocket.write(ping: data, completion: completionHandler)
  }

  private func processMessage(socket: WebSocketClient, text: String) {
    OperationMessage(serialized: text).parse { parseHandler in
      guard
        let type = parseHandler.type,
        let messageType = OperationMessage.Types(rawValue: type) else {
          self.notifyErrorAllHandlers(WebSocketError(payload: parseHandler.payload,
                                                     error: parseHandler.error,
                                                     kind: .unprocessedMessage(text)))
          return
      }

      switch messageType {
      case .data,
           .error:
        if
          let id = parseHandler.id,
          let responseHandler = subscribers[id] {
          if let payload = parseHandler.payload {
            responseHandler(.success(payload))
          } else if let error = parseHandler.error {
            responseHandler(.failure(error))
          } else {
            let websocketError = WebSocketError(payload: parseHandler.payload,
                                                error: parseHandler.error,
                                                kind: .neitherErrorNorPayloadReceived)
            responseHandler(.failure(websocketError))
          }
        } else {
          let websocketError = WebSocketError(payload: parseHandler.payload,
                                              error: parseHandler.error,
                                              kind: .unprocessedMessage(text))
          self.notifyErrorAllHandlers(websocketError)
        }
      case .complete:
        if let id = parseHandler.id {
          // remove the callback if NOT a subscription
          if subscriptions[id] == nil {
            subscribers.removeValue(forKey: id)
          }
        } else {
          notifyErrorAllHandlers(WebSocketError(payload: parseHandler.payload,
                                                error: parseHandler.error,
                                                kind: .unprocessedMessage(text)))
        }

      case .connectionAck:
        acked = true
        writeQueue()

      case .connectionKeepAlive:
        writeQueue()

      case .connectionInit,
           .connectionTerminate,
           .start,
           .stop,
           .connectionError:
        notifyErrorAllHandlers(WebSocketError(payload: parseHandler.payload,
                                              error: parseHandler.error,
                                              kind: .unprocessedMessage(text)))
      }
    }
  }

  private func notifyErrorAllHandlers(_ error: Error) {
    for (_, handler) in subscribers {
      handler(.failure(error))
    }
  }

  private func writeQueue() {
    guard !self.queue.isEmpty else {
      return
    }

    let queue = self.queue.sorted(by: { $0.0 < $1.0 })
    self.queue.removeAll()
    for (id, msg) in queue {
      self.write(msg, id: id)
    }
  }

  private func processMessage(socket: WebSocketClient, data: Data) {
    print("WebSocketTransport::unprocessed event \(data)")
  }

  public func initServer() {
    self.acked = false

    if let str = OperationMessage(payload: self.connectingPayload, type: .connectionInit).rawMessage {
      write(str, force:true)
    }

  }

  public func closeConnection() {
    self.reconnect.value = false

    let str = OperationMessage(type: .connectionTerminate).rawMessage
    processingQueue.async {
      if let str = str {
        self.write(str)
      }

      self.queue.removeAll()
      self.subscriptions.removeAll()
    }
  }

  private func write(_ str: String,
                     force forced: Bool = false,
                     id: Int? = nil) {
    if websocket.isConnected && (acked || forced) {
      websocket.write(string: str)
    } else {
      // using sequence number to make sure that the queue is processed correctly
      // either using the earlier assigned id or with the next higher key
      if let id = id {
        queue[id] = str
      } else if let id = queue.keys.max() {
        queue[id+1] = str
      } else {
        queue[1] = str
      }
    }
  }

  deinit {
    websocket.disconnect()
    websocket.delegate = nil
  }

  func sendHelper<Operation: GraphQLOperation>(operation: Operation, resultHandler: @escaping (_ result: Result<JSONObject, Error>) -> Void) -> String? {
    let body = requestBodyCreator.requestBody(for: operation,
                                              sendOperationIdentifiers: self.sendOperationIdentifiers,
                                              sendQueryDocument: true,
                                              autoPersistQuery: false)
    let sequenceNumber = "\(sequenceNumberCounter.increment())"

    guard let message = OperationMessage(payload: body, id: sequenceNumber).rawMessage else {
      return nil
    }

    processingQueue.async {
      self.write(message)

      self.subscribers[sequenceNumber] = resultHandler
      if operation.operationType == .subscription {
        self.subscriptions[sequenceNumber] = message
      }
    }

    return sequenceNumber
  }

  public func unsubscribe(_ subscriptionId: String) {
    let str = OperationMessage(id: subscriptionId, type: .stop).rawMessage

    processingQueue.async {
      if let str = str {
        self.write(str)
      }
      self.subscribers.removeValue(forKey: subscriptionId)
      self.subscriptions.removeValue(forKey: subscriptionId)
    }
  }

  public func updateHeaderValues(_ values: [String: String?]) {
    for (key, value) in values {
      self.websocket.request.setValue(value, forHTTPHeaderField: key)
    }

    self.reconnectWebSocket()
  }

  public func updateConnectingPayload(_ payload: GraphQLMap) {
    self.connectingPayload = payload
    self.reconnectWebSocket()
  }

  private func reconnectWebSocket() {
    let oldReconnectValue = reconnect.value
    self.reconnect.value = false

    self.websocket.disconnect()
    self.websocket.connect()

    reconnect.value = oldReconnectValue
  }
  
  /// Disconnects the websocket while setting the auto-reconnect value to false,
  /// allowing purposeful disconnects that do not dump existing subscriptions.
  /// NOTE: You will receive an error on the subscription (should be a `Starscream.WSError` with code 1000) when the socket disconnects.
  /// ALSO NOTE: To reconnect after calling this, you will need to call `resumeWebSocketConnection`.
  public func pauseWebSocketConnection() {
    self.reconnect.value = false
    self.websocket.disconnect()
  }
  
  /// Reconnects a paused web socket.
  ///
  /// - Parameter autoReconnect: `true` if you want the websocket to automatically reconnect if the connection drops. Defaults to true.
  public func resumeWebSocketConnection(autoReconnect: Bool = true) {
    self.reconnect.value = autoReconnect
    self.websocket.connect()
  }
}

// MARK: - NetworkTransport conformance

extension WebSocketTransport: NetworkTransport {
  public func send<Operation: GraphQLOperation>(
    operation: Operation,
    cachePolicy: CachePolicy,
    contextIdentifier: UUID? = nil,
    callbackQueue: DispatchQueue = .main,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable {
    
    func callCompletion(with result: Result<GraphQLResult<Operation.Data>, Error>) {
      callbackQueue.async {
        completionHandler(result)
      }
    }
    
    if let error = self.error.value {
      callCompletion(with: .failure(error))
      return EmptyCancellable()
    }

    return WebSocketTask(self, operation) { result in
      switch result {
      case .success(let jsonBody):
        let response = GraphQLResponse(operation: operation, body: jsonBody)
        do {
          let graphQLResult = try response.parseResultFast()
          callCompletion(with: .success(graphQLResult))
        } catch {
          callCompletion(with: .failure(error))
        }
      case .failure(let error):
        callCompletion(with: .failure(error))
      }
    }
  }
}

// MARK: - WebSocketDelegate implementation

extension WebSocketTransport: WebSocketDelegate {

  public func websocketDidConnect(socket: WebSocketClient) {
    self.error.value = nil
    initServer()
    if reconnected {
      self.delegate?.webSocketTransportDidReconnect(self)
      // re-send the subscriptions whenever we are re-connected
      // for the first connect, any subscriptions are already in queue
      for (_,msg) in self.subscriptions {
        if allowSendingDuplicates {
          write(msg)
        } else {
          // search duplicate message from the queue
          let id = queue.first { $0.value == msg }?.key
          write(msg, id: id)
        }
      }
    } else {
      self.delegate?.webSocketTransportDidConnect(self)
    }

    reconnected = true
  }

  public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    // report any error to all subscribers
    if let error = error {
      self.error.value = WebSocketError(payload: nil, error: error, kind: .networkError)
      self.notifyErrorAllHandlers(error)
    } else {
      self.error.value = nil
    }

    self.delegate?.webSocketTransport(self, didDisconnectWithError: self.error.value)
    acked = false // need new connect and ack before sending

    if reconnect.value {
      DispatchQueue.main.asyncAfter(deadline: .now() + reconnectionInterval) {
        self.websocket.connect()
      }
    }
  }

  public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    processMessage(socket: socket, text: text)
  }

  public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    processMessage(socket: socket, data: data)
  }
}

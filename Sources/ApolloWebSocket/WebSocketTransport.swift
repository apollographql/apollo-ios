#if !COCOAPODS
import Apollo
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

  let reconnect: Atomic<Bool>
  var websocket: ApolloWebSocketClient
  let error: Atomic<Error?> = Atomic(nil)
  let serializationFormat = JSONSerializationFormat.self
  private let requestCreator: RequestCreator

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

  /// Designated initializer
  ///
  /// - Parameter request: The connection URLRequest
  /// - Parameter clientName: The client name to use for this client. Defaults to `Self.defaultClientName`
  /// - Parameter clientVersion: The client version to use for this client. Defaults to `Self.defaultClientVersion`.
  /// - Parameter sendOperationIdentifiers: Whether or not to send operation identifiers with operations. Defaults to false.
  /// - Paremeter reconnect: Wether to auto reconnect when websocket looses connection. Defaults to true.
  /// - Parameter reconnectionInterval: How long to wait before attempting to reconnect. Defaults to half a second.
  /// - Parameter allowSendingDuplicates: Allow sending duplicate messages. Important when reconnected. Defaults to true.
  /// - Parameter connectingPayload: [optional] The payload to send on connection. Defaults to an empty `GraphQLMap`.
  /// - Parameter requestCreator: The request creator to use when serializing requests. Defaults to an `ApolloRequestCreator`.
  public init(request: URLRequest,
              clientName: String = WebSocketTransport.defaultClientName,
              clientVersion: String = WebSocketTransport.defaultClientVersion,
              sendOperationIdentifiers: Bool = false,
              reconnect: Bool = true,
              reconnectionInterval: TimeInterval = 0.5,
              allowSendingDuplicates: Bool = true,
              connectingPayload: GraphQLMap? = [:],
              requestCreator: RequestCreator = ApolloRequestCreator()) {
    self.connectingPayload = connectingPayload
    self.sendOperationIdentifiers = sendOperationIdentifiers
    self.reconnect = Atomic(reconnect)
    self.reconnectionInterval = reconnectionInterval
    self.allowSendingDuplicates = allowSendingDuplicates
    self.requestCreator = requestCreator
    self.websocket = WebSocketTransport.provider.init(request: request, protocols: protocols)
    self.clientName = clientName
    self.clientVersion = clientVersion
    self.addApolloClientHeaders(to: &self.websocket.request)
    self.websocket.delegate = self
    self.websocket.connect()
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
    let body = requestCreator.requestBody(for: operation, sendOperationIdentifiers: self.sendOperationIdentifiers)
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
}

// MARK: - HTTPNetworkTransport conformance

extension WebSocketTransport: NetworkTransport {
  public func send<Operation>(operation: Operation, completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>,Error>) -> Void) -> Cancellable {
    if let error = self.error.value {
      completionHandler(.failure(error))
      return EmptyCancellable()
    }

    return WebSocketTask(self, operation) { result in
      switch result {
      case .success(let jsonBody):
        let response = GraphQLResponse(operation: operation, body: jsonBody)
        completionHandler(.success(response))
      case .failure(let error):
        completionHandler(.failure(error))
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

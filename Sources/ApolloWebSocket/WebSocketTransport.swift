#if !COCOAPODS
import Apollo
import ApolloUtils
#endif
import Foundation

// MARK: - Transport Delegate

public protocol WebSocketTransportDelegate: AnyObject {
  func webSocketTransportDidConnect(_ webSocketTransport: WebSocketTransport)
  func webSocketTransportDidReconnect(_ webSocketTransport: WebSocketTransport)
  func webSocketTransport(_ webSocketTransport: WebSocketTransport, didDisconnectWithError error:Error?)
}

public extension WebSocketTransportDelegate {
  func webSocketTransportDidConnect(_ webSocketTransport: WebSocketTransport) {}
  func webSocketTransportDidReconnect(_ webSocketTransport: WebSocketTransport) {}
  func webSocketTransport(_ webSocketTransport: WebSocketTransport, didDisconnectWithError error:Error?) {}
  func webSocketTransport(_ webSocketTransport: WebSocketTransport, didReceivePingData: Data?) {}
  func webSocketTransport(_ webSocketTransport: WebSocketTransport, didReceivePongData: Data?) {}
}

// MARK: - WebSocketTransport

/// A network transport that uses web sockets requests to send GraphQL subscription operations to a server.
public class WebSocketTransport {
  public weak var delegate: WebSocketTransportDelegate?

  let connectOnInit: Bool
  let reconnect: Atomic<Bool>
  let websocket: WebSocketClient
  let store: ApolloStore?
  let error: Atomic<Error?> = Atomic(nil)
  let serializationFormat = JSONSerializationFormat.self
  private let requestBodyCreator: RequestBodyCreator
  private let operationMessageIdCreator: OperationMessageIdCreator

  /// non-private for testing - you should not use this directly
  enum SocketConnectionState {
    case disconnected
    case connected
    case failed
    
    var isConnected: Bool {
      self == .connected
    }
  }
  var socketConnectionState = Atomic<SocketConnectionState>(.disconnected)

  /// Indicates if the websocket connection has been acknowledged by the server.
  private var acked = false

  private var queue: [Int: String] = [:]
  private var connectingPayload: GraphQLMap?

  private var subscribers = [String: (Result<JSONObject, Error>) -> Void]()
  private var subscriptions : [String: String] = [:]
  let processingQueue = DispatchQueue(label: "com.apollographql.WebSocketTransport")

  private let sendOperationIdentifiers: Bool
  private let reconnectionInterval: TimeInterval
  private let allowSendingDuplicates: Bool
  fileprivate var reconnected = false

  /// - NOTE: Setting this won't override immediately if the socket is still connected, only on reconnection.
  public var clientName: String {
    didSet {
      self.addApolloClientHeaders(to: &self.websocket.request)
    }
  }

  /// - NOTE: Setting this won't override immediately if the socket is still connected, only on reconnection.
  public var clientVersion: String {
    didSet {
      self.addApolloClientHeaders(to: &self.websocket.request)
    }
  }

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - websocket: The websocket client to use for creating a websocket connection.
  ///   - store: [optional] The `ApolloStore` used as a local cache. Defaults to `nil`.
  ///   - clientName: The client name to use for this client. Defaults to `Self.defaultClientName`
  ///   - clientVersion: The client version to use for this client. Defaults to `Self.defaultClientVersion`.
  ///   - sendOperationIdentifiers: Whether or not to send operation identifiers with operations. Defaults to false.
  ///   - reconnect: Whether to auto reconnect when websocket looses connection. Defaults to true.
  ///   - reconnectionInterval: How long to wait before attempting to reconnect. Defaults to half a second.
  ///   - allowSendingDuplicates: Allow sending duplicate messages. Important when reconnected. Defaults to true.
  ///   - connectOnInit: Whether the websocket connects immediately on creation. If false, remember to call `resumeWebSocketConnection()` to connect. Defaults to true.
  ///   - connectingPayload: [optional] The payload to send on connection. Defaults to an empty `GraphQLMap`.
  ///   - requestBodyCreator: The `RequestBodyCreator` to use when serializing requests. Defaults to an `ApolloRequestBodyCreator`.
  ///   - operationMessageIdCreator: The `OperationMessageIdCreator` used to generate a unique message identifier per request. Defaults to `ApolloSequencedOperationMessageIdCreator`.
  public init(websocket: WebSocketClient,
              store: ApolloStore? = nil,
              clientName: String = WebSocketTransport.defaultClientName,
              clientVersion: String = WebSocketTransport.defaultClientVersion,
              sendOperationIdentifiers: Bool = false,
              reconnect: Bool = true,
              reconnectionInterval: TimeInterval = 0.5,
              allowSendingDuplicates: Bool = true,
              connectOnInit: Bool = true,
              connectingPayload: GraphQLMap? = [:],
              requestBodyCreator: RequestBodyCreator = ApolloRequestBodyCreator(),
              operationMessageIdCreator: OperationMessageIdCreator = ApolloSequencedOperationMessageIdCreator()) {
    self.websocket = websocket
    self.store = store
    self.connectingPayload = connectingPayload
    self.sendOperationIdentifiers = sendOperationIdentifiers
    self.reconnect = Atomic(reconnect)
    self.reconnectionInterval = reconnectionInterval
    self.allowSendingDuplicates = allowSendingDuplicates
    self.requestBodyCreator = requestBodyCreator
    self.operationMessageIdCreator = operationMessageIdCreator
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
    return self.socketConnectionState.value.isConnected
  }

  public func ping(data: Data, completionHandler: (() -> Void)? = nil) {
    return websocket.write(ping: data, completion: completionHandler)
  }

  private func processMessage(text: String) {
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
           .next,
           .error:
        if let id = parseHandler.id, let responseHandler = subscribers[id] {
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

      case .connectionKeepAlive,
           .startAck,
           .pong:
        writeQueue()

      case .ping:
        if let str = OperationMessage(type: .pong).rawMessage {
          write(str)
          writeQueue()
        }

      case .connectionInit,
           .connectionTerminate,
           .subscribe,
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

  private func processMessage(data: Data) {
    print("WebSocketTransport::unprocessed event \(data)")
  }

  public func initServer() {
    processingQueue.async {
      self.acked = false

      if let str = OperationMessage(payload: self.connectingPayload, type: .connectionInit).rawMessage {
        self.write(str, force:true)
      }
    }
  }

  public func closeConnection() {
    self.reconnect.mutate { $0 = false }

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
    if self.socketConnectionState.value.isConnected && (acked || forced) {
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
    self.websocket.delegate = nil
  }

  func sendHelper<Operation: GraphQLOperation>(operation: Operation, resultHandler: @escaping (_ result: Result<JSONObject, Error>) -> Void) -> String? {
    let body = requestBodyCreator.requestBody(for: operation,
                                              sendOperationIdentifiers: self.sendOperationIdentifiers,
                                              sendQueryDocument: true,
                                              autoPersistQuery: false)
    let identifier = operationMessageIdCreator.requestId()

    let messageType: OperationMessage.Types
    switch websocket.request.wsProtocol {
    case .graphql_ws: messageType = .start
    case .graphql_transport_ws: messageType = .subscribe
    default: return nil
    }

    guard let message = OperationMessage(payload: body, id: identifier, type: messageType).rawMessage else {
      return nil
    }

    processingQueue.async {
      self.write(message)

      self.subscribers[identifier] = resultHandler
      if operation.operationType == .subscription {
        self.subscriptions[identifier] = message
      }
    }

    return identifier
  }

  public func unsubscribe(_ subscriptionId: String) {
    let messageType: OperationMessage.Types
    switch websocket.request.wsProtocol {
    case .graphql_transport_ws: messageType = .complete
    default: messageType = .stop
    }

    let str = OperationMessage(id: subscriptionId, type: messageType).rawMessage

    processingQueue.async {
      if let str = str {
        self.write(str)
      }
      self.subscribers.removeValue(forKey: subscriptionId)
      self.subscriptions.removeValue(forKey: subscriptionId)
    }
  }

  public func updateHeaderValues(_ values: [String: String?], reconnectIfConnected: Bool = true) {
    for (key, value) in values {
      self.websocket.request.setValue(value, forHTTPHeaderField: key)
    }

    if reconnectIfConnected && isConnected() {
      self.reconnectWebSocket()
    }
  }

  public func updateConnectingPayload(_ payload: GraphQLMap, reconnectIfConnected: Bool = true) {
    self.connectingPayload = payload

    if reconnectIfConnected && isConnected() {
      self.reconnectWebSocket()
    }
  }

  private func reconnectWebSocket() {
    let oldReconnectValue = reconnect.value
    self.reconnect.mutate { $0 = false }

    self.websocket.disconnect()
    self.websocket.connect()

    self.reconnect.mutate { $0 = oldReconnectValue }
  }
  
  /// Disconnects the websocket while setting the auto-reconnect value to false,
  /// allowing purposeful disconnects that do not dump existing subscriptions.
  /// NOTE: You will receive an error on the subscription (should be a `WebSocket.WSError` with code 1000) when the socket disconnects.
  /// ALSO NOTE: To reconnect after calling this, you will need to call `resumeWebSocketConnection`.
  public func pauseWebSocketConnection() {
    self.reconnect.mutate { $0 = false }
    self.websocket.disconnect()
  }
  
  /// Reconnects a paused web socket.
  ///
  /// - Parameter autoReconnect: `true` if you want the websocket to automatically reconnect if the connection drops. Defaults to true.
  public func resumeWebSocketConnection(autoReconnect: Bool = true) {
    self.reconnect.mutate { $0 = autoReconnect }
    self.websocket.connect()
  }
}

extension URLRequest {
  fileprivate var wsProtocol: WebSocket.WSProtocol? {
    guard let header = value(forHTTPHeaderField: WebSocket.Constants.headerWSProtocolName) else {
      return nil
    }

    switch header {
    case WebSocket.WSProtocol.graphql_transport_ws.description: return .graphql_transport_ws
    case WebSocket.WSProtocol.graphql_ws.description: return .graphql_ws
    default: return nil
    }
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

    return WebSocketTask(self, operation) { [weak store, contextIdentifier, callbackQueue] result in
      switch result {
      case .success(let jsonBody):
        do {
          let response = GraphQLResponse(operation: operation, body: jsonBody)

          if let store = store {
            let (graphQLResult, parsedRecords) = try response.parseResult(cacheKeyForObject: store.cacheKeyForObject)
            guard let records = parsedRecords else {
              callCompletion(with: .success(graphQLResult))
              return
            }

            store.publish(records: records,
                          identifier: contextIdentifier,
                          callbackQueue: callbackQueue) { result in
              switch result {
              case .success:
                completionHandler(.success(graphQLResult))

              case let .failure(error):
                callCompletion(with: .failure(error))
              }
            }

          } else {
            let graphQLResult = try response.parseResultFast()
            callCompletion(with: .success(graphQLResult))
          }

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

extension WebSocketTransport: WebSocketClientDelegate {

  public func websocketDidConnect(socket: WebSocketClient) {
    self.handleConnection()
  }

  public func handleConnection() {
    self.error.mutate { $0 = nil }
    self.socketConnectionState.mutate { $0 = .connected }
    initServer()
    if self.reconnected {
      self.delegate?.webSocketTransportDidReconnect(self)
      // re-send the subscriptions whenever we are re-connected
      // for the first connect, any subscriptions are already in queue
      for (_, msg) in self.subscriptions {
        if self.allowSendingDuplicates {
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

    self.reconnected = true
  }

  public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    self.socketConnectionState.mutate { $0 = .disconnected }
    if let error = error {
      debugPrint("websocket is disconnected: \(error)")
      handleDisconnection(with: error)
    } else {
      self.error.mutate { $0 = nil }
      debugPrint("websocket is disconnected")
      self.handleDisconnection()
    }
  }

  private func handleDisconnection(with error: Error) {
    // Set state to `.failed`, and grab its previous value.
    let previousState: SocketConnectionState = self.socketConnectionState.mutate { socketConnectionState in
      let previousState = socketConnectionState
      socketConnectionState = .failed
      return previousState
    }
    // report any error to all subscribers
    self.error.mutate { $0 = WebSocketError(payload: nil,
                                            error: error,
                                            kind: .networkError) }
    self.notifyErrorAllHandlers(error)

    switch previousState {
    case .connected, .disconnected:
      self.handleDisconnection()
    case .failed:
      // Don't attempt at reconnecting if already failed.
      // Websockets will sometimes notify several errors in a row, and
      // we don't want to perform disconnection handling multiple times.
      // This avoids https://github.com/apollographql/apollo-ios/issues/1753
      break
    }
  }

  private func handleDisconnection()  {
    self.delegate?.webSocketTransport(self, didDisconnectWithError: self.error.value)
    self.acked = false // need new connect and ack before sending

    self.attemptReconnectionIfDesired()
  }

  private func attemptReconnectionIfDesired() {
    guard self.reconnect.value else {
      return
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + reconnectionInterval) { [weak self] in
      guard let self = self else { return }
      self.socketConnectionState.mutate { socketConnectionState in
        switch socketConnectionState {
        case .disconnected, .connected:
          break
        case .failed:
          // Reset state to `.disconnected`, so that we can perform
          // disconnection handling if this reconnection triggers an error.
          // (See how errors are handled in didReceive(event:client:).
          socketConnectionState = .disconnected
        }
      }
      self.websocket.connect()
    }
  }

  public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    self.processMessage(text: text)
  }

  public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    self.processMessage(data: data)
  }
  
}

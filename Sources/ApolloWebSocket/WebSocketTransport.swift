import Apollo
import Starscream

// To allow for alternative implementations supporting the same WebSocketClient protocol
public class ApolloWebSocket : WebSocket, ApolloWebSocketClient {
  required public convenience init(request: URLRequest, protocols: [String]? = nil) {
    self.init(request: request, protocols: protocols, stream: FoundationStream())
  }
}

public protocol ApolloWebSocketClient: WebSocketClient {
  init(request: URLRequest, protocols: [String]?)
}

/// A network transport that uses web sockets requests to send GraphQL subscription operations to a server, and that uses the Starscream implementation of web sockets.
public class WebSocketTransport {
  public static var provider : ApolloWebSocketClient.Type = ApolloWebSocket.self
  let serializationFormat = JSONSerializationFormat.self
  var reconnect = false

  private let protocols = ["graphql-ws"]
  internal let websocket: WebSocketClient
  private var acked = false

  private var messageQueue: [Int: String] = [:]
  private var connectingPayload: GraphQLMap?

  private let processingQueue = DispatchQueue(label: "com.apollographql.websocket-processing")
  private let lock = NSLock()

  private var subscribers = [String: (JSONObject?, Error?) -> Void]()
  private var subscriptions : [String: String] = [:]

  private let sendOperationIdentifiers: Bool
  private var reconnected: Bool = false
  private var sequenceNumber: Int = 0

  public init(request: URLRequest, sendOperationIdentifiers: Bool = false,  connectingPayload: GraphQLMap? = [:]) {
    self.connectingPayload = connectingPayload
    self.sendOperationIdentifiers = sendOperationIdentifiers

    self.websocket = WebSocketTransport.provider.init(request: request, protocols: protocols)
    self.websocket.delegate = self
    self.websocket.connect()
  }

  public func isConnected() -> Bool {
    return websocket.isConnected
  }

  private func processMessage(socket: WebSocketClient, text: String) {
    OperationMessage(serialized: text).parse { (type, id, payload, error) in
      guard let type = type, let messageType = OperationMessage.Types(rawValue: type) else {
        return notifyErrorAllHandlers(WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(text)))
      }

      switch(messageType) {
      case .data, .error:
        if let id = id, let responseHandler = subscribers[id] {
          responseHandler(payload,error)
        } else {
          notifyErrorAllHandlers(WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(text)))
        }

      case .complete:
        if let id = id {
          // remove the callback if NOT a subscription
          if subscriptions[id] == nil {
            lock.lock()
            subscribers.removeValue(forKey: id)
            lock.unlock()
          }
        } else {
          notifyErrorAllHandlers(WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(text)))
        }

      case .connectionAck:
        lock.lock()
        acked = true
        lock.unlock()
        processWriteQueue()

      case .connectionKeepAlive:
        processWriteQueue()

      case .connectionInit, .connectionTerminate, .start, .stop, .connectionError:
        notifyErrorAllHandlers(WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(text)))
      }
    }
  }

  func notifyErrorAllHandlers(_ error: Error) {
    for (_, handler) in subscribers {
      handler(nil, error)
    }
  }

  private func processWriteQueue() {
    lock.lock()
    guard !self.messageQueue.isEmpty else {
      lock.unlock()
      return
    }

    let queue = self.messageQueue.sorted(by: { $0.0 < $1.0 })
    self.messageQueue.removeAll()
    lock.unlock()

    for (id, msg) in queue {
      write(msg,id: id)
    }
  }

  private func processMessage(socket: WebSocketClient, data: Data) {
    print("WebSocketTransport::unprocessed event \(data)")
  }

  private func initServer() {
    self.acked = false

    if let str = OperationMessage(payload: self.connectingPayload, type: .connectionInit).rawMessage {
      write(str, force:true)
    }
  }

  public func closeConnection() {
    self.reconnect = false
    if let str = OperationMessage(type: .connectionTerminate).rawMessage {
      write(str)
    }

    self.messageQueue.removeAll()
    self.subscriptions.removeAll()
  }

  private func write(_ str: String, force forced: Bool = false, id : Int? = nil) {
    if websocket.isConnected && (acked || forced) {
      websocket.write(string: str)
    } else {
      // using sequence number to make sure that the queue is processed correctly
      // either using the earlier assigned id or with the next higher key
      if let id = id {
        messageQueue[id] = str
      } else if let id = messageQueue.keys.max() {
        messageQueue[id+1] = str
      } else {
        messageQueue[1] = str
      }
    }
  }

  deinit {
    websocket.disconnect()
    websocket.delegate = nil
  }

  fileprivate func nextSequenceNumber() -> Int {
    sequenceNumber += 1
    return sequenceNumber
  }

  fileprivate func sendHelper<Operation: GraphQLOperation>(operation: Operation, resultHandler: @escaping (_ response: JSONObject?, _ error: Error?) -> Void) -> String? {
    let body = requestBody(for: operation)

    let sequenceNumber = "\(nextSequenceNumber())"

    if let str = OperationMessage(payload: body, id: sequenceNumber).rawMessage {
      write(str)

      lock.lock()
      subscribers[sequenceNumber] = resultHandler
      if operation.operationType == .subscription {
        subscriptions[sequenceNumber] = str
      }
      lock.unlock()

      return sequenceNumber
    }

    return nil

  }

  private func requestBody<Operation: GraphQLOperation>(for operation: Operation) -> GraphQLMap {
    if sendOperationIdentifiers {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }
      return ["id": operationIdentifier, "variables": operation.variables]
    }
    return ["query": operation.queryDocument, "variables": operation.variables]
  }

  public func unsubscribe(_ subscriptionId: String) {
    if let str = OperationMessage(id: subscriptionId, type: .stop).rawMessage {
      write(str)
    }
    lock.lock()
    subscribers.removeValue(forKey: subscriptionId)
    subscriptions.removeValue(forKey: subscriptionId)
    lock.unlock()
  }

  fileprivate final class WebSocketTask<Operation: GraphQLOperation>: Cancellable {
    let sequenceNumber: String?
    let transport: WebSocketTransport

    init(transport: WebSocketTransport, operation: Operation, completionHandler: @escaping (_ response: JSONObject?, _ error: Error?) -> Void) {
      sequenceNumber = transport.sendHelper(operation: operation, resultHandler: completionHandler)
      self.transport = transport
    }

    public func cancel() {
      if let sequenceNumber = sequenceNumber {
        transport.unsubscribe(sequenceNumber)
      }
    }

    // unsubscribe same as cancel
    public func unsubscribe() {
      cancel()
    }
  }

  fileprivate final class OperationMessage {
    enum Types: String {
      case connectionInit = "connection_init"           // Client -> Server
      case connectionTerminate = "connection_terminate" // Client -> Server
      case start = "start"                              // Client -> Server
      case stop = "stop"                                // Client -> Server

      case connectionAck = "connection_ack"             // Server -> Client
      case connectionError = "connection_error"         // Server -> Client
      case connectionKeepAlive = "ka"                   // Server -> Client
      case data = "data"                                // Server -> Client
      case error = "error"                              // Server -> Client
      case complete = "complete"                        // Server -> Client
    }

    let serializationFormat = JSONSerializationFormat.self
    private var message: GraphQLMap = [:]

    var rawMessage: String? {
      let serialized = try! serializationFormat.serialize(value: message)
      return String(data: serialized, encoding: .utf8)
    }

    init(payload: GraphQLMap? = nil, id: String? = nil, type: Types = .start) {
      if let payload = payload {
        message += ["payload": payload]
      }
      if let id = id {
        message += ["id": id]
      }
      message += ["type": type.rawValue]
    }

    var serialized: String?

    init(serialized: String) {
      self.serialized = serialized
    }

    func parse(handler: (_ type: String?, _ id: String?, _ payload: JSONObject?, _ error: Error?) -> Void) {
      guard  let serialized = self.serialized else {
        handler(nil, nil, nil, WebSocketError(payload: nil, error: nil, kind: .serializedMessageError))
        return
      }
      guard let data = self.serialized?.data(using: (.utf8) ) else {
        handler(nil, nil, nil, WebSocketError(payload: nil, error: nil, kind: .unprocessedMessage(serialized)))
        return
      }

      var id: String?
      var type: String?
      var payload: JSONObject?

      do {
        let json = try JSONSerializationFormat.deserialize(data: data ) as? JSONObject

        id = json?["id"] as? String
        type = json?["type"] as? String
        payload = json?["payload"] as? JSONObject

        handler(type, id, payload, nil)
      }
      catch {
        handler(type, id, payload, WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(serialized)))
      }
    }
  }
}

extension WebSocketTransport: NetworkTransport {
  public func send<Operation>(operation: Operation, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {
    return WebSocketTask(transport: self, operation: operation) { (body, error) in
      if let body = body {
        let response = GraphQLResponse(operation: operation, body: body)
        completionHandler(response, error)
      } else {
        completionHandler(nil, error)
      }
    }
  }
}

extension WebSocketTransport: WebSocketDelegate {
  public func websocketDidConnect(socket: WebSocketClient) {
    processingQueue.async {
      self.initServer()
      if self.reconnected {
        // re-send the subscriptions whenever we are re-connected
        // for the first connect, any subscriptions are already in queue
        for (_, msg) in self.subscriptions {
          self.write(msg)
        }
      }
      self.reconnected = true
    }
  }

  public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    // report any error to all subscribers
    if let error = error {
      let webSocketError = WebSocketError(payload: nil, error: error, kind: .networkError)
      for (_, responseHandler) in subscribers {
        responseHandler(nil, webSocketError)
      }
    }

    lock.lock()
    self.acked = false // need new connect and ack before sending
    lock.unlock()

    processingQueue.async {
      if self.reconnect {
        self.websocket.connect();
      }
    }
  }

  public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    processingQueue.async {
      self.processMessage(socket: socket, text: text)
    }
  }

  public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    processingQueue.async {
      self.processMessage(socket: socket, data: data)
    }
  }
}

public struct WebSocketError: Error, LocalizedError {
  public enum ErrorKind {
    case errorResponse
    case networkError
    case unprocessedMessage(String)
    case serializedMessageError

    var description: String {
      switch self {
      case .errorResponse:
        return "Received error response"
      case .networkError:
        return "Websocket network error"
      case .unprocessedMessage(let message):
        return "Websocket error: Unprocessed message \(message)"
      case .serializedMessageError:
        return "Websocket error: Serialized message not found"
      }
    }
  }

  /// The payload of the response.
  public let payload: JSONObject?
  public let error: Error?
  public let kind: ErrorKind
}

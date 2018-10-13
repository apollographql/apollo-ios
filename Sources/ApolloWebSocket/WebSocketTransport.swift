import Apollo
import Starscream

// To allow for alternative implementations supporting the same WebSocketClient protocol
public class ApolloWebSocket: WebSocket, ApolloWebSocketClient {
  required public convenience init(request: URLRequest, protocols: [String]? = nil) {
    self.init(request: request, protocols: protocols, stream: FoundationStream())
  }
}

public protocol ApolloWebSocketClient: WebSocketClient {
  init(request: URLRequest, protocols: [String]?)
}

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

/// A network transport that uses web sockets requests to send GraphQL subscription operations to a server, and that uses the Starscream implementation of web sockets.
public class WebSocketTransport: NetworkTransport, WebSocketDelegate {
  public static var provider : ApolloWebSocketClient.Type = ApolloWebSocket.self
  public weak var delegate: WebSocketTransportDelegate?
    
  var reconnect = false
  var websocket: ApolloWebSocketClient
  var error: Error? = nil
  let serializationFormat = JSONSerializationFormat.self

  private final let protocols = ["graphql-ws"]

  private var acked = false
  
  private var queue: [Int: String] = [:]
  private var connectingPayload: GraphQLMap?

  private var subscribers = [String: (JSONObject?, Error?) -> Void]()
  private var subscriptions : [String: String] = [:]
  
  private let sendOperationIdentifiers: Bool
  private let reconnectionInterval: TimeInterval
  fileprivate var sequenceNumber = 0
  fileprivate var reconnected = false

  public init(request: URLRequest, sendOperationIdentifiers: Bool = false, reconnectionInterval: TimeInterval = 0.5, connectingPayload: GraphQLMap? = [:]) {
    self.connectingPayload = connectingPayload
    self.sendOperationIdentifiers = sendOperationIdentifiers
    self.reconnectionInterval = reconnectionInterval

    self.websocket = WebSocketTransport.provider.init(request: request, protocols: protocols)
    self.websocket.delegate = self
    self.websocket.connect()
  }
  
  public func send<Operation>(operation: Operation, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {
    if let error = self.error {
      completionHandler(nil,error)
    }
    
    return WebSocketTask(self,operation) { (body, error) in
      if let body = body {
        let response = GraphQLResponse(operation: operation, body: body)
        completionHandler(response,error)
      } else {
        completionHandler(nil,error)
      }
    }
    
  }
  
  public func isConnected() -> Bool {
    return websocket.isConnected
  }
  
  private func processMessage(socket: WebSocketClient, text: String) {
    OperationMessage(serialized: text).parse { (type, id, payload, error) in
      guard let type = type, let messageType = OperationMessage.Types(rawValue: type) else {
        notifyErrorAllHandlers(WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(text)))
        return
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
            subscribers.removeValue(forKey: id)
          }
        } else {
          notifyErrorAllHandlers(WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(text)))
        }

      case .connectionAck:
        acked = true
        writeQueue()

      case .connectionKeepAlive:
        writeQueue()

      case .connectionInit, .connectionTerminate, .start, .stop, .connectionError:
        notifyErrorAllHandlers(WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(text)))
      }
    }
  }
  
  private func notifyErrorAllHandlers(_ error: Error) {
    for (_, handler) in subscribers {
      handler(nil,error)
    }
  }
  
  private func writeQueue() {
    guard !self.queue.isEmpty else {
      return
    }

    let queue = self.queue.sorted(by: { $0.0 < $1.0 })
    self.queue.removeAll()
    for (id, msg) in queue {
      self.write(msg,id: id)
    }
  }
  
  private func processMessage(socket: WebSocketClient, data: Data) {
    print("WebSocketTransport::unprocessed event \(data)")
  }
  
  public func websocketDidConnect(socket: WebSocketClient) {
    self.error = nil
    initServer()
    if reconnected {
        self.delegate?.webSocketTransportDidReconnect(self)
      // re-send the subscriptions whenever we are re-connected
      // for the first connect, any subscriptions are already in queue
      for (_,msg) in self.subscriptions {
        write(msg)
      }
    } else {
        self.delegate?.webSocketTransportDidConnect(self)
    }
    
    reconnected = true
  }
  
  public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    // report any error to all subscribers
    if let error = error {
      self.error = WebSocketError(payload: nil, error: error, kind: .networkError)
      for (_, responseHandler) in subscribers {
        responseHandler(nil,error)
      }
    } else {
      self.error = nil
    }
    
    self.delegate?.webSocketTransport(self, didDisconnectWithError: self.error)
    acked = false // need new connect and ack before sending
    
    if reconnect {
      DispatchQueue.main.asyncAfter(deadline: .now() + reconnectionInterval) {
        self.websocket.connect();
      }
    }
  }
  
  public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    processMessage(socket: socket, text: text)
  }
  
  public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    processMessage(socket: socket, data: data)
  }
  
  public func initServer(reconnect: Bool = true) {
    self.reconnect = reconnect
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
    self.queue.removeAll()
    self.subscriptions.removeAll()
  }
  
  private func write(_ str: String, force forced: Bool = false, id: Int? = nil) {
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
  
  fileprivate func nextSequenceNumber() -> Int {
    sequenceNumber += 1
    return sequenceNumber
  }
  
  fileprivate func sendHelper<Operation: GraphQLOperation>(operation: Operation, resultHandler: @escaping (_ response: JSONObject?, _ error: Error?) -> Void) -> String? {
    let body = requestBody(for: operation)
    let sequenceNumber = "\(nextSequenceNumber())"
    
    guard let message = OperationMessage(payload: body, id: sequenceNumber).rawMessage else {
      return nil
    }

    write(message)
      
    subscribers[sequenceNumber] = resultHandler
    if operation.operationType == .subscription {
      subscriptions[sequenceNumber] = message
    }

    return sequenceNumber
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
    subscribers.removeValue(forKey: subscriptionId)
    subscriptions.removeValue(forKey: subscriptionId)
  }
  
  fileprivate final class WebSocketTask<Operation: GraphQLOperation> : Cancellable {
    let sequenceNumber : String?
    let transport: WebSocketTransport
    
    init(_ ws: WebSocketTransport, _ operation: Operation, _ completionHandler: @escaping (_ response: JSONObject?, _ error: Error?) -> Void) {
      sequenceNumber = ws.sendHelper(operation: operation, resultHandler: completionHandler)
      transport = ws
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
    enum Types : String {
      case connectionInit = "connection_init"            // Client -> Server
      case connectionTerminate = "connection_terminate"  // Client -> Server
      case start = "start"                               // Client -> Server
      case stop = "stop"                                 // Client -> Server
      
      case connectionAck = "connection_ack"              // Server -> Client
      case connectionError = "connection_error"          // Server -> Client
      case connectionKeepAlive = "ka"                    // Server -> Client
      case data = "data"                                 // Server -> Client
      case error = "error"                               // Server -> Client
      case complete = "complete"                         // Server -> Client
    }
    
    let serializationFormat = JSONSerializationFormat.self
    var message: GraphQLMap = [:]
    var serialized: String?
    
    var rawMessage : String? {
      let serialized = try! serializationFormat.serialize(value: message)
      if let str = String(data: serialized, encoding: .utf8) {
        return str
      } else {
        return nil
      }
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
    
    init(serialized: String) {
      self.serialized = serialized
    }
    
    func parse(handler: (_ type: String?, _ id: String?, _ payload: JSONObject?, _ error: Error?) -> Void) {
      guard let serialized = self.serialized else {
        handler(nil, nil, nil, WebSocketError(payload: nil, error: nil, kind: .serializedMessageError))
        return
      }

      guard let data = self.serialized?.data(using: (.utf8) ) else {
        handler(nil, nil, nil, WebSocketError(payload: nil, error: nil, kind: .unprocessedMessage(serialized)))
        return
      }

      var type : String?
      var id : String?
      var payload : JSONObject?

      do {
        let json = try JSONSerializationFormat.deserialize(data: data ) as? JSONObject

        id = json?["id"] as? String
        type = json?["type"] as? String
        payload = json?["payload"] as? JSONObject

        handler(type,id,payload,nil)
      }
      catch {
        handler(type, id, payload, WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(serialized)))
      }
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

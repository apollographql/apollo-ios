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
public class WebSocketTransport: NetworkTransport, WebSocketDelegate {
  
  final let PROTOCOLS = ["graphql-ws"]
  
  var websocket: WebSocketClient? = nil
  var error : Error? = nil
  
  let serializationFormat = JSONSerializationFormat.self
  
  var reconnect : Bool = false
  var acked : Bool = false
  
  private var queue: [Int:String] = [:]
  private var params: [String:String]?
  private var connectingParams: [String:String]?

  private var subscribers = [String: (JSONObject?, Error?) -> Void]()
  private var subscriptions : [String: String] = [:]
  
  private let sendOperationIdentifiers: Bool
  
  public static var provider : ApolloWebSocketClient.Type = ApolloWebSocket.self
  
  public init(url: URL, sendOperationIdentifiers: Bool = false, params: [String:String]? = nil, connectingParams: [String:String]? = [:]) {
    self.params = params
    self.connectingParams = connectingParams
    self.sendOperationIdentifiers = sendOperationIdentifiers
    var request = URLRequest(url: url)
    if let params = self.params {
      request.allHTTPHeaderFields = params
    }
    self.websocket = WebSocketTransport.provider.init(request: request, protocols: PROTOCOLS)
    
    self.websocket?.delegate = self
    self.websocket?.connect()
  }
  
  public init(request: URLRequest? = nil, sendOperationIdentifiers: Bool = false,  params: [String:String]? = nil,  connectingParams: [String:String]? = [:]) {
    self.params = params
    self.connectingParams = connectingParams
    self.sendOperationIdentifiers = sendOperationIdentifiers
    if var request = request {
      if let params = self.params {
        request.allHTTPHeaderFields = params
      }
      // self.websocket = WebSocket(request: request, protocols: PROTOCOLS)
      self.websocket = WebSocketTransport.provider.init(request: request, protocols: PROTOCOLS)
      self.websocket?.delegate = self
      self.websocket?.connect()
    }
  }
  
  public func connect(request: URLRequest) {
    // self.websocket = WebSocket(request: request, protocols: PROTOCOLS)
    self.websocket = WebSocketTransport.provider.init(request: request, protocols: PROTOCOLS)
    self.websocket?.delegate = self
    self.websocket?.connect()
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
    return websocket?.isConnected ?? false
  }
  
  private func processMessage(socket: WebSocketClient, text: String) {
    
    OperationMessage(serialized: text).parse { (type,id,payload,error) in
      if let type = type {
        switch(type) {
        case OperationMessage.Types.DATA.rawValue,
             OperationMessage.Types.ERROR.rawValue:
          if let id = id, let responseHandler = subscribers[id] {
            responseHandler(payload,error)
          } else {
            notifyErrorAllHandlers(WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(text)))
          }
          
        case OperationMessage.Types.COMPLETE.rawValue:
          if let id = id {
            // remove the callback if NOT a subscription
            if subscriptions[id] == nil {
              subscribers.removeValue(forKey: id)
            }
          } else {
            notifyErrorAllHandlers(WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(text)))
          }
          
        case OperationMessage.Types.CONNECTION_ACK.rawValue:
          acked = true
          writeQueue()

        case OperationMessage.Types.CONNECTION_KEEP_ALIVE.rawValue:
          writeQueue()

        default:
          notifyErrorAllHandlers(WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(text)))
        }
      } else {
        notifyErrorAllHandlers(WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(text)))
      }
    }
  }
  
  func notifyErrorAllHandlers(_ error: Error) {
    for (_,handler) in subscribers {
      handler(nil,error)
    }
  }
  
  private func writeQueue() {
    if (!self.queue.isEmpty) {
      let queue = self.queue.sorted(by: { $0.0 < $1.0 })
      self.queue.removeAll()
      for (id,msg) in queue {
        self.write(msg,id: id)
      }
    }
  }
  
  private func processMessage(socket: WebSocketClient, data: Data) {
    print("WebSocketTransport::unprocessed event \(data)")
  }
  
  fileprivate var reconnected : Bool = false
  
  public func websocketDidConnect(socket: WebSocketClient) {
    self.error = nil
    initServer()
    if reconnected {
      // re-send the subscriptions whenever we are re-connected
      // for the first connect, any subscriptions are already in queue
      for (_,msg) in self.subscriptions {
        write(msg)
      }
    }
    reconnected = true
  }
  
  public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    
    // report any error to all subscribers
    if let error = error {
      self.error = WebSocketError(payload: nil, error: error, kind: .networkError)
      for (_,responseHandler) in subscribers {
        responseHandler(nil,error)
      }
    } else {
      self.error = nil
    }
    
    acked = false // need new connect and ack before sending
    
    if (reconnect) {
      websocket?.connect();
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
    
    if let str = OperationMessage(payload: self.connectingParams, type: .CONNECTION_INIT).rawValue {
      write(str, force:true)
    }
    
  }
  
  public func closeConnection() {
    self.reconnect = false
    if let str = OperationMessage(type: .CONNECTION_TERMINATE).rawValue {
      write(str)
    }
    self.queue.removeAll()
    self.subscriptions.removeAll()
  }
  
  private func write(_ str: String, force forced: Bool = false, id : Int? = nil) {
    
    if let websocket = websocket {
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
  }
  
  deinit {
    websocket?.disconnect()
    websocket?.delegate = nil
  }
  
  fileprivate var sequenceNumber : Int = 0
  
  fileprivate func nextSeqNo() -> Int {
    sequenceNumber += 1
    return sequenceNumber
  }
  
  fileprivate func sendHelper<Operation: GraphQLOperation>(operation: Operation, resultHandler: @escaping (_ response: JSONObject?, _ error: Error?) -> Void) -> String? {
    
    let body = requestBody(for: operation)
    
    let seqNo = "\(nextSeqNo())"
    
    if let str = OperationMessage(payload: body, id: seqNo).rawValue {
      write(str)
      
      subscribers[seqNo] = resultHandler
      if operation.operationType == .subscription {
        subscriptions[seqNo] = str
      }
      
      return seqNo
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
    if let str = OperationMessage(id: subscriptionId, type: .STOP).rawValue {
      write(str)
    }
    subscribers.removeValue(forKey: subscriptionId)
    subscriptions.removeValue(forKey: subscriptionId)
  }
  
  fileprivate final class WebSocketTask<Operation: GraphQLOperation> : Cancellable {
    
    let seqNo : String?
    let wst: WebSocketTransport
    
    init(_ ws: WebSocketTransport, _ operation: Operation, _ completionHandler: @escaping (_ response: JSONObject?, _ error: Error?) -> Void) {
      
      seqNo = ws.sendHelper(operation: operation, resultHandler: completionHandler)
      wst = ws
    }
    
    public func cancel() {
      if let seqNo = seqNo {
        wst.unsubscribe(seqNo)
      }
    }
    
    // unsubscribe same as cancel
    public func unsubscribe() {
      cancel()
    }
    
  }
  
  fileprivate final class OperationMessage {
    
    public enum Types : String {
      case CONNECTION_INIT = "connection_init"            // Client -> Server
      case CONNECTION_TERMINATE = "connection_terminate"  // Client -> Server
      case START = "start"                                // Client -> Server
      case STOP = "stop"                                  // Client -> Server
      
      case CONNECTION_ACK = "connection_ack"              // Server -> Client
      case CONNECTION_ERROR = "connection_error"          // Server -> Client
      case CONNECTION_KEEP_ALIVE = "ka"                   // Server -> Client
      case DATA = "data"                                  // Server -> Client
      case ERROR = "error"                                // Server -> Client
      case COMPLETE = "complete"                          // Server -> Client
    }
    
    let serializationFormat = JSONSerializationFormat.self
    var message : GraphQLMap = [:]
    
    var rawValue : String? {
      get {
        let serialized = try! serializationFormat.serialize(value: message)
        if let str = String(data: serialized, encoding: .utf8) {
          return str
        } else {
          return nil
        }
      }
    }
    
    init(payload: GraphQLMap? = nil, id: String? = nil, type: Types = .START) {
      if let payload = payload {
        message += ["payload": payload]
      }
      if let id = id {
        message += ["id": id]
      }
      message += ["type": type.rawValue]
    }
    
    var serialized : String?
    
    init(serialized: String) {
      self.serialized = serialized
    }
    
    func parse(handler: (_ type: String?, _ id: String?, _ payload: JSONObject?, _ error: Error?) -> Void) {
      
      var type : String?
      var id : String?
      var payload : JSONObject?
      
      if let serialized = self.serialized {
        if let data = self.serialized?.data(using: (.utf8) ) {
          do {
            let json = try JSONSerializationFormat.deserialize(data: data ) as? JSONObject
            
            id = json?["id"] as? String
            type = json?["type"] as? String
            payload = json?["payload"] as? JSONObject
            
            handler(type,id,payload,nil)
          }
          catch {
            handler(type,id,payload,
                    WebSocketError(payload: payload, error: error, kind: .unprocessedMessage(serialized)))
          }
        } else {
          handler(type,id,payload,
                  WebSocketError(payload: payload, error: nil, kind: .unprocessedMessage(serialized)))
        }
      } else {
        handler(type,id,payload,
                WebSocketError(payload: payload, error: nil, kind: .serializedMessageError))
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

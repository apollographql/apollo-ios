import Foundation
import Starscream

fileprivate var sequenceNumber : Int = 0

/// A network transport that uses web sockets requests to send GraphQL subscription operations to a server, and that uses the Starscream implementation of web sockets.
public class WebSocketTransport: NetworkTransport, WebSocketDelegate {

    final let PROTOCOLS = ["graphql-ws"]
    
    var websocket: WebSocket? = nil
    var error : Error? = nil
    
    let serializationFormat = JSONSerializationFormat.self
    
    var reconnect : Bool = false
    var acked : Bool = false
    var reconnected : Bool = false
    
    private var queue: [String] = []
    private var params: [String:String]?
    
    private var subscribers = [String: (JSONObject?, Error?) -> Void]()
    private var subscriptions : [String: String] = [:]
    
    private let sendOperationIdentifiers: Bool
    
    public init(url: URL, sendOperationIdentifiers: Bool = false, params: [String:String]? = nil) {
        self.params = params
        self.sendOperationIdentifiers = sendOperationIdentifiers
        var request = URLRequest(url: url)
        if let params = self.params {
            request.allHTTPHeaderFields = params
        }
        self.websocket = WebSocket(request: request, protocols: PROTOCOLS)
        self.websocket?.delegate = self
        self.websocket?.connect()
    }
    
    public init(request: URLRequest? = nil, sendOperationIdentifiers: Bool = false,  params: [String:String]? = nil) {
        self.params = params
        self.sendOperationIdentifiers = sendOperationIdentifiers
        if var request = request {
            if let params = self.params {
                request.allHTTPHeaderFields = params
            }
            self.websocket = WebSocket(request: request, protocols: PROTOCOLS)
            self.websocket?.delegate = self
            self.websocket?.connect()
        }
    }
    
    public func connect(request: URLRequest) {
        self.websocket = WebSocket(request: request, protocols: PROTOCOLS)
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
        
        if let data = text.data(using: (.utf8) ) {
            do {
                let json = try JSONSerializationFormat.deserialize(data: data) as? JSONObject
                if let msgtype = json?["type"] as? String {
                    switch(msgtype) {
                    case OperationMessage.Types.DATA.rawValue:
                        if let id = json?["id"] as? String,
                            let responseHandler = subscribers[id] {
                            
                            let payload = json?["payload"] as? JSONObject
                            responseHandler(payload,nil)
                        }
                        
                    case OperationMessage.Types.ERROR.rawValue:
                        if let id = json?["id"] as? String,
                            let responseHandler = subscribers[id] {
                            
                            let payload = json?["payload"] as? JSONObject
                            let responseError = json?["error"] as? Error
                            let error = WebSocketError(payload: payload, error: responseError, kind: .errorResponse)
                            responseHandler(payload,error)
                        }
                        
                    case OperationMessage.Types.COMPLETE.rawValue:
                        if let id = json?["id"] as? String {
                            // remove the callback if NOT a subscription
                            if subscriptions[id] == nil {
                                subscribers.removeValue(forKey: id)
                            }
                        }
                        
                    case OperationMessage.Types.CONNECTION_ACK.rawValue,
                         OperationMessage.Types.CONNECTION_KEEP_ALIVE.rawValue:

                        acked = (msgtype == OperationMessage.Types.CONNECTION_ACK.rawValue)
                        writeQueue()

                    default:
                        print("WebSocketTransport::unprocessed event \(msgtype)")
                    }
                }
            } catch {
                print("WebSocketTransport::unprocessed event \(data)")
            }
        } else {
            print("WebSocketTransport::unprocessed event \(text)")
        }
        
    }
    
    private func writeQueue() {
        if (!self.queue.isEmpty) {
            let queue = self.queue
            self.queue.removeAll()
            for msg in queue.reversed() {
                self.write(msg)
            }
        }
    }
    
    private func processMessage(socket: WebSocketClient, data: Data) {
        print("WebSocketTransport::unprocessed event \(data)")
    }
    
    public func websocketDidConnect(socket: WebSocketClient) {
        self.error = nil
        initServer()
        if reconnected {
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
        
        if let str = OperationMessage(type: .CONNECTION_INIT).rawValue {
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
    
    private func write(_ str: String, force forced: Bool = false) {
        
        if let websocket = websocket {
            websocket.isConnected && (acked || forced) ?
                print("write:: string=\(str)") : print("queueing:: string=\(str)")
        
            websocket.isConnected && (acked || forced) ? websocket.write(string: str) : queue.append(str)
        }
    }
    
    deinit {
        websocket?.disconnect(forceTimeout: 0)
        websocket?.delegate = nil
    }
    
    fileprivate func sendHelper<Operation: GraphQLOperation>(operation: Operation, resultHandler: @escaping (_ response: JSONObject?, _ error: Error?) -> Void) -> String? {
        
        let body = requestBody(for: operation)
        
        sequenceNumber += 1
        let seqNo = "\(sequenceNumber)"
        
        if let str = OperationMessage(payload: body, id: seqNo).rawValue {
            write(str)
            
            subscribers[seqNo] = resultHandler
            subscriptions[seqNo] = str
            
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
        
    }
    
}

public struct WebSocketError: Error, LocalizedError {
    public enum ErrorKind {
        case errorResponse
        case networkError
        
        var description: String {
            switch self {
            case .errorResponse:
                return "Received error response"
            case .networkError:
                return "Websocket network error"
            }
        }
    }
    
    /// The payload of the response.
    public let payload: JSONObject?
    public let error: Error?
    public let kind: ErrorKind
    
}



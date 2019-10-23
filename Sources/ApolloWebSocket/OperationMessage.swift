#if !COCOAPODS
import Apollo
#endif
import Foundation

final class OperationMessage {
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

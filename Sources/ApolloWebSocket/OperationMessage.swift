#if !COCOAPODS
import Apollo
#endif
import Foundation

final class OperationMessage {
  enum Types : String {
    case connectionInit = "connection_init"            // Client -> Server
    case connectionTerminate = "connection_terminate"  // Client -> Server
    case subscribe = "subscribe"                       // Client -> Server
    case start = "start"                               // Client -> Server
    case stop = "stop"                                 // Client -> Server

    case connectionAck = "connection_ack"              // Server -> Client
    case connectionError = "connection_error"          // Server -> Client
    case startAck = "start_ack"                        // Server -> Client
    case connectionKeepAlive = "ka"                    // Server -> Client
    case data = "data"                                 // Server -> Client
    case error = "error"                               // Server -> Client
    case complete = "complete"                         // Server -> Client
    case next = "next"                                 // Server -> Client

    case ping = "ping"                                 // Bidirectional
    case pong = "pong"                                 // Bidirectional
  }

  let serializationFormat = JSONSerializationFormat.self
  let message: GraphQLMap
  var serialized: String?

  var rawMessage : String? {
    let serialized = try! serializationFormat.serialize(value: message)
    if let str = String(data: serialized, encoding: .utf8) {
      return str
    } else {
      return nil
    }
  }

  init(payload: GraphQLMap? = nil,
       id: String? = nil,
       type: Types) {
    var message: GraphQLMap = [:]
    if let payload = payload {
      message["payload"] = payload
    }
    if let id = id {
      message["id"] = id
    }
    message["type"] = type.rawValue
    self.message = message
  }

  init(serialized: String) {
    self.message = [:]
    self.serialized = serialized
  }

  func parse(handler: (ParseHandler) -> Void) {
    guard let serialized = self.serialized else {
      handler(ParseHandler(nil,
                           nil,
                           nil,
                           WebSocketError(payload: nil,
                                          error: nil,
                                          kind: .serializedMessageError)))
      return
    }

    guard let data = self.serialized?.data(using: (.utf8) ) else {
      handler(ParseHandler(nil,
                           nil,
                           nil,
                           WebSocketError(payload: nil,
                                          error: nil,
                                          kind: .unprocessedMessage(serialized))))
      return
    }

    var type : String?
    var id : String?
    var payload : JSONObject?

    do {
      let json = try serializationFormat.deserialize(data: data) as? JSONObject

      id = json?["id"] as? String
      type = json?["type"] as? String
      payload = json?["payload"] as? JSONObject

      handler(ParseHandler(type,
                           id,
                           payload,
                           nil))
    }
    catch {
      handler(ParseHandler(type,
                           id,
                           payload,
                           WebSocketError(payload: payload,
                                          error: error,
                                          kind: .unprocessedMessage(serialized))))
    }
  }
}

extension OperationMessage: CustomDebugStringConvertible {
  var debugDescription: String {
    rawMessage!
  }
}

struct ParseHandler {
  let type: String?
  let id: String?
  let payload: JSONObject?
  let error: Error?

  init(_ type: String?,
       _ id: String?,
       _ payload: JSONObject?,
       _ error: Error?) {
    self.type = type
    self.id = id
    self.payload = payload
    self.error = error
  }
}

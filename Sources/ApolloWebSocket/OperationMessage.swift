#if !COCOAPODS
import Apollo
#endif
import Foundation

final class OperationMessage {
  enum Types : String {
    case connectionInit = "connection_init"            // Client -> Server
    case connectionTerminate = "connection_terminate"  // Client -> Server
    case subscribe = "subscribe"                       // Client -> Server
    case unsubscribe = "unsubscribe"                   // Client -> Server
    case pong = "PONG"                                 // Client -> Server

    case connectionAck = "connection_ack"              // Server -> Client
    case connectionError = "connection_error"          // Server -> Client
    case connectionKeepAlive = "ka"                    // Server -> Client
    case data = "data"                                 // Server -> Client
    case error = "error"                               // Server -> Client
    case complete = "complete"                         // Server -> Client
    case subscriptionUpdate = "subscription update"    // Server -> Client
    case ping = "PING"                                 // Server -> Client
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

  init(eventData: GraphQLMap? = nil,
       id: String? = nil,
       eventType: Types = .subscribe,
       token: String? = nil) {

    var mutableEventData = eventData

    if let id = id {
      message += ["id": id]

      mutableEventData = mutableEventData ?? GraphQLMap()
      mutableEventData?["id"] = id

      if var variables = mutableEventData?["variables"] as? GraphQLMap,
        var input = (variables["input"] as? GraphQLMapConvertible)?.graphQLMap {

        input["clientSubscriptionId"] = id
        variables["input"] = input
        mutableEventData?["variables"] = variables
      }
    }
    if let eventData = mutableEventData {
      message += ["eventData": eventData]
    }
    if let token = token {
      message += ["token": token]
    }
    message += ["eventName": eventType.rawValue]
  }

  init(serialized: String) {
    self.serialized = serialized
  }

  func parse(handler: (ParseHandler) -> Void) {
    guard let serialized = self.serialized else {
      handler(ParseHandler(nil,
                           nil,
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
                           nil,
                           WebSocketError(payload: nil,
                                          error: nil,
                                          kind: .unprocessedMessage(serialized))))
      return
    }

    var id: String?
    var eventName : String?
    var token : String?
    var eventData : JSONObject?

    do {
      let json = try JSONSerializationFormat.deserialize(data: data ) as? JSONObject

      eventData = json?["eventData"] as? JSONObject
      id = eventData?["id"] as? String
      token = json?["token"] as? String
      eventName = json?["eventName"] as? String

      handler(ParseHandler(id,
                           eventName,
                           token,
                           eventData,
                           nil))
    }
    catch {
      handler(ParseHandler(id,
                           eventName,
                           token,
                           eventData,
                           WebSocketError(payload: eventData,
                                          error: error,
                                          kind: .unprocessedMessage(serialized))))
    }
  }
}

struct ParseHandler {

  let id: String?
  let eventName: String?
  let token: String?
  let eventData: JSONObject?
  let error: Error?

  init(_ id: String?,
       _ eventName: String?,
       _ token: String?,
       _ eventData: JSONObject?,
       _ error: Error?) {
    self.id = id
    self.eventName = eventName
    self.token = token
    self.eventData = eventData
    self.error = error
  }
}

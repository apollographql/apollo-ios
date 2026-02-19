@_spi(Internal) import Apollo
@_spi(Internal) import ApolloAPI
import Foundation

extension WebSocketTransport {
  typealias OperationID = Int

  /// GraphQL Websocket Transport Protocol Messages
  ///
  /// The messages sent and recieved by a websocket in conformance with the the `graphql-ws` protocol.
  /// This implementation is in conformance as of Feb. 2026 according to the protocol as defined at:
  /// https://github.com/enisdenjo/graphql-ws/blob/6a31f46cce25644d30253da351978e452ae583a7/PROTOCOL.md
  enum Message {
    enum Outgoing {
      /// Indicates that the client wants to establish a connection within the existing socket.
      /// This connection is not the actual WebSocket communication channel, but is rather a frame within it asking
      /// the server to allow future operation requests.
      ///
      /// The server must receive the connection initialisation message within the allowed waiting time specified in
      /// the `connectionInitWaitTimeout` parameter during the server setup. If the client does not request a
      /// connection within the allowed timeout, the server will close the socket with the event:
      /// `4408: Connection initialisation timeout.`
      ///
      /// If the server receives more than one ConnectionInit message at any given time, the server will close the
      /// socket with the event
      /// `4429: Too many initialisation requests.`
      ///
      /// If the server wishes to reject the connection, for example during authentication, it is recommended to close
      /// the socket with
      /// `4403: Forbidden.`
      case connectionInit(payload: JSONObject?)

      /// Useful for detecting failed connections, displaying latency metrics or other types of network probing.
      ///
      /// A Pong must be sent in response from the receiving party as soon as possible.
      ///
      /// The Ping message can be sent at any time within the established socket.
      ///
      /// The optional payload field can be used to transfer additional details about the ping.
      case ping(payload: JSONObject?)

      /// The response to the Ping message. Must be sent as soon as the Ping message is received.
      ///
      /// The Pong message can be sent at any time within the established socket.
      /// Furthermore, the Pong message may even be sent unsolicited as an unidirectional heartbeat.
      ///
      /// The optional payload field can be used to transfer additional details about the pong.
      case pong(payload: JSONObject?)

      /// Requests an operation specified in the message payload. This message provides a unique ID field to connect
      /// published messages to the operation requested by this message.
      ///
      /// If there is already an active subscriber for an operation matching the provided ID, regardless of the
      /// operation type, the server must close the socket immediately with the event
      /// `4409: Subscriber for <unique-operation-id> already exists.`
      ///
      /// The server needs only keep track of IDs for as long as the subscription is active.
      /// Once a client completes an operation, it is free to re-use that ID.
      ///
      /// Executing operations is allowed only after the server has acknowledged the connection through the
      /// ConnectionAck message, if the connection is not acknowledged, the socket will be closed immediately with the
      /// event `4401: Unauthorized.`
      case subscribe(id: OperationID, payload: SubscribePayload)

      /// Indicates that the client has stopped listening and wants to complete the subscription.
      /// No further events, relevant to the original subscription, should be sent through.
      /// Even if the client completed a subscription before it was acknowledged by the server
      /// through the `Next`/`Error` message, the server should NOT continue sending those messages.
      case complete(id: OperationID)
    }

    enum Incoming {
      ///Expected response to the ConnectionInit message from the client acknowledging a successful connection with
      ///the server.
      ///
      ///The server can use the optional payload field to transfer additional details about the connection.
      ///
      ///The client is now ready to request subscription operations.
      case connectionAck(payload: JSONObject?)

      /// Useful for detecting failed connections, displaying latency metrics or other types of network probing.
      ///
      /// A Pong must be sent in response from the receiving party as soon as possible.
      ///
      /// The Ping message can be sent at any time within the established socket.
      ///
      /// The optional payload field can be used to transfer additional details about the ping.
      case ping(payload: JSONObject?)

      /// The response to the Ping message. Must be sent as soon as the Ping message is received.
      ///
      /// The Pong message can be sent at any time within the established socket.
      /// Furthermore, the Pong message may even be sent unsolicited as an unidirectional heartbeat.
      ///
      /// The optional payload field can be used to transfer additional details about the pong.
      case pong(payload: JSONObject?)

      /// Operation execution result(s) from the source stream created by the binding Subscribe message.
      /// After all results have been emitted, the Complete message will follow indicating stream completion.
      case next(id: OperationID, payload: JSONObject)

      /// Operation execution error(s) in response to the Subscribe message.
      /// This can occur before execution starts, usually due to validation errors, or during the execution of the
      /// request. This message terminates the operation and no further messages will be sent.
      case error(id: OperationID, payload: [GraphQLError])

      /// Indicates that the requested subscription execution has completed. If the server dispatched
      /// the `Error` message relative to the original `Subscribe` message, no `Complete` message will be emitted.
      case complete(id: OperationID)
    }

  }

  struct SubscribePayload {
    let operationName: String?
    let query: String
    let variables: GraphQLOperation.Variables?
    let extensions: JSONObject?

    var jsonPayload: JSONObject {
      var payload: JSONObject = [
        "query": query
      ]

      if let operationName {
        payload["operationName"] = operationName
      }

      if let variables {
        payload["variables"] = variables._jsonEncodableObject._jsonValue
      }

      if let extensions {
        payload["extensions"] = extensions as JSONValue
      }
      return payload
    }
  }

}

// MARK: - Message Serialization

extension WebSocketTransport.Message.Outgoing {

  // For best performance, raw strings for messages are inlined. This avoids needing to serialize more JSON than is
  // absolutely necessary (for arbitrary payloads).
  func toWebSocketMessage() throws -> URLSessionWebSocketTask.Message {
    var data: Data
    switch self {
    case .connectionInit(let payload):
      data = Data(#"{"type":"connection_init""#.utf8)
      if let payload {
        data.append(contentsOf: #","payload":"#.utf8)
        data.append(try JSONSerializationFormat.serialize(value: payload))
      }
      data.append(UInt8(ascii: "}"))

    case .ping(let payload):
      data = Data(#"{"type":"ping""#.utf8)
      if let payload {
        data.append(contentsOf: #","payload":"#.utf8)
        data.append(try JSONSerializationFormat.serialize(value: payload))
      }
      data.append(UInt8(ascii: "}"))

    case .pong(let payload):
      data = Data(#"{"type":"pong""#.utf8)
      if let payload {
        data.append(contentsOf: #","payload":"#.utf8)
        data.append(try JSONSerializationFormat.serialize(value: payload))
      }
      data.append(UInt8(ascii: "}"))

    case .subscribe(let id, let payload):
      data = Data(#"{"type":"subscribe","id":""#.utf8)
      data.append(contentsOf: "\(id)".utf8)
      data.append(contentsOf: #"","payload":"#.utf8)
      data.append(try JSONSerializationFormat.serialize(value: payload.jsonPayload))
      data.append(UInt8(ascii: "}"))

    case .complete(let id):
      data = Data(#"{"type":"complete","id":""#.utf8)
      data.append(contentsOf: "\(id)".utf8)
      data.append(contentsOf: #""}"#.utf8)
    }

    return .data(data)
  }

}

extension WebSocketTransport.Message.Incoming {
  var type: StaticString {
    switch self {
    case .connectionAck: return "connection_ack"
    case .ping: return "ping"
    case .pong: return "pong"
    case .next: return "next"
    case .error: return "error"
    case .complete: return "complete"
    }
  }
}

// MARK: - Message Deserialization

extension WebSocketTransport.Message.Incoming {

  static func from(_ webSocketMessage: URLSessionWebSocketTask.Message) throws -> Self {
    let data: Data
    switch webSocketMessage {
    case .string(let string):
      data = Data(string.utf8)
    case .data(let d):
      data = d
    @unknown default:
      throw WebSocketTransport.Error.unrecognizedMessage
    }

    let json: JSONObject = try JSONSerializationFormat.deserialize(data: data)

    guard let type = json["type"] as? String else {
      throw WebSocketTransport.Error.unrecognizedMessage
    }

    switch type {
    case "connection_ack":
      return .connectionAck(payload: json["payload"] as? JSONObject)

    case "ping":
      return .ping(payload: json["payload"] as? JSONObject)

    case "pong":
      return .pong(payload: json["payload"] as? JSONObject)

    case "next":
      guard
        let idValue = json["id"],
        let id = Self.parseOperationID(idValue)
      else {
        throw WebSocketTransport.Error.unrecognizedMessage
      }
      guard let payload = json["payload"] as? JSONObject else {
        throw WebSocketTransport.Error.unrecognizedMessage
      }
      return .next(id: id, payload: payload)

    case "error":
      guard
        let idValue = json["id"],
        let id = Self.parseOperationID(idValue)
      else {
        throw WebSocketTransport.Error.unrecognizedMessage
      }
      let errorObjects = (json["payload"] as? [JSONObject]) ?? []
      return .error(id: id, payload: errorObjects.map { GraphQLError($0) })

    case "complete":
      guard
        let idValue = json["id"],
        let id = Self.parseOperationID(idValue)
      else {
        throw WebSocketTransport.Error.unrecognizedMessage
      }
      return .complete(id: id)

    default:
      throw WebSocketTransport.Error.unrecognizedMessage
    }
  }

  /// Parses an operation ID from a JSON value.
  ///
  /// The `graphql-transport-ws` protocol transmits IDs as strings, but our internal representation
  /// uses `Int`. This handles both string and numeric JSON values.
  private static func parseOperationID(_ value: Any) -> WebSocketTransport.OperationID? {
    if let stringID = value as? String {
      return Int(stringID)
    }
    if let intID = value as? Int {
      return intID
    }
    return nil
  }
}

import Starscream
import Foundation

// MARK: - Client protocol

/// Protocol allowing alternative implementations of web sockets beyond `ApolloWebSocket`. Extends `Starscream`'s `WebSocketClient` protocol.
public protocol ApolloWebSocketClient: WebSocketClient {

  /// Required initializer
  ///
  /// - Parameter request: The URLRequest to use on connection.
  /// - Parameter protocols: The supported protocols
  init(request: URLRequest, protocols: [String]?)

  /// The URLRequest used on connection.
  var request: URLRequest { get set }

  /// Queue where the callbacks are executed
  var callbackQueue: DispatchQueue { get set }
}

// MARK: - WebSocket

/// Included implementation of an `ApolloWebSocketClient`, based on `Starscream`'s `WebSocket`.
public class ApolloWebSocket: WebSocket, ApolloWebSocketClient {
  required public convenience init(request: URLRequest, protocols: [String]? = nil) {
    self.init(request: request,
              protocols: protocols,
              stream: FoundationStream())
  }
}

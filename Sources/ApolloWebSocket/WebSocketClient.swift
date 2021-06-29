import Foundation

// MARK: - Client protocol

/// Protocol allowing alternative implementations of websockets beyond `ApolloWebSocket`.
public protocol WebSocketClient: AnyObject {
  
  /// The URLRequest used on connection.
  var request: URLRequest { get set }

  /// The delegate that will receive networking event updates for this websocket client.
  var delegate: WebSocketClientDelegate? { get set }

  /// `DispatchQueue` where the websocket client should call all delegate callbacks.
  var callbackQueue: DispatchQueue { get set }

  /// Connects to the websocket server.
  ///
  /// - Note: This should be implemented to connect the websocket on a background thread.
  func connect()

  /// Disconnects from the websocket server.
  func disconnect()

  /// Writes ping data to the websocket.
  func write(ping: Data, completion: (() -> Void)?)

  /// Writes a string to the websocket.
  func write(string: String)

}

// TODO: Document
public protocol WebSocketClientDelegate: AnyObject {
  func websocketDidConnect(socket: WebSocketClient)
  func websocketDidDisconnect(socket: WebSocketClient, error: Error?)
  func websocketDidReceiveMessage(socket: WebSocketClient, text: String)
  func websocketDidReceiveData(socket: WebSocketClient, data: Data)
}

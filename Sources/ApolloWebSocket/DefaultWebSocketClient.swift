import Starscream
import Foundation

/// Included default implementation of a `WebSocketClient`, based on `Starscream`'s `WebSocket`.
public class DefaultWebSocket: WebSocketClient, Starscream.WebSocketDelegate  {

  /// The websocket protocols supported by this websocket client implementation.
  static private let wsProtocols = ["graphql-ws"]

  /// The underlying `Starscream` websocket used by this websocket client.
  private let underlyingWebsocket: Starscream.WebSocket

  public var request: URLRequest {
    get { underlyingWebsocket.request }
    set { underlyingWebsocket.request = newValue }
  }

  public weak var delegate: WebSocketClientDelegate?

  public var callbackQueue: DispatchQueue {
    get { underlyingWebsocket.callbackQueue }
    set { underlyingWebsocket.callbackQueue = newValue }
  }

  /// Required initializer
  ///
  /// - Parameters:
  ///   - request: The URLRequest to use on connection.
  ///   - certPinner: [optional] The object providing information about certificate pinning. Should default to Starscream's `FoundationSecurity`.
  ///   - compressionHandler: [optional] The object helping with any compression handling. Should default to nil.
  required public init(request: URLRequest) {
    self.underlyingWebsocket = Starscream.WebSocket(
      request: request,
      protocols: Self.wsProtocols,
      stream: FoundationStream())
    self.underlyingWebsocket.delegate = self
  }

  public func connect() {
    self.underlyingWebsocket.connect()
  }

  public func disconnect() {
    self.underlyingWebsocket.disconnect()
  }

  public func write(ping: Data, completion: (() -> Void)?) {
    self.underlyingWebsocket.write(ping: ping, completion: completion)
  }

  public func write(string: String) {
    self.underlyingWebsocket.write(string: string)
  }

  public func websocketDidConnect(socket: Starscream.WebSocketClient) {
    self.delegate?.websocketDidConnect(socket: self)
  }

  public func websocketDidDisconnect(socket: Starscream.WebSocketClient, error: Error?) {
    self.delegate?.websocketDidDisconnect(socket: self, error: error)
  }

  public func websocketDidReceiveMessage(socket: Starscream.WebSocketClient, text: String) {
    self.delegate?.websocketDidReceiveMessage(socket: self, text: text)
  }

  public func websocketDidReceiveData(socket: Starscream.WebSocketClient, data: Data) {
    self.delegate?.websocketDidReceiveData(socket: self, data: data)
  }
}

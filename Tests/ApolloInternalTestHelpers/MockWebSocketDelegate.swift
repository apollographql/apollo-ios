import Foundation
@testable import ApolloWebSocket

public class MockWebSocketDelegate: WebSocketClientDelegate {
  public var didReceiveMessage: ((String) -> Void)?

  public init() {}

  public func websocketDidConnect(socket: WebSocketClient) {}

  public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {}

  public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    didReceiveMessage?(text)
  }

  public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {}
}

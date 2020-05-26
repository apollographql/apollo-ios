import XCTest
import Apollo
import Starscream
@testable import ApolloWebSocket

class WebSocketTransportTests: XCTestCase {

  private let mockSocketURL = URL(string: "http://localhost/dummy_url")!
  private var webSocketTransport: WebSocketTransport!

  func testUpdateHeaderValues() {
    var request = URLRequest(url: mockSocketURL)
    request.addValue("OldToken", forHTTPHeaderField: "Authorization")

    self.webSocketTransport = WebSocketTransport(request: request)

    self.webSocketTransport.updateHeaderValues(["Authorization": "UpdatedToken"])

    XCTAssertEqual(self.webSocketTransport.websocket.request.allHTTPHeaderFields?["Authorization"], "UpdatedToken")
  }

  func testUpdateConnectingPayload() {
    WebSocketTransport.provider = MockWebSocket.self

    self.webSocketTransport = WebSocketTransport(request: URLRequest(url: mockSocketURL),
                                                 connectingPayload: ["Authorization": "OldToken"])

    let mockWebSocketDelegate = MockWebSocketDelegate()

    let mockWebSocket = self.webSocketTransport.websocket as? MockWebSocket
    mockWebSocket?.isConnected = true
    mockWebSocket?.delegate = mockWebSocketDelegate

    let exp = expectation(description: "Waiting for reconnect")

    mockWebSocketDelegate.didReceiveMessage = { message in
      let json = try? JSONSerializationFormat.deserialize(data: message.data(using: .utf8)!) as? JSONObject
      guard let payload = json?["payload"] as? JSONObject, (json?["type"] as? String) == "connection_init" else {
        return
      }

      XCTAssertEqual(payload["Authorization"] as? String, "UpdatedToken")
      exp.fulfill()
    }

    self.webSocketTransport.updateConnectingPayload(["Authorization": "UpdatedToken"])
    self.webSocketTransport.initServer()

    waitForExpectations(timeout: 3, handler: nil)
  }
}

private final class MockWebSocketDelegate: WebSocketDelegate {

  var didReceiveMessage: ((String) -> Void)?

  func websocketDidConnect(socket: WebSocketClient) { }

  func websocketDidDisconnect(socket: WebSocketClient, error: Error?) { }

  func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    didReceiveMessage?(text)
  }

  func websocketDidReceiveData(socket: WebSocketClient, data: Data) { }
}

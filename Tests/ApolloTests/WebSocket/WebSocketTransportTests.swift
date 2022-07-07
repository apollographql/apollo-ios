import XCTest
import Apollo
import ApolloTestSupport
@testable import ApolloWebSocket

class WebSocketTransportTests: XCTestCase {

  private var webSocketTransport: WebSocketTransport!

  override func tearDown() {
    webSocketTransport = nil
    
    super.tearDown()
  }

  func testUpdateHeaderValues() {
    var request = URLRequest(url: TestURL.mockServer.url)
    request.addValue("OldToken", forHTTPHeaderField: "Authorization")

    self.webSocketTransport = WebSocketTransport(
      websocket: MockWebSocket(request: request, protocol: .graphql_ws),
      store: ApolloStore()
    )

    self.webSocketTransport.updateHeaderValues(["Authorization": "UpdatedToken"])

    XCTAssertEqual(self.webSocketTransport.websocket.request.allHTTPHeaderFields?["Authorization"], "UpdatedToken")
  }

  func testUpdateConnectingPayload() {
    let request = URLRequest(url: TestURL.mockServer.url)

    self.webSocketTransport = WebSocketTransport(
      websocket: MockWebSocket(request: request, protocol: .graphql_ws),
      store: ApolloStore(),
      connectingPayload: ["Authorization": "OldToken"]
    )

    let mockWebSocketDelegate = MockWebSocketDelegate()

    let mockWebSocket = self.webSocketTransport.websocket as? MockWebSocket
    self.webSocketTransport.socketConnectionState.mutate { $0 = .connected }
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

  func testCloseConnectionAndInit() {
    let request = URLRequest(url: TestURL.mockServer.url)

    self.webSocketTransport = WebSocketTransport(
      websocket: MockWebSocket(request: request, protocol: .graphql_ws),
      store: ApolloStore(),
      connectingPayload: ["Authorization": "OldToken"]
    )
    self.webSocketTransport.closeConnection()
    self.webSocketTransport.updateConnectingPayload(["Authorization": "UpdatedToken"])
    self.webSocketTransport.initServer()

    let exp = expectation(description: "Wait")
    let result = XCTWaiter.wait(for: [exp], timeout: 1.0)
    if result == XCTWaiter.Result.timedOut {
    } else {
      XCTFail("Delay interrupted")
    }
  }
}

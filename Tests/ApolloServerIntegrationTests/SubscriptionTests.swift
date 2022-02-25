import XCTest
import Apollo
import SubscriptionAPI
import ApolloWebSocket
import SQLite
import Nimble

class SubscriptionTests: XCTestCase {
  enum Connection: Equatable {
    case disconnected
    case connected
  }

  var connectionState: Connection = .disconnected
  var resultNumber: Int? = nil

  func test_subscribe_givenSubscription_shouldReceiveSuccessResult_andCancelSubscription() {
    // given
    let store = ApolloStore()
    let webSocketTransport = WebSocketTransport(
      websocket: WebSocket(url: TestServerURL.subscriptionWebSocket.url, protocol: .graphql_transport_ws),
      store: store
    )
    webSocketTransport.delegate = self
    let client = ApolloClient(networkTransport: webSocketTransport, store: store)

    expect(self.connectionState).toEventually(equal(Connection.connected), timeout: .seconds(1))

    // when
    let subject = client.subscribe(subscription: IncrementingSubscription()) { result in
      switch result {
      case let .failure(error):
        XCTFail("Expected .success, got \(error.localizedDescription)")

      case let .success(graphqlResult):
        expect(graphqlResult.errors).to(beNil())
        self.resultNumber = graphqlResult.data?.numberIncremented
      }
    }

    // then
    expect(self.resultNumber).toEventuallyNot(beNil(), timeout: .seconds(2))

    subject.cancel()
    webSocketTransport.closeConnection()
    expect(self.connectionState).toEventually(equal(.disconnected), timeout: .seconds(2))
  }
}

extension SubscriptionTests: WebSocketTransportDelegate {
  func webSocketTransportDidConnect(_ webSocketTransport: WebSocketTransport) {
    connectionState = .connected
  }

  func webSocketTransport(_ webSocketTransport: WebSocketTransport, didDisconnectWithError error:Error?) {
    connectionState = .disconnected
  }
}

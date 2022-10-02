import XCTest
@testable import ApolloWebSocket
import ApolloInternalTestHelpers
import Nimble
import Apollo
// import SubscriptionAPI
#warning("When SubscriptionAPI target is regenerated and compiles then decide what to do here")

class GraphqlWsProtocolTests: WSProtocolTestsBase {

  let `protocol` = "graphql-ws"

  override var urlRequest: URLRequest {
    var request = URLRequest(url: TestURL.mockServer.url)
    request.setValue(`protocol`, forHTTPHeaderField: "Sec-WebSocket-Protocol")

    return request
  }

  private func buildWebSocket() {
    buildWebSocket(protocol: .graphql_ws)
  }

  // MARK: Initializer Tests

  func test__designatedInitializer__shouldSetRequestProtocolHeader() {
    expect(
      WebSocket(
        request: URLRequest(url: TestURL.mockServer.url),
        protocol: .graphql_ws
      ).request.value(forHTTPHeaderField: "Sec-WebSocket-Protocol")
    ).to(equal(`protocol`))
  }

  func test__convenienceInitializers__shouldSetRequestProtocolHeader() {
    expect(
      WebSocket(
        url: TestURL.mockServer.url,
        protocol: .graphql_ws
      ).request.value(forHTTPHeaderField: "Sec-WebSocket-Protocol")
    ).to(equal(`protocol`))

    expect(
      WebSocket(
        url: TestURL.mockServer.url,
        writeQueueQOS: .default,
        protocol: .graphql_ws
      ).request.value(forHTTPHeaderField: "Sec-WebSocket-Protocol")
    ).to(equal(`protocol`))
  }

  // MARK: Protocol Tests

  func test__messaging__givenDefaultConnectingPayload_whenWebSocketConnected_shouldSendConnectionInit() throws {
    // given
    buildWebSocket()

    waitUntil { done in
      self.mockWebSocketDelegate.didReceiveMessage = { message in
        // then
        expect(message).to(equalMessage(payload: [:], type: .connectionInit))
        done()
      }

      // when
      self.websocketTransport.websocketDidConnect(socket: self.mockWebSocket)
    }
  }

  func test__messaging__givenNilConnectingPayload_whenWebSocketConnected_shouldSendConnectionInit() throws {
    buildWebSocket()

    // given
    websocketTransport = WebSocketTransport(
      websocket: mockWebSocket,
      config: .init(connectingPayload: nil)
    )

    waitUntil { done in
      self.mockWebSocketDelegate.didReceiveMessage = { message in
        // then
        expect(message).to(equalMessage(type: .connectionInit))
        done()
      }

      // when
      self.websocketTransport.websocketDidConnect(socket: self.mockWebSocket)
    }
  }

  func test__messaging__givenConnectingPayload_whenWebSocketConnected_shouldSendConnectionInit() throws {
    buildWebSocket()

    // given
     websocketTransport = WebSocketTransport(
      websocket: mockWebSocket,
      config: .init(connectingPayload: ["sample": "data"])
    )

    waitUntil { done in
      self.mockWebSocketDelegate.didReceiveMessage = { message in
        // then
        expect(message).to(equalMessage(payload: ["sample": "data"], type: .connectionInit))
        done()
      }

      // when
      self.websocketTransport.websocketDidConnect(socket: self.mockWebSocket)
    }
  }

//  func test__messaging__givenSubscriptionSubscribe_shouldSendStart() {
//    // given
//    buildWebSocket()
//    buildClient()
//
//    connectWebSocket()
//    ackConnection()
//
//    let operation = IncrementingSubscription()
//
//    waitUntil { done in
//      self.mockWebSocketDelegate.didReceiveMessage = { message in
//        // then
//        expect(message).to(equalMessage(payload: operation.requestBody, id: "1", type: .start))
//        done()
//      }
//
//      // when
//      self.client.subscribe(subscription: operation) { _ in }
//    }
//  }

//  func test__messaging__givenSubscriptionCancel_shouldSendStop() {
//    // given
//    buildWebSocket()
//    buildClient()
//
//    connectWebSocket()
//    ackConnection()
//
//    let subject = client.subscribe(subscription: IncrementingSubscription()) { _ in }
//
//    waitUntil { done in
//      self.mockWebSocketDelegate.didReceiveMessage = { message in
//        // then
//        let expected = OperationMessage(id: "1", type: .stop).rawMessage!
//        if message == expected {
//          done()
//        }
//      }
//
//      // when
//      subject.cancel()
//    }
//  }

  func test__messaging__whenWebSocketClosed_shouldSendConnectionTerminate() throws {
    // given
    buildWebSocket()

    connectWebSocket()
    ackConnection()

    waitUntil { done in
      self.mockWebSocketDelegate.didReceiveMessage = { message in
        // then
        expect(message).to(equalMessage(type: .connectionTerminate))
        done()
      }

      // when
      self.websocketTransport.closeConnection()
    }
  }

//  func test__messaging__whenReceivesData_shouldParseMessage() throws {
//    // given
//    buildWebSocket()
//    buildClient()
//
//    connectWebSocket()
//    ackConnection()
//
//    let operation = IncrementingSubscription()
//
//    waitUntil { done in
//      // when
//      self.client.subscribe(subscription: operation) { result in
//        switch result {
//        case let .failure(error):
//          fail("Expected .success, got error: \(error.localizedDescription)")
//
//        case let .success(graphqlResult):
//          expect(graphqlResult.data?.numberIncremented).to(equal(42))
//          done()
//        }
//      }
//
//      self.sendAsync(message: OperationMessage(
//        payload: ["data": ["numberIncremented": 42]],
//        id: "1",
//        type: .data
//      ))
//    }
//  }
}

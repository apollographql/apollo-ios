import XCTest
@testable import ApolloWebSocket
import ApolloTestSupport
import Nimble
import Apollo
import SubscriptionAPI

class GraphqlTransportWsProtocolTests: XCTestCase {
  private let asyncTimeout: DispatchTimeInterval = .seconds(3)

  private var store: ApolloStore!
  private var mockWebSocket: MockWebSocket!
  private var websocketTransport: WebSocketTransport! {
    didSet {
      if let websocketTransport = websocketTransport { // caters for tearDown setting nil value
        websocketTransport.websocket.delegate = mockWebSocketDelegate
      }
    }
  }
  private var mockWebSocketDelegate: MockWebSocketDelegate!
  private var client: ApolloClient!

  override func setUp() {
    super.setUp()

    store = ApolloStore()
  }

  override func tearDown() {
    client = nil
    websocketTransport = nil
    mockWebSocket = nil
    mockWebSocketDelegate = nil
    store = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildWebSocket() {
    var request = URLRequest(url: TestURL.mockServer.url)
    request.setValue("graphql-transport-ws", forHTTPHeaderField: "Sec-WebSocket-Protocol")

    mockWebSocketDelegate = MockWebSocketDelegate()
    mockWebSocket = MockWebSocket(request: request)
    websocketTransport = WebSocketTransport(websocket: mockWebSocket, store: store)
  }

  private func buildClient() {
    client = ApolloClient(networkTransport: websocketTransport, store: store)
  }

  private func connectWebSocket() {
    websocketTransport.socketConnectionState.mutate { $0 = .connected }
  }

  private func ackConnection() {
    let ackMessage = OperationMessage(type: .connectionAck).rawMessage!
    websocketTransport.websocketDidReceiveMessage(socket: mockWebSocket, text: ackMessage)
  }

  // MARK: Initializer Tests

  func test__designatedInitializer__shouldSetRequestProtocolHeader() {
    expect(
      WebSocket(
        request: URLRequest(url: TestURL.mockServer.url),
        webSocketProtocol: .graphql_transport_ws
      ).request.value(forHTTPHeaderField: "Sec-WebSocket-Protocol")
    ).to(equal("graphql-transport-ws"))
  }

  func test__convenienceInitializers__shouldSetRequestProtocolHeader() {
    expect(
      WebSocket(
        url: TestURL.mockServer.url,
        webSocketProtocol: .graphql_transport_ws
      ).request.value(forHTTPHeaderField: "Sec-WebSocket-Protocol")
    ).to(equal("graphql-transport-ws"))

    expect(
      WebSocket(
        url: TestURL.mockServer.url,
        writeQueueQOS: .default,
        webSocketProtocol: .graphql_transport_ws
      ).request.value(forHTTPHeaderField: "Sec-WebSocket-Protocol")
    ).to(equal("graphql-transport-ws"))
  }

  // MARK: Protocol Tests

  func test__messaging__givenDefaultConnectingPayload_whenWebSocketConnected_shouldSendConnectionInit() throws {
    // given
    buildWebSocket()

    waitUntil(timeout: asyncTimeout) { done in
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
    websocketTransport = WebSocketTransport(websocket: mockWebSocket, connectingPayload: nil)

    waitUntil(timeout: asyncTimeout) { done in
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
      connectingPayload: ["sample": "data"]
    )

    waitUntil(timeout: asyncTimeout) { done in
      self.mockWebSocketDelegate.didReceiveMessage = { message in
        // then
        expect(message).to(equalMessage(payload: ["sample": "data"], type: .connectionInit))
        done()
      }

      // when
      self.websocketTransport.websocketDidConnect(socket: self.mockWebSocket)
    }
  }

  func test__messaging__givenSubscriptionSubscribe_shouldSendSubscribe() {
    // given
    buildWebSocket()
    buildClient()

    connectWebSocket()
    ackConnection()

    let operation = IncrementingSubscription()

    waitUntil(timeout: asyncTimeout) { done in
      self.mockWebSocketDelegate.didReceiveMessage = { message in
        // then
        expect(message).to(equalMessage(payload: operation.requestBody, id: "1", type: .subscribe))
        done()
      }

      // when
      self.client.subscribe(subscription: operation) { _ in }
    }
  }

  func test__messaging__givenSubscriptionCancel_shouldSendStop() {
    // given
    buildWebSocket()
    buildClient()

    connectWebSocket()
    ackConnection()

    let subject = client.subscribe(subscription: IncrementingSubscription()) { _ in }

    waitUntil(timeout: asyncTimeout) { done in
      self.mockWebSocketDelegate.didReceiveMessage = { message in
        // then
        let expected = OperationMessage(id: "1", type: .stop).rawMessage!
        if message == expected {
          done()
        }
      }

      // when
      subject.cancel()
    }
  }

  func test__messaging__whenWebSocketClosed_shouldSendConnectionTerminate() throws {
    // given
    buildWebSocket()

    connectWebSocket()
    ackConnection()

    waitUntil(timeout: asyncTimeout) { done in
      self.mockWebSocketDelegate.didReceiveMessage = { message in
        // then
        expect(message).to(equalMessage(type: .connectionTerminate))
        done()
      }

      // when
      self.websocketTransport.closeConnection()
    }
  }

  func test__messaging__whenReceivesNext_shouldParseMessage() throws {
    // given
    buildWebSocket()
    buildClient()

    connectWebSocket()
    ackConnection()

    let operation = IncrementingSubscription()

    waitUntil(timeout: asyncTimeout) { done in
      // when
      self.client.subscribe(subscription: operation) { result in
        switch result {
        case let .failure(error):
          fail("Expected .success, got error: \(error.localizedDescription)")

        case let .success(graphqlResult):
          expect(graphqlResult.data?.numberIncremented).to(equal(42))
          done()
        }
      }

      let message = OperationMessage(
        payload: ["data": ["numberIncremented": 42]],
        id: "1",
        type: .next
      ).rawMessage!
      self.websocketTransport.websocketDidReceiveMessage(socket: self.mockWebSocket, text: message)
    }
  }

  func test__messaging__whenReceivesPing_shouldSendPong() throws {
    // given
    buildWebSocket()
    buildClient()

    connectWebSocket()
    ackConnection()

    waitUntil(timeout: asyncTimeout) { done in
      self.mockWebSocketDelegate.didReceiveMessage = { message in
        // then
        expect(message).to(equalMessage(type: .pong))
        done()
      }

      // when
      let message = OperationMessage(payload: ["sample": "data"], type: .ping).rawMessage!
      self.websocketTransport.websocketDidReceiveMessage(socket: self.mockWebSocket, text: message)
    }
  }
}

private extension GraphQLOperation {
  var requestBody: GraphQLMap {
    ApolloRequestBodyCreator().requestBody(
      for: self,
      sendOperationIdentifiers: false,
      sendQueryDocument: true,
      autoPersistQuery: false
    )
  }
}

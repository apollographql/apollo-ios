import XCTest
@testable import ApolloWebSocket
import ApolloInternalTestHelpers
import Nimble
import Apollo
import ApolloAPI
// import SubscriptionAPI
#warning("When SubscriptionAPI target is regenerated and compiles then decide what to do here")

class WSProtocolTestsBase: XCTestCase {
  private var store: ApolloStore!
  var mockWebSocket: MockWebSocket!
  var websocketTransport: WebSocketTransport! {
    didSet {
      if let websocketTransport = websocketTransport { // caters for tearDown setting nil value
        websocketTransport.websocket.delegate = mockWebSocketDelegate
      }
    }
  }
  var mockWebSocketDelegate: MockWebSocketDelegate!
  var client: ApolloClient!

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

  var urlRequest: URLRequest {
    fatalError("Subclasses must override this property!")
  }

  func buildWebSocket() {
    mockWebSocketDelegate = MockWebSocketDelegate()
    mockWebSocket = MockWebSocket(request: urlRequest)
    websocketTransport = WebSocketTransport(websocket: mockWebSocket, store: store)
  }

  func buildClient() {
    client = ApolloClient(networkTransport: websocketTransport, store: store)
  }

  func connectWebSocket() {
    websocketTransport.socketConnectionState.mutate { $0 = .connected }
  }

  func ackConnection() {
    let ackMessage = OperationMessage(type: .connectionAck).rawMessage!
    websocketTransport.websocketDidReceiveMessage(socket: mockWebSocket, text: ackMessage)
  }

  func sendAsync(message: OperationMessage) {
    websocketTransport.processingQueue.async {
      self.websocketTransport.websocketDidReceiveMessage(
        socket: self.mockWebSocket,
        text: message.rawMessage!
      )
    }
  }
}

extension GraphQLOperation {
  var requestBody: JSONEncodableDictionary {
    ApolloRequestBodyCreator().requestBody(
      for: self,
      sendQueryDocument: true,
      autoPersistQuery: false
    )
  }
}

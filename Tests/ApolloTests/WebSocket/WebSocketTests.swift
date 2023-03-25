import XCTest
import Nimble
import Apollo
import ApolloAPI
import ApolloInternalTestHelpers
@testable import ApolloWebSocket

extension WebSocketTransport {
  func write(message: JSONEncodableDictionary) {
    let serialized = try! JSONSerializationFormat.serialize(value: message)
    if let str = String(data: serialized, encoding: .utf8) {
      self.websocket.write(string: str)
    }
  }
}

class WebSocketTests: XCTestCase {
  var networkTransport: WebSocketTransport!
  var client: ApolloClient!
  var websocket: MockWebSocket!
  
  struct CustomOperationMessageIdCreator: OperationMessageIdCreator {
    func requestId() -> String {
      return "12345678"
    }
  }

  class ReviewAddedData: MockSelectionSet {
    override class var __selections: [Selection] { [
      .field("reviewAdded", ReviewAdded.self),
    ]}

    class ReviewAdded: MockSelectionSet {
      override class var __selections: [Selection] { [
        .field("__typename", String.self),
        .field("stars", Int.self),
        .field("commentary", String?.self),
      ] }
    }
  }
  
  override func setUp() {
    super.setUp()

    let store = ApolloStore.mock()
    let websocket = MockWebSocket(
      request:URLRequest(url: TestURL.mockServer.url),
      protocol: .graphql_ws
    )
    networkTransport = WebSocketTransport(websocket: websocket, store: store)
    client = ApolloClient(networkTransport: networkTransport!, store: store)
  }
    
  override func tearDown() {
    networkTransport = nil
    client = nil
    websocket = nil
    
    super.tearDown()
  }
    
  func testLocalSingleSubscription() throws {
    let expectation = self.expectation(description: "Single subscription")
    
    let subject = client.subscribe(
      subscription: MockSubscription<ReviewAddedData>()
    ) { result in
      defer { expectation.fulfill() }
      switch result {
      case .success(let graphQLResult):
        expect(graphQLResult.data?.reviewAdded?.stars).to(equal(5))

      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
    }
        
    let message : JSONEncodableDictionary = [
      "type": "data",
      "id": "1",
      "payload": [
        "data": [
          "reviewAdded": [
            "__typename": "ReviewAdded",
            "episode": "JEDI",
            "stars": 5,
            "commentary": "A great movie"
          ]
        ]
      ]
    ]
        
    networkTransport.write(message: message)
        
    waitForExpectations(timeout: 5, handler: nil)

    subject.cancel()
  }
  
  func testLocalMissingSubscription() throws {
    let expectation = self.expectation(description: "Missing subscription")
    expectation.isInverted = true

    let subject = client.subscribe(subscription: MockSubscription<ReviewAddedData>()) { _ in
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 2, handler: nil)

    subject.cancel()
  }
  
  func testLocalErrorUnknownId() throws {
    let expectation = self.expectation(description: "Unknown id for subscription")
    
    let subject = client.subscribe(subscription: MockSubscription<ReviewAddedData>()) { result in
      defer { expectation.fulfill() }
      
      switch result {
      case .success:
        XCTFail("This should have caused an error!")
      case .failure(let error):
        if let webSocketError = error as? WebSocketError {
          switch webSocketError.kind {
          case .unprocessedMessage:
            // Correct!
            break
          default:
            XCTFail("Unexpected websocket error: \(error)")
          }
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
    
    let message : JSONEncodableDictionary = [
      "type": "data",
      "id": "2",            // subscribing on id = 1, i.e. expecting error when receiving id = 2
      "payload": [
        "data": [
          "reviewAdded": [
            "__typename": "ReviewAdded",
            "episode": "JEDI",
            "stars": 5,
            "commentary": "A great movie"
          ]
        ]
      ]
    ]
    
    networkTransport.write(message: message)
    
    waitForExpectations(timeout: 2, handler: nil)

    subject.cancel()
  }
  
  func testSingleSubscriptionWithCustomOperationMessageIdCreator() throws {
    let expectation = self.expectation(description: "Single Subscription with Custom Operation Message Id Creator")
    
    let store = ApolloStore.mock()
    let websocket = MockWebSocket(
      request:URLRequest(url: TestURL.mockServer.url),
      protocol: .graphql_ws
    )
    networkTransport = WebSocketTransport(
      websocket: websocket,
      store: store,
      config: .init(
        operationMessageIdCreator: CustomOperationMessageIdCreator()
      ))
    client = ApolloClient(networkTransport: networkTransport!, store: store)
    
    let subject = client.subscribe(subscription: MockSubscription<ReviewAddedData>()) { result in
      defer { expectation.fulfill() }
      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.data?.reviewAdded?.stars, 5)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
    }
    
    let message : JSONEncodableDictionary = [
      "type": "data",
      "id": "12345678", // subscribing on id = 12345678 from custom operation id
      "payload": [
        "data": [
          "reviewAdded": [
            "__typename": "ReviewAdded",
            "episode": "JEDI",
            "stars": 5,
            "commentary": "A great movie"
          ]
        ]
      ]
    ]
    
    networkTransport.write(message: message)
    
    waitForExpectations(timeout: 2, handler: nil)

    subject.cancel()
  }
}

import XCTest
import Apollo
@testable import ApolloWebSocket
import StarWarsAPI

extension WebSocketTransport {
  func write(message: GraphQLMap) {
    let serialized = try! JSONSerializationFormat.serialize(value: message)
    if let str = String(data: serialized, encoding: .utf8) {
      self.websocket.write(string: str)
    }
  }
}

class MockWebSocketTests: XCTestCase {
  var networkTransport: WebSocketTransport!
  var client: ApolloClient!
  
  override func setUp() {
    super.setUp()
  
    WebSocketTransport.provider = MockWebSocket.self
    networkTransport = WebSocketTransport(request: URLRequest(url: URL(string: "http://localhost/dummy_url")!))
    client = ApolloClient(networkTransport: networkTransport!)
  }
    
  override func tearDown() {
    super.tearDown()
    
    WebSocketTransport.provider = ApolloWebSocket.self
  }
    
  func testLocalSingleSubscription() throws {
    let expectation = self.expectation(description: "Single subscription")
    
    client.subscribe(subscription: ReviewAddedSubscription()) { result in
      defer { expectation.fulfill() }
      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.data?.reviewAdded?.stars, 5)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
    }
        
    let message : GraphQLMap = [
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
  }
  
  func testLocalMissingSubscription() throws {
    let expectation = self.expectation(description: "Missing subscription")
    expectation.isInverted = true

    client.subscribe(subscription: ReviewAddedSubscription()) { _ in
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 2, handler: nil)
  }
  
  func testLocalErrorUnknownId() throws {
    let expectation = self.expectation(description: "Unknown id for subscription")
    
    client.subscribe(subscription: ReviewAddedSubscription()) { result in
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
    
    let message : GraphQLMap = [
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
  }
}

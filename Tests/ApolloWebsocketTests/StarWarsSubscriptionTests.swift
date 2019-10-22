import XCTest
import Apollo
import ApolloTestSupport
@testable import ApolloWebSocket
import StarWarsAPI

class StarWarsSubscriptionTests: XCTestCase {
  let SERVER: String = "ws://localhost:8080/websocket"
  
  var client: ApolloClient!
  
  override func setUp() {
    super.setUp()
    
    let networkTransport = WebSocketTransport(request: URLRequest(url: URL(string: SERVER)!))
    client = ApolloClient(networkTransport: networkTransport)
  }
  
  // MARK: Subscriptions
  
  func testSubscribeReviewJediEpisode() {
    let expectation = self.expectation(description: "Subscribe single review")
    
    let sub = client.subscribe(subscription: ReviewAddedSubscription(episode: .jedi)) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success(let graphQLResult):
        XCTAssertNil(graphQLResult.errors)
        guard let data = graphQLResult.data else {
          XCTFail("No subscription result data")
          return
        }
        
        XCTAssertEqual(data.reviewAdded?.episode, .jedi)
        XCTAssertEqual(data.reviewAdded?.stars, 6)
        XCTAssertEqual(data.reviewAdded?.commentary, "This is the greatest movie!")
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
    }
    
    client.perform(mutation: CreateReviewForEpisodeMutation(episode: .jedi, review: ReviewInput(stars: 6, commentary: "This is the greatest movie!")))
    
    waitForExpectations(timeout: 10, handler: nil)
    sub.cancel()
  }
  
  func testSubscribeReviewAnyEpisode() {
    let expectation = self.expectation(description: "Subscribe any episode")
    
    let sub = client.subscribe(subscription: ReviewAddedSubscription()) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success(let graphQLResult):
        XCTAssertNil(graphQLResult.errors)
        guard let data = graphQLResult.data else {
          XCTFail("No subscription result data")
          return
        }
        
        XCTAssertEqual(data.reviewAdded?.stars, 13)
        XCTAssertEqual(data.reviewAdded?.commentary, "This is an even greater movie!")
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
    }
    
    client.perform(mutation: CreateReviewForEpisodeMutation(episode: .empire, review: ReviewInput(stars: 13, commentary: "This is an even greater movie!")))
    
    waitForExpectations(timeout: 2, handler: nil)
    sub.cancel()
  }
  
  func testSubscribeReviewDifferentEpisode() {
    let expectation = self.expectation(description: "Subscription to specific episode - expecting timeout")
    expectation.isInverted = true
    
    let sub = client.subscribe(subscription: ReviewAddedSubscription(episode: .jedi)) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success(let graphQLResult):
        XCTAssertNil(graphQLResult.errors)
        guard let data = graphQLResult.data else {
          XCTFail("No subscription result data")
          return
        }
        
        XCTAssertNotEqual(data.reviewAdded?.episode, .jedi)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
    }
    
    client.perform(mutation: CreateReviewForEpisodeMutation(episode: .empire, review: ReviewInput(stars: 10, commentary: "This is an even greater movie!")))
    
    waitForExpectations(timeout: 3, handler: nil)
    sub.cancel()
  }
  
  func testSubscribeThenCancel() {
    let expectation = self.expectation(description: "Subscription then cancel - expecting timeput")
    expectation.isInverted = true
    
    let sub = client.subscribe(subscription: ReviewAddedSubscription(episode: .jedi)) { _ in
      XCTFail("Received subscription after cancel")
    }
    
    sub.cancel()
    
    client.perform(mutation: CreateReviewForEpisodeMutation(episode: .jedi, review: ReviewInput(stars: 10, commentary: "This is an even greater movie!")))
    
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testSubscribeMultipleReviews() {
    let count = 50
    let expectation = self.expectation(description: "Multiple reviews")
    expectation.expectedFulfillmentCount = count

    let sub = client.subscribe(subscription: ReviewAddedSubscription(episode: .empire)) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success(let graphQLResult):
        XCTAssertNil(graphQLResult.errors)
        guard let data = graphQLResult.data else {
          XCTFail("No subscription result data")
          return
        }
        
        XCTAssertEqual(data.reviewAdded?.episode, .empire)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
    }

    for i in 1...count {
      let review = ReviewInput(stars: i, commentary: "The greatest movie ever!")
      _ = client.perform(mutation: CreateReviewForEpisodeMutation(episode: .empire, review: review))
    }

    waitForExpectations(timeout: 10, handler: nil)
    sub.cancel()
  }
  
  func testMultipleSubscriptions() {
    // Multiple subscriptions, one for any episode and one for each of the episode
    // We send count reviews and expect to receive twice that number of subscriptions
    
    let count = 20
    
    let expectation = self.expectation(description: "Multiple reviews")
    expectation.expectedFulfillmentCount = count * 2
    
    var allFulfilledCount = 0
    var newHopeFulfilledCount = 0
    var empireFulfilledCount = 0
    var jediFulfilledCount = 0
    
    let subAll = client.subscribe(subscription: ReviewAddedSubscription()) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertNil(graphQLResult.errors)
        XCTAssertNotNil(graphQLResult.data)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      
      expectation.fulfill()
      allFulfilledCount += 1
    }
    
    let subEmpire = client.subscribe(subscription: ReviewAddedSubscription(episode: .empire)) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertNil(graphQLResult.errors)
        XCTAssertNotNil(graphQLResult.data)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }

      expectation.fulfill()
      empireFulfilledCount += 1
    }
    
    let subJedi = client.subscribe(subscription: ReviewAddedSubscription(episode: .jedi)) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertNil(graphQLResult.errors)
        XCTAssertNotNil(graphQLResult.data)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }

      expectation.fulfill()
      jediFulfilledCount += 1
    }
    
    let subNewHope = client.subscribe(subscription: ReviewAddedSubscription(episode: .newhope)) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertNil(graphQLResult.errors)
        XCTAssertNotNil(graphQLResult.data)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }

      expectation.fulfill()
      newHopeFulfilledCount += 1
    }
    
    let episodes : [Episode] = [.empire, .jedi, .newhope]
    
    var selectedEpisodes = [Episode]()
    for i in 1...count {
      let review = ReviewInput(stars: i, commentary: "The greatest movie ever!")
      let episode = episodes.randomElement()!
      selectedEpisodes.append(episode)
      _ = client.perform(mutation: CreateReviewForEpisodeMutation(episode: episode, review: review))
    }
    
    waitForExpectations(timeout: 10, handler: nil)
    XCTAssertEqual(allFulfilledCount,
                   count,
                   "All not fulfilled proper number of times. Expected \(count), got \(allFulfilledCount)")
    let expectedNewHope = selectedEpisodes.filter { $0 == .newhope }.count
    XCTAssertEqual(newHopeFulfilledCount,
                   expectedNewHope,
                   "New Hope not fulfilled proper number of times. Expected \(expectedNewHope), got \(newHopeFulfilledCount)")
    let expectedEmpire = selectedEpisodes.filter { $0 == .empire }.count
    XCTAssertEqual(empireFulfilledCount,
                   expectedEmpire,
                   "Empire not fulfilled proper number of times. Expected \(expectedEmpire), got \(empireFulfilledCount)")
    let expectedJedi = selectedEpisodes.filter { $0 == .jedi }.count
    XCTAssertEqual(jediFulfilledCount,
                   expectedJedi,
                   "Jedi not fulfilled proper number of times. Expected \(expectedJedi), got \(jediFulfilledCount)")
    
    subAll.cancel()
    subEmpire.cancel()
    subJedi.cancel()
    subNewHope.cancel()
  }
}

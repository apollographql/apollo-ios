import XCTest
import Apollo
import ApolloInternalTestHelpers
@testable import ApolloWebSocket
import StarWarsAPI

class StarWarsSubscriptionTests: XCTestCase {
  var concurrentQueue: DispatchQueue!
  var client: ApolloClient!
  var webSocketTransport: WebSocketTransport!
  
  var connectionStartedExpectation: XCTestExpectation?
  var disconnectedExpectation: XCTestExpectation?
  var reconnectedExpectation: XCTestExpectation?
  
  override func setUp() {
    super.setUp()

    concurrentQueue = DispatchQueue(label: "com.apollographql.test.\(self.name)", attributes: .concurrent)

    connectionStartedExpectation = self.expectation(description: "Web socket connected")

    webSocketTransport = WebSocketTransport(
      websocket: WebSocket(
        request: URLRequest(url: TestServerURL.starWarsWebSocket.url),
        protocol: .graphql_ws
      ),
      store: ApolloStore()
    )
    webSocketTransport.delegate = self
    client = ApolloClient(networkTransport: webSocketTransport, store: ApolloStore())

    self.wait(for: [self.connectionStartedExpectation!], timeout: 5)
  }

  override func tearDownWithError() throws {
    client = nil
    webSocketTransport = nil
    connectionStartedExpectation = nil
    disconnectedExpectation = nil
    reconnectedExpectation = nil
    concurrentQueue = nil

    try super.tearDownWithError()
  }
  
  private func waitForSubscriptionsToStart(for delay: TimeInterval = 0.1, on queue: DispatchQueue = .main) {
    /// This method works around changes to the subscriptions package which mean that subscriptions do not start passing on data the absolute instant they are created.
    let waitExpectation = self.expectation(description: "Waited!")
    
    queue.asyncAfter(deadline: .now() + delay) {
      waitExpectation.fulfill()
    }
    
    self.wait(for: [waitExpectation], timeout: delay + 1)
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
    
    self.waitForSubscriptionsToStart()
        
    client.perform(mutation: CreateReviewForEpisodeMutation(
                    episode: .jedi,
                    review: ReviewInput(stars: 6, commentary: "This is the greatest movie!")))
    
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
    
    self.waitForSubscriptionsToStart()
    
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
    
    self.waitForSubscriptionsToStart()
    
    client.perform(mutation: CreateReviewForEpisodeMutation(episode: .empire, review: ReviewInput(stars: 10, commentary: "This is an even greater movie!")))
    
    waitForExpectations(timeout: 3, handler: nil)
    sub.cancel()
  }
  
  func testSubscribeThenCancel() {
    let expectation = self.expectation(description: "Subscription then cancel - expecting timeout")
    expectation.isInverted = true
    
    let sub = client.subscribe(subscription: ReviewAddedSubscription(episode: .jedi)) { _ in
      XCTFail("Received subscription after cancel")
    }
    
    self.waitForSubscriptionsToStart()
    
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
    
    self.waitForSubscriptionsToStart()

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
    
    self.waitForSubscriptionsToStart()
    
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
  
  // MARK: Data races tests
  
  func testConcurrentSubscribing() {
    let firstSubscription = ReviewAddedSubscription(episode: .empire)
    let secondSubscription = ReviewAddedSubscription(episode: .empire)
    
    let expectation = self.expectation(description: "Subscribers connected and received events")
    expectation.expectedFulfillmentCount = 2
    
    var sub1: Cancellable?
    var sub2: Cancellable?
        
    concurrentQueue.async {
      sub1 = self.client.subscribe(subscription: firstSubscription) { _ in
        expectation.fulfill()
      }
    }
    
    concurrentQueue.async {
      sub2 = self.client.subscribe(subscription: secondSubscription) { _ in
        expectation.fulfill()
      }
    }
    
    self.waitForSubscriptionsToStart(on: concurrentQueue)
    
    // dispatched with a barrier flag to make sure
    // this is performed after subscription calls
    concurrentQueue.sync(flags: .barrier) {
      // dispatched on the processing queue with barrier flag to make sure
      // this is performed after subscribers are processed
      self.webSocketTransport.processingQueue.async(flags: .barrier) {
        _ = self.client.perform(mutation: CreateReviewForEpisodeMutation(episode: .empire, review: ReviewInput(stars: 5, commentary: "The greatest movie ever!")))
      }
    }
    
    waitForExpectations(timeout: 10, handler: nil)
    sub1?.cancel()
    sub2?.cancel()
  }
  
  func testConcurrentSubscriptionCancellations() {
    let firstSubscription = ReviewAddedSubscription(episode: .empire)
    let secondSubscription = ReviewAddedSubscription(episode: .empire)
    
    let expectation = self.expectation(description: "Subscriptions cancelled")
    expectation.expectedFulfillmentCount = 2
    let invertedExpectation = self.expectation(description: "Subscription received callback - expecting timeout")
    invertedExpectation.isInverted = true
    
    let sub1 = client.subscribe(subscription: firstSubscription) { _ in
      invertedExpectation.fulfill()
    }
    let sub2 = client.subscribe(subscription: secondSubscription) { _ in
      invertedExpectation.fulfill()
    }
    
    self.waitForSubscriptionsToStart(on: concurrentQueue)
    
    concurrentQueue.async {
      sub1.cancel()
      expectation.fulfill()
    }
    concurrentQueue.async {
      sub2.cancel()
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 10)
    
    _ = self.client.perform(mutation: CreateReviewForEpisodeMutation(episode: .empire, review: ReviewInput(stars: 5, commentary: "The greatest movie ever!")))
    
    wait(for: [invertedExpectation], timeout: 2)
  }
  
  func testConcurrentSubscriptionAndConnectionClose() {
    let empireReviewSubscription = ReviewAddedSubscription(episode: .empire)
    let expectation = self.expectation(description: "Connection closed")
    let invertedExpectation = self.expectation(description: "Subscription received callback - expecting timeout")
    invertedExpectation.isInverted = true
    
    let sub = self.client.subscribe(subscription: empireReviewSubscription) { _ in
      invertedExpectation.fulfill()
    }
    
    self.waitForSubscriptionsToStart(on: concurrentQueue)
    
    concurrentQueue.async {
      sub.cancel()
    }
    concurrentQueue.async {
      self.webSocketTransport.closeConnection()
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 10)
    
    _ = self.client.perform(mutation: CreateReviewForEpisodeMutation(episode: .empire, review: ReviewInput(stars: 5, commentary: "The greatest movie ever!")))
    
    wait(for: [invertedExpectation], timeout: 2)
  }
  
  func testConcurrentConnectAndCloseConnection() {
    let webSocketTransport = WebSocketTransport(
      websocket: MockWebSocket(
        request: URLRequest(url: TestServerURL.starWarsWebSocket.url)
      ),
      store: ApolloStore()
    )

    let expectation = self.expectation(description: "Connection closed")
    expectation.expectedFulfillmentCount = 2
    
    concurrentQueue.async {
      if let websocket = webSocketTransport.websocket as? MockWebSocket {
        websocket.reportDidConnect()
        expectation.fulfill()
      }
    }
    
    concurrentQueue.async {
      webSocketTransport.closeConnection()
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  func testPausingAndResumingWebSocketConnection() {
    let subscription = ReviewAddedSubscription()
    let reviewMutation = CreateAwesomeReviewMutation()
    
    // Send the mutations via a separate transport so they can still be sent when the websocket is disconnected
    let store = ApolloStore()
    let interceptorProvider = DefaultInterceptorProvider(store: store)
    let alternateTransport = RequestChainNetworkTransport(interceptorProvider: interceptorProvider,
                                                          endpointURL: TestServerURL.starWarsServer.url)
    let alternateClient = ApolloClient(networkTransport: alternateTransport, store: store)
    
    func sendReview() {
      let reviewSentExpectation = self.expectation(description: "review sent")
      alternateClient.perform(mutation: reviewMutation) { mutationResult in
        switch mutationResult {
        case .success:
          break
        case .failure(let error):
          XCTFail("Unexpected error sending review: \(error)")
        }
        
        reviewSentExpectation.fulfill()
      }
      self.wait(for: [reviewSentExpectation], timeout: 10)
    }
    
    let subscriptionExpectation = self.expectation(description: "Received review")
    // This should get hit twice - once before we pause the web socket and once after.
    subscriptionExpectation.expectedFulfillmentCount = 2
    let reviewAddedSubscription = self.client.subscribe(subscription: subscription) { subscriptionResult in
      switch subscriptionResult {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.data?.reviewAdded?.episode, .jedi)
        subscriptionExpectation.fulfill()
      case .failure(let error):
        if let wsError = error as? WebSocket.WSError {
          // This is an expected error on disconnection, ignore it.
          XCTAssertEqual(wsError.code, 1000)
        } else {
          XCTFail("Unexpected error receiving subscription: \(error)")
          subscriptionExpectation.fulfill()
        }
      }
    }
    
    self.waitForSubscriptionsToStart()
    sendReview()

    self.disconnectedExpectation = self.expectation(description: "Web socket disconnected")
    webSocketTransport.pauseWebSocketConnection()
    self.wait(for: [self.disconnectedExpectation!], timeout: 10)

    // This should not go through since the socket is paused
    sendReview()

    self.reconnectedExpectation = self.expectation(description: "Web socket reconnected")
    webSocketTransport.resumeWebSocketConnection()
    self.wait(for: [self.reconnectedExpectation!], timeout: 10)
    self.waitForSubscriptionsToStart()

    // Now that we've reconnected, this should go through to the same subscription.
    sendReview()
    
    self.wait(for: [subscriptionExpectation], timeout: 10)

    // Cancel subscription so it doesn't keep receiving from other tests.
    reviewAddedSubscription.cancel()    
  }
}

extension StarWarsSubscriptionTests: WebSocketTransportDelegate {
  
  func webSocketTransportDidConnect(_ webSocketTransport: WebSocketTransport) {
    self.connectionStartedExpectation?.fulfill()
  }
  
  func webSocketTransportDidReconnect(_ webSocketTransport: WebSocketTransport) {
    self.reconnectedExpectation?.fulfill()
  }
  
  func webSocketTransport(_ webSocketTransport: WebSocketTransport, didDisconnectWithError error: Error?) {
    self.disconnectedExpectation?.fulfill()
  }
}

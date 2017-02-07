import XCTest
@testable import Apollo

class WatchQueryTests: XCTestCase {
  func testRefetchWatchedQuery() throws {
    let query = HeroNameQuery()
    
    let store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let networkTransport = MockNetworkTransport(body: [
      "data": [
        "hero": [
          "name": "Artoo",
          "__typename": "Droid"
        ]
      ]
    ])
    
    let client = ApolloClient(networkTransport: networkTransport, store: store)
    
    var verifyResult: OperationResultHandler<HeroNameQuery>
    
    verifyResult = { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      
      XCTAssertEqual(result?.data?.hero?.name, "R2-D2")
    }
    
    var expectation = self.expectation(description: "Fetching query")
    
    let watcher = client.watch(query: query) { (result, error) in
      verifyResult(result, error)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1.0, handler: nil)
    
    verifyResult = { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      
      XCTAssertEqual(result?.data?.hero?.name, "Artoo")
    }
    
    expectation = self.expectation(description: "Refetching query")
    
    watcher.refetch()
    
    waitForExpectations(timeout: 1.0, handler: nil)
  }
  
  func testWatchedQueryGetsUpdatedWithResultFromOtherQuery() throws {
    let store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          Reference(key: "hero.friends.0"),
          Reference(key: "hero.friends.1"),
          Reference(key: "hero.friends.2")
        ]
      ],
      "hero.friends.0": ["__typename": "Human", "name": "Luke Skywalker"],
      "hero.friends.1": ["__typename": "Human", "name": "Han Solo"],
      "hero.friends.2": ["__typename": "Human", "name": "Leia Organa"],
    ])
    
    let networkTransport = MockNetworkTransport(body: [
      "data": [
        "hero": [
          "name": "Artoo",
          "__typename": "Droid"
        ]
      ]
    ])
    
    let client = ApolloClient(networkTransport: networkTransport, store: store)
    
    let query = HeroAndFriendsNamesQuery()
    
    var verifyResult: OperationResultHandler<HeroAndFriendsNamesQuery>
    
    verifyResult = { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      
      guard let data = result?.data else { XCTFail(); return }
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
    
    var expectation = self.expectation(description: "Fetching query")
    
    _ = client.watch(query: query) { (result, error) in
      verifyResult(result, error)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1.0, handler: nil)
    
    verifyResult = { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      
      guard let data = result?.data else { XCTFail(); return }
      XCTAssertEqual(data.hero?.name, "Artoo")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
    
    expectation = self.expectation(description: "Updated after fetching other query")
    
    client.fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData)

    waitForExpectations(timeout: 1.0, handler: nil)
  }
  
  func testWatchedQueryDoesNotRefetchAfterUnrelatedQuery() throws {
    let store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          Reference(key: "hero.friends.0"),
          Reference(key: "hero.friends.1"),
          Reference(key: "hero.friends.2")
        ]
      ],
      "hero.friends.0": ["__typename": "Human", "name": "Luke Skywalker"],
      "hero.friends.1": ["__typename": "Human", "name": "Han Solo"],
      "hero.friends.2": ["__typename": "Human", "name": "Leia Organa"],
    ])
    
    let networkTransport = MockNetworkTransport(body: [
      "data": [
        "hero": [
          "name": "Artoo",
          "__typename": "Droid"
        ]
      ]
    ])
    
    let client = ApolloClient(networkTransport: networkTransport, store: store)
    
    let query = HeroAndFriendsNamesQuery()
    
    var verifyResult: OperationResultHandler<HeroAndFriendsNamesQuery>
    
    verifyResult = { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      
      guard let data = result?.data else { XCTFail(); return }
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
    
    let expectation = self.expectation(description: "Fetching query")
    
    _ = client.watch(query: query) { (result, error) in
      verifyResult(result, error)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1.0, handler: nil)
    
    verifyResult = { (result, error) in
      XCTFail()
    }
    
    client.fetch(query: HeroNameQuery(episode: .empire), cachePolicy: .fetchIgnoringCacheData)
    
    waitFor(timeInterval: 1.0)
  }
  
  func testWatchedQueryWithID() throws {
    let query = HeroNameWithIdQuery()
    
    let store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "2001")],
      "2001": [
        "id": "2001",
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let networkTransport = MockNetworkTransport(body: [
      "data": [
        "hero": [
          "id": "2001",
          "name": "Luke Skywalker",
          "__typename": "Human"
        ]
      ]
    ])
    
    let client = ApolloClient(networkTransport: networkTransport, store: store)
    client.cacheKeyForObject = { $0["id"] }
    
    var verifyResult: OperationResultHandler<HeroNameWithIdQuery>
    
    verifyResult = { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      
      XCTAssertEqual(result?.data?.hero?.name, "R2-D2")
    }
    
    var expectation = self.expectation(description: "Fetching query")
    
    _ = client.watch(query: query) { (result, error) in
      verifyResult(result, error)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1.0, handler: nil)
    
    verifyResult = { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      
      XCTAssertEqual(result?.data?.hero?.name, "Luke Skywalker")
    }
    
    expectation = self.expectation(description: "Fetching other query")
    
    client.fetch(query: HeroNameWithIdQuery(), cachePolicy: .fetchIgnoringCacheData)
    
    waitForExpectations(timeout: 1.0, handler: nil)
  }
  
  // TODO: Replace with .inverted on XCTestExpectation, which is new in Xcode 8.3
  private func waitFor(timeInterval: TimeInterval) {
    let untilDate = Date(timeIntervalSinceNow: timeInterval)
    
    while untilDate.timeIntervalSinceNow > 0 {
      RunLoop.current.run(mode: .defaultRunLoopMode, before: untilDate)
    }
  }
}

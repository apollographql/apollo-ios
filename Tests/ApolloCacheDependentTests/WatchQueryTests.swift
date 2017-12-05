import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class WatchQueryTests: XCTestCase {

  func testRefetchWatchedQuery() throws {
    let query = HeroNameQuery()

    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]

    withCache(initialRecords: initialRecords) { (cache) in
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "name": "Artoo",
            "__typename": "Droid"
          ]
        ]
        ])
      let store = ApolloStore(cache: cache)
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

      waitForExpectations(timeout: 5, handler: nil)

      verifyResult = { (result, error) in
        XCTAssertNil(error)
        XCTAssertNil(result?.errors)

        XCTAssertEqual(result?.data?.hero?.name, "Artoo")
      }

      expectation = self.expectation(description: "Refetching query")

      watcher.refetch()
      
      waitForExpectations(timeout: 5, handler: nil)
    }
  }
  
  func testWatchedQueryGetsUpdatedWithResultFromOtherQuery() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          Reference(key: "QUERY_ROOT.hero.friends.0"),
          Reference(key: "QUERY_ROOT.hero.friends.1"),
          Reference(key: "QUERY_ROOT.hero.friends.2")
        ]
      ],
      "QUERY_ROOT.hero.friends.0": ["__typename": "Human", "name": "Luke Skywalker"],
      "QUERY_ROOT.hero.friends.1": ["__typename": "Human", "name": "Han Solo"],
      "QUERY_ROOT.hero.friends.2": ["__typename": "Human", "name": "Leia Organa"],
      ]

    withCache(initialRecords: initialRecords) { (cache) in
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "name": "Artoo",
            "__typename": "Droid"
          ]
        ]
        ])
      let store = ApolloStore(cache: cache)
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

      waitForExpectations(timeout: 5, handler: nil)

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
      
      waitForExpectations(timeout: 5, handler: nil)
    }
  }
  
  func testWatchedQueryDoesNotRefetchAfterUnrelatedQuery() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          Reference(key: "QUERY_ROOT.hero.friends.0"),
          Reference(key: "QUERY_ROOT.hero.friends.1"),
          Reference(key: "QUERY_ROOT.hero.friends.2")
        ]
      ],
      "QUERY_ROOT.hero.friends.0": ["__typename": "Human", "name": "Luke Skywalker"],
      "QUERY_ROOT.hero.friends.1": ["__typename": "Human", "name": "Han Solo"],
      "QUERY_ROOT.hero.friends.2": ["__typename": "Human", "name": "Leia Organa"],
      ]

    withCache(initialRecords: initialRecords) { (cache) in
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "name": "Artoo",
            "__typename": "Droid"
          ]
        ]
        ])
      let store = ApolloStore(cache: cache)
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

      waitForExpectations(timeout: 5, handler: nil)

      verifyResult = { (result, error) in
        XCTFail()
      }

      client.fetch(query: HeroNameQuery(episode: .empire), cachePolicy: .fetchIgnoringCacheData)
      
      waitFor(timeInterval: 1.0)
    }
  }
  
  func testWatchedQueryWithID() throws {
    let query = HeroNameWithIdQuery()

    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "2001")],
      "2001": [
        "id": "2001",
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]

    withCache(initialRecords: initialRecords) { (cache) in
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "id": "2001",
            "name": "Luke Skywalker",
            "__typename": "Human"
          ]
        ]
        ])
      let store = ApolloStore(cache: cache)
      let client = ApolloClient(networkTransport: networkTransport, store: store)
      client.store.cacheKeyForObject = { $0["id"] }

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

      waitForExpectations(timeout: 5, handler: nil)

      verifyResult = { (result, error) in
        XCTAssertNil(error)
        XCTAssertNil(result?.errors)

        XCTAssertEqual(result?.data?.hero?.name, "Luke Skywalker")
      }

      expectation = self.expectation(description: "Fetching other query")

      client.fetch(query: HeroNameWithIdQuery(), cachePolicy: .fetchIgnoringCacheData)

      waitForExpectations(timeout: 5, handler: nil)
    }
  }

  func testWatchedQueryGetsUpdatedWithResultFromReadWriteTransaction() throws {
    let initialRecords: RecordSet = [
            "QUERY_ROOT": ["hero": Reference(key: "QUERY_ROOT.hero")],
            "QUERY_ROOT.hero": [
                "name": "R2-D2",
                "__typename": "Droid",
                "friends": [
                    Reference(key: "QUERY_ROOT.hero.friends.0"),
                    Reference(key: "QUERY_ROOT.hero.friends.1"),
                    Reference(key: "QUERY_ROOT.hero.friends.2")
                ]
            ],
            "QUERY_ROOT.hero.friends.0": ["__typename": "Human", "name": "Luke Skywalker"],
            "QUERY_ROOT.hero.friends.1": ["__typename": "Human", "name": "Han Solo"],
            "QUERY_ROOT.hero.friends.2": ["__typename": "Human", "name": "Leia Organa"],
            ]
    try withCache(initialRecords: initialRecords) { (cache) in
      let networkTransport = MockNetworkTransport(body: [:])

      let store = ApolloStore(cache: cache)
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

      waitForExpectations(timeout: 5, handler: nil)

      let nameQuery = HeroNameQuery()
      try await(store.withinReadWriteTransaction { transaction in
        try transaction.update(query: nameQuery) { (data: inout HeroNameQuery.Data) in
          data.hero?.name = "Artoo"
        }
      })

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
      waitForExpectations(timeout: 5, handler: nil)
    }
  }

  // TODO: Replace with .inverted on XCTestExpectation, which is new in Xcode 8.3
  private func waitFor(timeInterval: TimeInterval) {
    let untilDate = Date(timeIntervalSinceNow: timeInterval)

    while untilDate.timeIntervalSinceNow > 0 {
      RunLoop.current.run(mode: .defaultRunLoopMode, before: untilDate)
    }
  }
}

import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class WatchQueryTests: XCTestCase, CacheDependentTesting {
  
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  static let defaultWaitTimeout: TimeInterval = 1
  
  var cache: NormalizedCache!
  var server: MockGraphQLServer!
  var client: ApolloClient!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    cache = try makeNormalizedCache()
    let store = ApolloStore(cache: cache)
    
    server = MockGraphQLServer()
    let networkTransport = MockNetworkTransport(server: server, store: store)
    
    client = ApolloClient(networkTransport: networkTransport, store: store)
  }
  
  override func tearDownWithError() throws {
    cache = nil
    server = nil
    client = nil
    
    try super.tearDownWithError()
  }
  
  func testRefetchWatchedQueryFromServerThroughWatcherReturnsRefetchedResults() throws {
    let watchedQuery = HeroNameQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Refetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let refetchedWatcherResultExpectation = resultObserver.expectation(description: "Watcher received refetched result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
        }
      }
      
      watcher.refetch()
      
      wait(for: [serverRequestExpectation, refetchedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryGetsUpdatedAfterFetchingSameQueryWithChangedData() throws {
    let watchedQuery = HeroNameQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Fetch same query from server returning changed data") { _ in
      let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let updatedWatcherResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
        }
      }
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")
      
      client.fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryDoesNotRefetchAfterSameQueryWithDifferentArgument() throws {
    let watchedQuery = HeroNameQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Fetch same query from server with different argument") { _ in
      let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
        XCTAssertEqual(request.operation.episode, .jedi)
        
        return [
          "data": [
            "hero": [
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let noUpdatedResultExpectation = resultObserver.expectation(description: "Other query shouldn't trigger refetch") { _ in }
      noUpdatedResultExpectation.isInverted = true
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")
      
      client.fetch(query: HeroNameQuery(episode: .jedi), cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, noUpdatedResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryGetsUpdatedWhenSameObjectHasChangedInDifferentQuery() throws {
    client.cacheKeyForObject = { $0["id"] }
    
    let watchedQuery = HeroNameWithIdQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroNameWithIdQuery.self) { request in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.id, "2001")
          XCTAssertEqual(data.hero?.name, "R2-D2")
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Fetch same query from server with different argument but returning same object with changed data") { _ in
      let serverRequestExpectation = server.expect(HeroNameWithIdQuery.self) { request in
        XCTAssertEqual(request.operation.episode, .jedi)
        return [
          "data": [
            "hero": [
              "id": "2001",
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let updatedWatcherResultExpectation = resultObserver.expectation(description: "Updated result after refetching query") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
        }
      }
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")
      
      client.fetch(query: HeroNameWithIdQuery(episode: .jedi), cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryGetsUpdatedWhenOverlappingQueryReturnsChangedData() throws {
    let watchedQuery = HeroAndFriendsNamesQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroAndFriendsNamesQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "name": "Luke Skywalker"],
                ["__typename": "Human", "name": "Han Solo"],
                ["__typename": "Human", "name": "Leia Organa"],
              ]
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Fetch overlapping query from server") { _ in
      let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let updatedWatcherResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")
      
      client.fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testListInWatchedQueryGetsUpdatedByListOfKeysFromOtherQuery() throws {
    client.cacheKeyForObject = { $0["id"] }
    
    let watchedQuery = HeroAndFriendsNamesWithIDsQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "R2-D2",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "id": "1000", "name": "Luke Skywalker"],
                ["__typename": "Human", "id": "1002", "name": "Han Solo"],
                ["__typename": "Human", "id": "1003", "name": "Leia Organa"],
              ]
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Fetch other query with list of updated keys from server") { _ in
      let serverRequestExpectation = server.expect(HeroAndFriendsIDsQuery.self) { request in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "Artoo",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "id": "1003"],
                ["__typename": "Human", "id": "1000"],
              ]
            ]
          ]
        ]
      }
      
      let updatedWatcherResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Leia Organa", "Luke Skywalker"])
        }
      }
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")
      
      client.fetch(query: HeroAndFriendsIDsQuery(), cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryRefetchesFromServerAfterOtherQueryUpdatesListWithIncompleteObject() throws {
    client.store.cacheKeyForObject = { $0["id"] }
    
    let watchedQuery = HeroAndFriendsNamesWithIDsQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "R2-D2",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "id": "1000", "name": "Luke Skywalker"],
                ["__typename": "Human", "id": "1002", "name": "Han Solo"],
                ["__typename": "Human", "id": "1003", "name": "Leia Organa"],
              ]
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Fetch other query with list of updated keys from server") { _ in
      let serverRequestExpectation = server.expect(HeroAndFriendsIDsQuery.self) { request in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "Artoo",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "id": "1003"],
                ["__typename": "Human", "id": "1004"],
                ["__typename": "Human", "id": "1000"],
              ]
            ]
          ]
        ]
      }
      
      let refetchServerRequestExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "Artoo",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "id": "1003", "name": "Leia Organa"],
                ["__typename": "Human", "id": "1004", "name": "Wilhuff Tarkin"],
                ["__typename": "Human", "id": "1000", "name": "Luke Skywalker"],
              ]
            ]
          ]
        ]
      }
      
      let updatedWatcherResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Leia Organa", "Wilhuff Tarkin", "Luke Skywalker"])
        }
      }
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")
      
      client.fetch(query: HeroAndFriendsIDsQuery(), cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, refetchServerRequestExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func testWatchedQuery_givenCachePolicyReturnCacheDataDontFetch_doesNotRefetchFromServerAfterOtherQueryUpdatesListWithIncompleteObject() throws {
    client.store.cacheKeyForObject = { $0["id"] }

    let watchedQuery = HeroAndFriendsNamesWithIDsQuery()

    let resultObserver = makeResultObserver(for: watchedQuery)

    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }

    runActivity("Write data to cache") { _ in
      let writeToStoreExpectation = expectation(description: "Initial Data written to store")

      client.store.withinReadWriteTransaction({ transaction in
        let data = HeroAndFriendsNamesWithIDsQuery.Data(
          unsafeResultMap: [
            "hero": [
              "id": "2001",
              "name": "R2-D2",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "id": "1000", "name": "Luke Skywalker"],
                ["__typename": "Human", "id": "1002", "name": "Han Solo"],
                ["__typename": "Human", "id": "1003", "name": "Leia Organa"],
              ]
            ]
          ])
        
        try transaction.write(data: data, forQuery: HeroAndFriendsNamesWithIDsQuery())
      }) { result in
        XCTAssertSuccessResult(result)
        writeToStoreExpectation.fulfill()
      }

      wait(for: [writeToStoreExpectation], timeout: Self.defaultWaitTimeout)
    }

    runActivity("Initial fetch from cache") { _ in
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from cache") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)

          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }

      watcher.fetch(cachePolicy: .returnCacheDataDontFetch)

      wait(for: [initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }

    runActivity("Fetch other query with list of updated keys from server") { _ in
      let serverRequestExpectation = server.expect(HeroAndFriendsIDsQuery.self) { request in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "Artoo",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "id": "1003"],
                ["__typename": "Human", "id": "1004"],
                ["__typename": "Human", "id": "1000"],
              ]
            ]
          ]
        ]
      }

      let noRefetchExpectation = resultObserver.expectation(description: "Initial query shouldn't trigger refetch") { _ in }
      noRefetchExpectation.isInverted = true

      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")

      client.fetch(query: HeroAndFriendsIDsQuery(), cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }

      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, noRefetchExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryGetsUpdatedWhenObjectIsChangedByDirectStoreUpdate() throws {
    let watchedQuery = HeroAndFriendsNamesQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroAndFriendsNamesQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "name": "Luke Skywalker"],
                ["__typename": "Human", "name": "Han Solo"],
                ["__typename": "Human", "name": "Leia Organa"],
              ]
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Update object directly in store") { _ in
      let updatedWatcherResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
          
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }
      
      client.store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: HeroNameQuery()) { data in
          data.hero?.name = "Artoo"
        }
      })
      
      wait(for: [updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryIsOnlyUpdatedOnceIfConcurrentFetchesAllReturnTheSameResult() throws {
    let watchedQuery = HeroNameQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    let numberOfFetches = 10
    
    runActivity("Fetch same query concurrently \(numberOfFetches) times") { _ in
      let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      serverRequestExpectation.expectedFulfillmentCount = numberOfFetches
      
      let updatedWatcherResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
        }
      }
      
      let otherFetchesCompletedExpectation = expectation(description: "Other fetches completed")
      otherFetchesCompletedExpectation.expectedFulfillmentCount = numberOfFetches
      
      DispatchQueue.concurrentPerform(iterations: numberOfFetches) { _ in
        client.fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData) { [weak self] result in
          otherFetchesCompletedExpectation.fulfill()
          
          if let self = self, case .failure(let error) = result {
            self.record(error)
          }
        }
      }
      
      wait(for: [serverRequestExpectation, otherFetchesCompletedExpectation, updatedWatcherResultExpectation], timeout: 3)
      
      XCTAssertEqual(updatedWatcherResultExpectation.apollo.numberOfFulfillments, 1)
    }
  }
  
  func testWatchedQueryIsUpdatedMultipleTimesIfConcurrentFetchesReturnChangedData() throws {
    let watchedQuery = HeroNameQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    let numberOfFetches = 10
    
    runActivity("Fetch same query concurrently \(numberOfFetches) times") { _ in
      let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo #\(UUID())",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      serverRequestExpectation.expectedFulfillmentCount = numberOfFetches
      
      let updatedWatcherResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertTrue(try XCTUnwrap(data.hero?.name).hasPrefix("Artoo"))
        }
      }
      
      updatedWatcherResultExpectation.expectedFulfillmentCount = numberOfFetches
      
      let otherFetchesCompletedExpectation = expectation(description: "Other fetches completed")
      otherFetchesCompletedExpectation.expectedFulfillmentCount = numberOfFetches
      
      DispatchQueue.concurrentPerform(iterations: numberOfFetches) { _ in
        client.fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData) { [weak self] result in
          otherFetchesCompletedExpectation.fulfill()
          
          if let self = self, case .failure(let error) = result {
            self.record(error)
          }
        }
      }
      
      wait(for: [serverRequestExpectation, otherFetchesCompletedExpectation, updatedWatcherResultExpectation], timeout: 3)
      
      XCTAssertEqual(updatedWatcherResultExpectation.apollo.numberOfFulfillments, numberOfFetches)
    }
  }
  
  func testWatchedQueryDependentKeysAreUpdatedAfterDirectStoreUpdate() {
    client.store.cacheKeyForObject = { $0["id"] }
    
    let watchedQuery = HeroAndFriendsNamesWithIDsQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "R2-D2",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "id": "1000", "name": "Luke Skywalker"],
              ]
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          
          XCTAssertEqual(data.hero?.name, "R2-D2")
          
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker"])
          
          let expectedDependentKeys: Set = [
            "2001.__typename",
            "2001.friends",
            "2001.id",
            "2001.name",
            "1000.__typename",
            "1000.id",
            "1000.name",
            "QUERY_ROOT.hero",
          ]
          let actualDependentKeys = try XCTUnwrap(graphQLResult.dependentKeys)
          XCTAssertEqual(actualDependentKeys, expectedDependentKeys)
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Update same query directly in store") { _ in
      let updatedWatcherResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          
          XCTAssertEqual(data.hero?.name, "R2-D2")
          
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo"])
          
          let expectedDependentKeys: Set = [
            "2001.__typename",
            "2001.friends",
            "2001.id",
            "2001.name",
            "1000.__typename",
            "1000.id",
            "1000.name",
            "1002.__typename",
            "1002.id",
            "1002.name",
            "QUERY_ROOT.hero",
          ]
          let actualDependentKeys = try XCTUnwrap(graphQLResult.dependentKeys)
          XCTAssertEqual(actualDependentKeys, expectedDependentKeys)
        }
      }
      
      client.store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: HeroAndFriendsNamesWithIDsQuery()) { data in
          data.hero?.friends?.append(.makeHuman(id: "1002", name: "Han Solo"))
        }
      })
      
      wait(for: [updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryDependentKeysAreUpdatedAfterOtherFetchReturnsChangedData() {
    client.store.cacheKeyForObject = { $0["id"] }
    
    let watchedQuery = HeroAndFriendsNamesWithIDsQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "R2-D2",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "id": "1000", "name": "Luke Skywalker"],
              ]
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          
          XCTAssertEqual(data.hero?.name, "R2-D2")
          
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker"])
          
          let expectedDependentKeys: Set = [
            "2001.__typename",
            "2001.friends",
            "2001.id",
            "2001.name",
            "1000.__typename",
            "1000.id",
            "1000.name",
            "QUERY_ROOT.hero",
          ]
          let actualDependentKeys = try XCTUnwrap(graphQLResult.dependentKeys)
          XCTAssertEqual(actualDependentKeys, expectedDependentKeys)
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Fetch other query from server") { _ in
      let serverRequestExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "R2-D2",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "id": "1000", "name": "Luke Skywalker"],
                ["__typename": "Human", "id": "1002", "name": "Han Solo"],
              ]
            ]
          ]
        ]
      }
      
      let updatedWatcherResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          
          XCTAssertEqual(data.hero?.name, "R2-D2")
          
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo"])
          
          let expectedDependentKeys: Set = [
            "2001.__typename",
            "2001.friends",
            "2001.id",
            "2001.name",
            "1000.__typename",
            "1000.id",
            "1000.name",
            "1002.__typename",
            "1002.id",
            "1002.name",
            "QUERY_ROOT.hero",
          ]
          let actualDependentKeys = try XCTUnwrap(graphQLResult.dependentKeys)
          XCTAssertEqual(actualDependentKeys, expectedDependentKeys)
        }
      }
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")
      
      client.fetch(query: HeroAndFriendsNamesWithIDsQuery(), cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func testQueryWatcherDoesNotHaveARetainCycle() {
    client.store.cacheKeyForObject = { $0["id"] }

    let watchedQuery = HeroAndFriendsNamesWithIDsQuery()

    let resultObserver = makeResultObserver(for: watchedQuery)

    var watcher: GraphQLQueryWatcher<HeroAndFriendsNamesWithIDsQuery>? = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    weak var weakWatcher: GraphQLQueryWatcher<HeroAndFriendsNamesWithIDsQuery>? = watcher

    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "R2-D2",
              "__typename": "Droid",
              "friends": [
                ["__typename": "Human", "id": "1000", "name": "Luke Skywalker"],
              ]
            ]
          ]
        ]
      }

      let initialWatcherResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)

          let data = try XCTUnwrap(graphQLResult.data)

          XCTAssertEqual(data.hero?.name, "R2-D2")

          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker"])

          let expectedDependentKeys: Set = [
            "2001.__typename",
            "2001.friends",
            "2001.id",
            "2001.name",
            "1000.__typename",
            "1000.id",
            "1000.name",
            "QUERY_ROOT.hero",
          ]
          let actualDependentKeys = try XCTUnwrap(graphQLResult.dependentKeys)
          XCTAssertEqual(actualDependentKeys, expectedDependentKeys)
        }
      }

      watcher?.fetch(cachePolicy: .fetchIgnoringCacheData)

      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }

    runActivity("make sure it gets released") { _ in
      watcher = nil
      cache = nil
      server = nil
      client = nil

      XCTAssertTrueEventually(weakWatcher == nil, message: "Watcher was not released.")
    }
  }
}

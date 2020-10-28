import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class WatchQueryTests: XCTestCase, CacheTesting {
  
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  var cache: NormalizedCache!
  var server: MockGraphQLServer!
  var client: ApolloClient!
  
  override func setUpWithError() throws {
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
  }
  
  func testRefetchWatchedQueryFromServerThroughWatcher() throws {
    let watchedQuery = HeroNameQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }
    
    runActivity("Refetch from server") { _ in
      let serverExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let refetchedResultExpectation = resultObserver.expectation(description: "Watcher received refetched result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
      }
      
      watcher.refetch()
      
      wait(for: [serverExpectation, refetchedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryGetsUpdatedWithResultFromSameQuery() throws {
    let watchedQuery = HeroNameQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch same query from server with changed result") { _ in
      let serverExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let updatedResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
      }
      
      let fetchedResultExpectation = fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData)
        .expectation(description: "Fetched same query again")
      
      wait(for: [serverExpectation, fetchedResultExpectation, updatedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryDoesNotRefetchAfterSameQueryWithDifferentArgument() throws {
    let watchedQuery = HeroNameQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch same query from server with different argument") { _ in
      let serverExpectation = server.expect(HeroNameQuery.self) { request in
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
      
      let noUpdatedResultExpectation = resultObserver.expectation(description: "Other query shouldn't trigger refetch")
      noUpdatedResultExpectation.isInverted = true
      
      let fetchedResultExpectation = fetch(query: HeroNameQuery(episode: .jedi), cachePolicy: .fetchIgnoringCacheData)
        .expectation(description: "Fetched same query with different argument")
      
      wait(for: [serverExpectation, fetchedResultExpectation, noUpdatedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryGetsUpdatedWithResultForSameObject() throws {
    client.cacheKeyForObject = { $0["id"] }
    
    let watchedQuery = HeroNameWithIdQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroNameWithIdQuery.self) { request in
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
      
      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.id, "2001")
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch same query from server with different result") { _ in
      let serverExpectation = server.expect(HeroNameWithIdQuery.self) { request in
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
      
      let updatedResultExpectation = resultObserver.expectation(description: "Updated result after refetching query") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
      }
      
      let fetchedResultExpectation = fetch(query: HeroNameWithIdQuery(episode: .jedi), cachePolicy: .fetchIgnoringCacheData)
        .expectation(description: "Fetched same query again")
      
      wait(for: [serverExpectation, fetchedResultExpectation, updatedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryGetsUpdatedWithResultFromSubQuery() throws {
    let watchedQuery = HeroAndFriendsNamesQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroAndFriendsNamesQuery.self) { request in
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
      
      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch subquery from server") { _ in
      let serverExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let updatedResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
      
      let fetchResultExpectation = fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData)
        .expectation(description: "Fetched related query") { result in
          let graphQLResult = try result.get()
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
        }
      
      wait(for: [serverExpectation, fetchResultExpectation, updatedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryGetsUpdatedWithListFromOtherQuery() throws {
    client.cacheKeyForObject = { $0["id"] }
    
    let watchedQuery = HeroAndFriendsNamesWithIDsQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
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
      
      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch related query from server") { _ in
      let serverExpectation = server.expect(HeroAndFriendsIDsQuery.self) { request in
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
      
      let updatedResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Leia Organa", "Luke Skywalker"])
      }
      
      let fetchResultExpectation = fetch(query: HeroAndFriendsIDsQuery(), cachePolicy: .fetchIgnoringCacheData)
        .expectation(description: "Fetched related query") { result in
          let graphQLResult = try result.get()
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
        }
      
      wait(for: [serverExpectation, fetchResultExpectation, updatedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryRefectchesFromServerAfterOtherQueryUpdatesListWithIncompleteObject() throws {
    client.store.cacheKeyForObject = { $0["id"] }
    
    let watchedQuery = HeroAndFriendsNamesWithIDsQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
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
      
      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch related query from server") { _ in
      let serverExpectation = server.expect(HeroAndFriendsIDsQuery.self) { request in
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
      
      let refetchServerExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
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
      
      let updatedResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Leia Organa", "Wilhuff Tarkin", "Luke Skywalker"])
      }
      
      let fetchResultExpectation = fetch(query: HeroAndFriendsIDsQuery(), cachePolicy: .fetchIgnoringCacheData)
        .expectation(description: "Fetched related query") { result in
          let graphQLResult = try result.get()
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
        }
      
      wait(for: [serverExpectation, fetchResultExpectation, refetchServerExpectation, updatedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryGetsUpdatedWithResultFromDirectStoreUpdate() throws {
    let watchedQuery = HeroAndFriendsNamesQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroAndFriendsNamesQuery.self) { request in
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
      
      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }
    
    runActivity("Update subquery in store") { _ in
      let updatedResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
        
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
            
      client.store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: HeroNameQuery()) { data in
          data.hero?.name = "Artoo"
        }
      })
      
      wait(for: [updatedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryIsOnlyUpdatedOnceIfRelatedFetchesAllReturnTheSameResults() throws {
    let watchedQuery = HeroNameQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }
    
    runActivity("Same query fetched concurrently") { _ in
      let numberOfFetches = 100
      
      let serverExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      serverExpectation.expectedFulfillmentCount = numberOfFetches
      
      let updatedResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
      }
      
      DispatchQueue.concurrentPerform(iterations: numberOfFetches) { i in
        fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData)
          .expectation(description: "Fetched related query #\(i)") { result in
            let graphQLResult = try result.get()
            let data = try XCTUnwrap(graphQLResult.data)
            XCTAssertEqual(data.hero?.name, "Artoo")
          }
      }
      
      wait(for: [updatedResultExpectation], timeout: 1)
      
      XCTAssertEqual(updatedResultExpectation.numberOfFulfillments, 1)
    }
  }
  
  func testWatchedQueryIsUpdatedMultipleTimesIfRelatedFetchesReturnDifferentResults() throws {
    let watchedQuery = HeroNameQuery()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }
    
    runActivity("Same query fetched concurrently") { _ in
      let numberOfFetches = 100
      
      let serverExpectation = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo #\(String(describing: request.contextIdentifier!))",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      serverExpectation.expectedFulfillmentCount = numberOfFetches
      
      let updatedResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertTrue(try XCTUnwrap(data.hero?.name).hasPrefix("Artoo"))
      }
      
      updatedResultExpectation.expectedFulfillmentCount = numberOfFetches
      
      DispatchQueue.concurrentPerform(iterations: numberOfFetches) { i in
        let contextIdentifier = UUID()
        
        fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData, contextIdentifier: contextIdentifier)
          .expectation(description: "Fetched related query") { result in
            let graphQLResult = try result.get()
            let data = try XCTUnwrap(graphQLResult.data)
            XCTAssertEqual(data.hero?.name, "Artoo #\(String(describing: contextIdentifier))")
          }
      }
      
      wait(for: [serverExpectation, updatedResultExpectation], timeout: 1)
      
      XCTAssertEqual(updatedResultExpectation.numberOfFulfillments, numberOfFetches)
    }
  }
  
  func testWatchedQueryDependentKeysAreUpdatedAfterDirectStoreUpdate() {
    client.store.cacheKeyForObject = { $0["id"] }

    let watchedQuery = HeroAndFriendsNamesWithIDsQuery()

    let resultObserver = makeResultObserver(for: watchedQuery)

    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
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

      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)

        let data = try XCTUnwrap(graphQLResult.data)

        XCTAssertEqual(data.hero?.name, "R2-D2")

        let friendsNames = graphQLResult.data?.hero?.friends?.compactMap { $0?.name }
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

      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)

      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }

    runActivity("Update same query directly in store") { _ in
      let updatedResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        let graphQLResult = try result.get()
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

      client.store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: HeroAndFriendsNamesWithIDsQuery()) { data in
          data.hero?.friends?.append(.makeHuman(id: "1002", name: "Han Solo"))
        }
      })

      wait(for: [updatedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryDependentKeysAreUpdatedAfterRelatedFetch() {
    client.store.cacheKeyForObject = { $0["id"] }

    let watchedQuery = HeroAndFriendsNamesWithIDsQuery()

    let resultObserver = makeResultObserver(for: watchedQuery)

    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
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

      let initialResultExpectation = resultObserver.expectation(description: "Watcher received initial result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)

        let data = try XCTUnwrap(graphQLResult.data)

        XCTAssertEqual(data.hero?.name, "R2-D2")

        let friendsNames = graphQLResult.data?.hero?.friends?.compactMap { $0?.name }
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

      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)

      wait(for: [serverExpectation, initialResultExpectation], timeout: 1)
    }

    runActivity("Fetch related query from server") { _ in
      let serverExpectation = server.expect(HeroAndFriendsNamesWithIDsQuery.self) { request in
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
      
      let updatedResultExpectation = resultObserver.expectation(description: "Watcher received updated result from cache") { result in
        let graphQLResult = try result.get()
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
      
      let fetchResultExpectation = fetch(query: HeroAndFriendsNamesWithIDsQuery(), cachePolicy: .fetchIgnoringCacheData)
        .expectation(description: "Fetched related query")

      wait(for: [serverExpectation, fetchResultExpectation, updatedResultExpectation], timeout: 1)
    }
  }
  
  // MARK: - Helpers
  
  private func mergeRecordsIntoCache(_ records: RecordSet) {
    let expectation = XCTestExpectation(description: "Merged records into cache")
    
    cache.merge(records: records, callbackQueue: nil) { _ in
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 1)
  }
  
  private func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy, contextIdentifier: UUID? = nil) -> AsyncResultObserver<GraphQLResult<Query.Data>, Error> {
    let resultObserver = makeResultObserver(for: query)
    client.fetch(query: query, cachePolicy: cachePolicy, contextIdentifier: contextIdentifier, resultHandler: resultObserver.handler)
    return resultObserver
  }
}

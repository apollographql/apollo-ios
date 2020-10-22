import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class WatchQueryTests: XCTestCase, CacheTesting {

  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  var cache: NormalizedCache!
  var networkTransport: MockNetworkTransport!
  var client: ApolloClient!
  
  override func setUpWithError() throws {
    cache = try makeNormalizedCache()
    let store = ApolloStore(cache: cache)
    
    networkTransport = MockNetworkTransport(store: store)
    client = ApolloClient(networkTransport: networkTransport, store: store)
  }
  
  override func tearDownWithError() throws {
    cache = nil
    networkTransport = nil
    client = nil
  }
  
  func mergeRecordsIntoCache(_ records: RecordSet) {
    let expectation = XCTestExpectation(description: "Merged records into cache")
    
    cache.merge(records: records, callbackQueue: nil) { _ in
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 1)
  }
  
  func stubNetworkResponse(_ body: JSONObject) {
    networkTransport.updateBody(to: body)
  }
  
  func testRefetchWatchedQuery() throws {
    let query = HeroNameQuery()
    
    let resultObserver = makeResultObserver(for: query)
    
    let watcher = GraphQLQueryWatcher(client: client, query: query, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from cache") { _ in
      mergeRecordsIntoCache([
        "QUERY_ROOT": ["hero": Reference(key: "hero")],
        "hero": [
          "name": "R2-D2",
          "__typename": "Droid",
        ]
      ])
      
      let initialResultExpectation = resultObserver.expectation(description: "Initial result") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
      
      watcher.fetch(cachePolicy: .returnCacheDataDontFetch)
      
      wait(for: [initialResultExpectation], timeout: 1)
    }
    
    runActivity("Refetch from server") { _ in
      stubNetworkResponse([
        "data": [
          "hero": [
            "name": "Artoo",
            "__typename": "Droid"
          ]
        ]
      ])
      
      let refetchedResultExpectation = resultObserver.expectation(description: "Refetched result from server") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
      }
      
      watcher.refetch()
      
      wait(for: [refetchedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryGetsUpdatedWithResultFromOtherQuery() throws {
    let query = HeroAndFriendsNamesQuery()
    
    let resultObserver = makeResultObserver(for: query)
    
    let watcher = GraphQLQueryWatcher(client: client, query: query, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from cache") { _ in
      mergeRecordsIntoCache([
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
      ])
      
      let initialResultExpectation = resultObserver.expectation(description: "Initial result") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
      
      watcher.fetch(cachePolicy: .returnCacheDataDontFetch)
      
      wait(for: [initialResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch other query from server") { _ in
      stubNetworkResponse([
        "data": [
          "hero": [
            "name": "Artoo",
            "__typename": "Droid"
          ]
        ]
      ])
      
      let updatedResultExpectation = resultObserver.expectation(description: "Updated result after fetching other query") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, [
          "Luke Skywalker",
          "Han Solo",
          "Leia Organa",
        ])
      }
      
      client.fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [updatedResultExpectation], timeout: 1)
    }
  }

  func testWatchedQueryGetsUpdatedWithListReorderingFromOtherQuery() throws {
    let query = HeroAndFriendsNamesQuery()
    
    let resultObserver = makeResultObserver(for: query)
    
    let watcher = GraphQLQueryWatcher(client: client, query: query, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from cache") { _ in
      mergeRecordsIntoCache([
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
      ])
      
      let initialResultExpectation = resultObserver.expectation(description: "Initial result") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
      
      watcher.fetch(cachePolicy: .returnCacheDataDontFetch)
      
      wait(for: [initialResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch other query from server") { _ in
      stubNetworkResponse([
        "data": [
          "hero": [
            "name": "Artoo",
            "__typename": "Droid",
            "friends": [
              ["__typename": "Human", "name": "Luke Skywalker"],
              ["__typename": "Human", "name": "Leia Organa"],
            ]
          ]
        ]
      ])
      
      let updatedResultExpectation = resultObserver.expectation(description: "Updated result after fetching other query") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, [
          "Luke Skywalker",
          "Leia Organa",
        ])
      }
      
      client.fetch(query: HeroAndFriendsNamesQuery(), cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [updatedResultExpectation], timeout: 1)
    }
  }

  func testWatchedQueryDoesNotRefetchAfterUnrelatedQuery() throws {
    let query = HeroAndFriendsNamesQuery()
    
    let resultObserver = makeResultObserver(for: query)
    
    let watcher = GraphQLQueryWatcher(client: client, query: query, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from cache") { _ in
      mergeRecordsIntoCache([
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
      ])
      
      let initialResultExpectation = resultObserver.expectation(description: "Initial result") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, [
          "Luke Skywalker",
          "Han Solo",
          "Leia Organa",
        ])
      }
      
      watcher.fetch(cachePolicy: .returnCacheDataDontFetch)
      
      wait(for: [initialResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch other query from server") { _ in
      stubNetworkResponse([
        "data": [
          "hero": [
            "name": "Artoo",
            "__typename": "Droid"
          ]
        ]
      ])
      
      let noUpdatedResultExpectation = resultObserver.expectation(description: "Unrelated other query shouldn't trigger update")
      
      noUpdatedResultExpectation.isInverted = true
      
      client.fetch(query: HeroNameQuery(episode: .empire), cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [noUpdatedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryWithID() throws {
    client.cacheKeyForObject = { $0["id"] }
    
    let query = HeroNameWithIdQuery()
    
    let resultObserver = makeResultObserver(for: query)
    
    let watcher = GraphQLQueryWatcher(client: client, query: query, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from cache") { _ in
      mergeRecordsIntoCache([
        "QUERY_ROOT": ["hero": Reference(key: "2001")],
        "2001": [
          "id": "2001",
          "name": "R2-D2",
          "__typename": "Droid",
        ]
      ])
      
      let initialResultExpectation = resultObserver.expectation(description: "Initial result") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
      
      watcher.fetch(cachePolicy: .returnCacheDataDontFetch)
      
      wait(for: [initialResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch related query from server") { _ in
      stubNetworkResponse([
        "data": [
          "hero": [
            "id": "2001",
            "name": "Artoo",
            "__typename": "Droid"
          ]
        ]
      ])
      
      let updatedResultExpectation = resultObserver.expectation(description: "Updated result after fetching related query") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
      }
      
      client.fetch(query: HeroNameWithIdQuery(), cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [updatedResultExpectation], timeout: 1)
    }
  }

  func testWatchedListModifyingQueryWithID() throws {
    client.store.cacheKeyForObject = { $0["id"] }
    
    let query = HeroAndFriendsNamesWithIDsQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": Reference(key: "2001")],
      "2001": [
        "id": "2001",
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          Reference(key: "LS"),
          Reference(key: "HS"),
          Reference(key: "LO"),
        ],
      ],
      "LS": ["__typename": "Human", "id": "LS", "name": "Luke Skywalker"],
      "HS": ["__typename": "Human", "id": "HS", "name": "Han Solo"],
      "LO": ["__typename": "Human", "id": "LO", "name": "Leia Organa"],
    ])
    
    let resultObserver = makeResultObserver(for: query)
    
    let watcher = GraphQLQueryWatcher(client: client, query: query, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from cache") { _ in
      let initialResultExpectation = resultObserver.expectation(description: "Initial result") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        
        let friendsNames = graphQLResult.data?.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, [
          "Luke Skywalker",
          "Han Solo",
          "Leia Organa",
        ])
      }
      
      watcher.fetch(cachePolicy: .returnCacheDataDontFetch)
      
      wait(for: [initialResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch related query from server") { _ in
      stubNetworkResponse([
        "data": [
          "hero": [
            "id": "2001",
            "name": "R2-D2",
            "__typename": "Droid",
            "friends": [
              ["__typename": "Human", "id": "LO"],
              ["__typename": "Human", "id": "LS"],
            ]
          ]
        ]
      ])
      
      let updatedResultExpectation = resultObserver.expectation(description: "Updated result after fetching related query") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        
        let friendsNames = graphQLResult.data?.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, [
          "Leia Organa",
          "Luke Skywalker",
        ])
      }
      
      client.fetch(query: HeroAndFriendsIDsQuery(), cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [updatedResultExpectation], timeout: 1)
    }
  }

  func testWatchedQueryGetsUpdatedWithResultFromReadWriteTransaction() throws {
    let query = HeroAndFriendsNamesQuery()
    
    let resultObserver = makeResultObserver(for: query)
    
    let watcher = GraphQLQueryWatcher(client: client, query: query, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from cache") { _ in
      mergeRecordsIntoCache([
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
      ])
      
      let initialResultExpectation = resultObserver.expectation(description: "Initial result") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        
        let friendsNames = graphQLResult.data?.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, [
          "Luke Skywalker",
          "Han Solo",
          "Leia Organa",
        ])
      }
      
      watcher.fetch(cachePolicy: .returnCacheDataDontFetch)
      
      wait(for: [initialResultExpectation], timeout: 1)
    }
    
    runActivity("Update query in store") { _ in
      let updatedResultExpectation = resultObserver.expectation(description: "Updated result after direct store update") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
        
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, [
          "Luke Skywalker",
          "Han Solo",
          "Leia Organa",
        ])
      }
      
      let nameQuery = HeroNameQuery()
      
      client.store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: nameQuery) { (data: inout HeroNameQuery.Data) in
          data.hero?.name = "Artoo"
        }
      })
      
      wait(for: [updatedResultExpectation], timeout: 1)
    }
  }
  
  func testWatchedQueryDependentKeysAreUpdated() {
    client.store.cacheKeyForObject = { $0["id"] }
    
    let query = HeroAndFriendsNamesWithIDsQuery()
    
    let resultObserver = makeResultObserver(for: query)
    
    let watcher = GraphQLQueryWatcher(client: client, query: query, resultHandler: resultObserver.handler)
    defer { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      stubNetworkResponse([
        "data": [
          "hero": [
            "id": "0",
            "name": "R2-D2",
            "__typename": "Droid",
            "friends": [
              [
                "id": "10",
                "__typename": "Human",
                "name": "Luke Skywalker"
              ]
            ]
          ]
        ]
      ])
      
      let initialResultExpectation = resultObserver.expectation(description: "Initial result") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        
        let friendsNames = graphQLResult.data?.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, [
          "Luke Skywalker"
        ])
        
        let expectedDependentKeys: Set = [
          "0.__typename",
          "0.friends",
          "0.id",
          "0.name",
          "10.__typename",
          "10.id",
          "10.name",
          "QUERY_ROOT.hero",
        ]
        let actualDependentKeys = try XCTUnwrap(graphQLResult.dependentKeys)
        XCTAssertEqual(actualDependentKeys, expectedDependentKeys)
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [initialResultExpectation], timeout: 1)
    }
    
    runActivity("Update query in store") { _ in
      let updatedResultExpectation = resultObserver.expectation(description: "Updated result after direct store update") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, [
          "Luke Skywalker",
          "Jean-Luc Picard"
        ])
        
        let expectedDependentKeys: Set = [
          "0.__typename",
          "0.friends",
          "0.id",
          "0.name",
          "10.__typename",
          "10.id",
          "10.name",
          "11.__typename",
          "11.id",
          "11.name",
          "QUERY_ROOT.hero"
        ]
        let actualDependentKeys = try XCTUnwrap(graphQLResult.dependentKeys)
        XCTAssertEqual(actualDependentKeys, expectedDependentKeys)
      }
      
      client.store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: query) { (data: inout HeroAndFriendsNamesWithIDsQuery.Data) in
          data.hero?.friends?.append(try .init(jsonObject: [
            "id": "11",
            "__typename": "Human",
            "name": "Jean-Luc Picard"
          ]))
        }
      })
      
      wait(for: [updatedResultExpectation], timeout: 1)
    }
    
    runActivity("Fetch related query from server") { _ in
      stubNetworkResponse([
        "data": [
          "hero": [
            "id": "2",
            "name": "R2-D2",
            "__typename": "Droid",
            "friends": [
              [
                "id": "11",
                "__typename": "Human",
                "name": "Han Solo"
              ]
            ]
          ]
        ]
      ])
      
      let updatedResultExpectation = resultObserver.expectation(description: "Updated result after fetching related query") { result in
        let graphQLResult = try result.get()
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, [
          "Luke Skywalker",
          "Han Solo"
        ])
      }
      
      client.fetch(query: HeroAndFriendsNamesWithIDsQuery(episode: .newhope), cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [updatedResultExpectation], timeout: 1)
    }
  }
}

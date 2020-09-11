import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class WatchQueryTests: XCTestCase, CacheTesting {

  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  func testRefetchWatchedQuery() throws {
    let query = HeroNameQuery()

    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]

    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "name": "Artoo",
            "__typename": "Droid"
          ]
        ]
      ], store: store)
      let client = ApolloClient(networkTransport: networkTransport, store: store)

      var verifyResult: GraphQLResultHandler<HeroNameQuery.Data>

      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
        case .failure(let error):
          XCTFail("Unexpexcted error: \(error)")
        }
      }

      var expectation = self.expectation(description: "Fetching query")

      let watcher = client.watch(query: query) { result in
        verifyResult(result)
        expectation.fulfill()
      }

      waitForExpectations(timeout: 5, handler: nil)

      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Artoo")
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }

      expectation = self.expectation(description: "Refetching query")

      watcher.refetch()
      
      waitForExpectations(timeout: 5, handler: nil)
      
      watcher.cancel()
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

    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "name": "Artoo",
            "__typename": "Droid"
          ]
        ]
      ], store: store)
      let client = ApolloClient(networkTransport: networkTransport, store: store)

      let query = HeroAndFriendsNamesQuery()

      var verifyResult: GraphQLResultHandler<HeroAndFriendsNamesQuery.Data>

      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          guard let data = graphQLResult.data else {
            XCTFail("No data in graphQLResult!")
            return
          }
          
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }

      var expectation = self.expectation(description: "Fetching query")

      _ = client.watch(query: query) { result in
        verifyResult(result)
        expectation.fulfill()
      }

      waitForExpectations(timeout: 5, handler: nil)

      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          guard let data = graphQLResult.data else {
            XCTFail("No data in GraphQL result!")
            return
          }
          XCTAssertEqual(data.hero?.name, "Artoo")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, [
            "Luke Skywalker",
            "Han Solo",
            "Leia Organa",
          ])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }

      expectation = self.expectation(description: "Updated after fetching other query")

      client.fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData)

      waitForExpectations(timeout: 5, handler: nil)
    }
  }

  func testWatchedQueryGetsUpdatedWithListReorderingFromOtherQuery() throws {
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

    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      let networkTransport = MockNetworkTransport(body: [
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
      ], store: store)
      let client = ApolloClient(networkTransport: networkTransport, store: store)

      let query = HeroAndFriendsNamesQuery()

      var verifyResult: GraphQLResultHandler<HeroAndFriendsNamesQuery.Data>

      // verify initial state
      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          guard let data = graphQLResult.data else {
            XCTFail("No data in graphQLResult!")
            return
          }

          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }

      var expectation = self.expectation(description: "Fetching query")

      _ = client.watch(query: query) { result in
        verifyResult(result)
        expectation.fulfill()
      }

      waitForExpectations(timeout: 5, handler: nil)

      // verify cache update
      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          guard let data = graphQLResult.data else {
            XCTFail("No data in GraphQL result!")
            return
          }
          XCTAssertEqual(data.hero?.name, "Artoo")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, [
            "Luke Skywalker",
            "Leia Organa",
          ])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }

      expectation = self.expectation(description: "Updated after fetching other query")

      client.fetch(query: HeroAndFriendsNamesQuery(), cachePolicy: .fetchIgnoringCacheData)

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
    
    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "name": "Artoo",
            "__typename": "Droid"
          ]
        ]
      ], store: store)
      
      let client = ApolloClient(networkTransport: networkTransport, store: store)
      let query = HeroAndFriendsNamesQuery()

      let fetching = self.expectation(description: "Fetching query")
      var refetching: XCTestExpectation?
      
      let _ = client.watch(query: query) { result in
        guard refetching == nil else {
          return refetching!.fulfill()
        }
        
        defer {
          fetching.fulfill()
        }
        
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          
          guard let data = graphQLResult.data else {
            XCTFail("No data on graphQL result!")
            return
          }
          
          XCTAssertEqual(data.hero?.name, "R2-D2")
          
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          
          XCTAssertEqual(friendsNames, [
            "Luke Skywalker",
            "Han Solo",
            "Leia Organa",
          ])
          
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
      
      wait(for: [fetching], timeout: 5)
      
      refetching = self.expectation(description: "Refetching query")
      refetching?.isInverted = true
      
      client.fetch(query: HeroNameQuery(episode: .empire), cachePolicy: .fetchIgnoringCacheData)
      wait(for: [refetching!], timeout: 1)
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

    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "id": "2001",
            "name": "Luke Skywalker",
            "__typename": "Human"
          ]
        ]
        ], store: store)
      let client = ApolloClient(networkTransport: networkTransport, store: store)
      client.store.cacheKeyForObject = { $0["id"] }

      var verifyResult: GraphQLResultHandler<HeroNameWithIdQuery.Data>

      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }

      var expectation = self.expectation(description: "Fetching query")

      _ = client.watch(query: query) { result in
        verifyResult(result)
        expectation.fulfill()
      }

      waitForExpectations(timeout: 5, handler: nil)

      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }

      expectation = self.expectation(description: "Fetching other query")

      client.fetch(query: HeroNameWithIdQuery(), cachePolicy: .fetchIgnoringCacheData)

      waitForExpectations(timeout: 5, handler: nil)
    }
  }

  func testWatchedListModifyingQueryWithID() throws {
    let query = HeroAndFriendsNamesWithIDsQuery()
    let initialRecords: RecordSet = [
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
    ]

    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "id": "2001",
            "name": "Luke Skywalker",
            "__typename": "Human",
            "friends": [
              ["__typename": "Human", "id": "LO"],
              ["__typename": "Human", "id": "LS"],
            ]
          ]
        ]
      ], store: store)
      let client = ApolloClient(networkTransport: networkTransport, store: store)
      client.store.cacheKeyForObject = { $0["id"] }

      var verifyResult: GraphQLResultHandler<HeroAndFriendsNamesWithIDsQuery.Data>

      // verify initial cache state
      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
          let friendsNames = graphQLResult.data?.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, [
            "Luke Skywalker",
            "Han Solo",
            "Leia Organa",
          ])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }

      var expectation = self.expectation(description: "Fetching query")

      _ = client.watch(query: query, cachePolicy: .returnCacheDataDontFetch) { result in
        verifyResult(result)
        expectation.fulfill()
      }

      waitForExpectations(timeout: 5, handler: nil)

      // verify cache update
      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")

          let friendsNames = graphQLResult.data?.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, [
            "Leia Organa",
            "Luke Skywalker",
          ])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }

      expectation = self.expectation(description: "Fetching other query")

      client.fetch(query: HeroAndFriendsIDsQuery(), cachePolicy: .fetchIgnoringCacheData)

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
    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      let networkTransport = MockNetworkTransport(body: [:], store: store)

      let client = ApolloClient(networkTransport: networkTransport, store: store)
      let query = HeroAndFriendsNamesQuery()

      var verifyResult: GraphQLResultHandler<HeroAndFriendsNamesQuery.Data>

      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)

          guard let data = graphQLResult.data else {
            XCTFail("No data returned with GraphQL result!")
            return
          }

          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, [
            "Luke Skywalker",
            "Han Solo",
            "Leia Organa",
          ])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }

      var expectation = self.expectation(description: "Fetching query")

      _ = client.watch(query: query) { result in
        verifyResult(result)
        expectation.fulfill()
      }

      waitForExpectations(timeout: 5, handler: nil)

      let nameQuery = HeroNameQuery()
      expectation = self.expectation(description: "transaction'd")
      store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: nameQuery) { (data: inout HeroNameQuery.Data) in
          data.hero?.name = "Artoo"
        }
        expectation.fulfill()
      })
      self.waitForExpectations(timeout: 1, handler: nil)

      verifyResult = { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          guard let data = graphQLResult.data else {
            XCTFail("GraphqlResult had no data!")
            return
          }
          
          XCTAssertEqual(data.hero?.name, "Artoo")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, [
            "Luke Skywalker",
            "Han Solo",
            "Leia Organa",
          ])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }

      expectation = self.expectation(description: "Updated after fetching other query")
      client.fetch(query: HeroNameQuery(), cachePolicy: .fetchIgnoringCacheData)
      waitForExpectations(timeout: 5, handler: nil)
    }
  }
  
  func testWatchedQueryDependentKeysAreUpdated() {
    withCache { cache in
      let store = ApolloStore(cache: cache)
      store.cacheKeyForObject = { $0["id"] }
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "id": "0",
            "name": "Artoo",
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
      ], store: store)

      let client = ApolloClient(networkTransport: networkTransport, store: store)
      let query = HeroAndFriendsNamesWithIDsQuery()
      let hasPicardFriendExpecation = self.expectation(description: "Has friend named Jean-Luc Picard")
      let hasHanSoloFriendExpecation = self.expectation(description: "Has friend named Han Solo")
      let initialFetchExpectation = self.expectation(description: "Initial fetch")
      var expectedDependentKeys = [
        "0.__typename",
        "0.friends",
        "0.id",
        "0.name",
        "10.__typename",
        "10.id",
        "10.name",
        "QUERY_ROOT.hero",
      ]
      
      var fetchCount = 0
      let watcher = client.watch(query: query) { result in
        defer {
          if fetchCount == 0 {
            initialFetchExpectation.fulfill()
          }
          fetchCount += 1
        }
        switch result {
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.dependentKeys?.sorted(), expectedDependentKeys)
          guard let friends = graphQLResult.data?.hero?.friends else {
            XCTFail("404 friends not found")
            return
          }
          
          if friends.contains(where: { $0?.name == "Jean-Luc Picard" }) {
            hasPicardFriendExpecation.fulfill()
          }
          if friends.contains(where: { $0?.name == "Han Solo" }) {
            hasHanSoloFriendExpecation.fulfill()
          }
        case .failure(let error):
          XCTFail("Watcher error: \(error)")
        }
      }
      wait(for: [initialFetchExpectation], timeout: 1)
      
      /// Add an additional friend to the results so that the watcher for this query knows to look for updates to friend #11
      let updateInitialQueryExpectation = self.expectation(description: "Update initial query")
      store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: query) { (data: inout HeroAndFriendsNamesWithIDsQuery.Data) in
          data.hero?.friends?.append(try .init(jsonObject: [
            "id": "11",
            "__typename": "Human",
            "name": "Jean-Luc Picard"
          ]))
          updateInitialQueryExpectation.fulfill()
        }
      })
      
      /// The dependent keys should have changed here since we've now added a new friend to the user's friends.
      expectedDependentKeys = [
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
      
      wait(for: [updateInitialQueryExpectation, hasPicardFriendExpecation], timeout: 1)
      

      /// Send an update that updates friend #11 on a different query
      networkTransport.updateBody(to: [
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

      /// This fetch should trigger our watcher on friend #11
      client.fetch(query: HeroAndFriendsNamesWithIDsQuery(episode: .newhope), cachePolicy: .fetchIgnoringCacheData)
      
      self.wait(for: [hasHanSoloFriendExpecation], timeout: 1)
      
      watcher.cancel()
    }
  }
}

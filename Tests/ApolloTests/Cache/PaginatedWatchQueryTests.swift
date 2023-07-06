@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers
import Nimble
import StarWarsAPI
import XCTest

class PaginatedWatchQueryTests: XCTestCase, CacheDependentTesting {

  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }

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
    MockSchemaMetadata.stub_cacheKeyInfoForType_Object = IDCacheKeyProvider.resolver
  }

  override func tearDownWithError() throws {
    cache = nil
    server = nil
    client = nil

    try super.tearDownWithError()
  }

  struct HeroViewModel: Hashable {
    struct Friend: Hashable {
      let name: String
      let id: String
    }

    let name: String
    let friends: [Friend]
  }

  // MARK: - Tests

  // MARK: Custom Pagination Strategy

  func testMultiPageResults() {
    let query = HeroFriendsConnectionQuery(id: "2001", first: 2, after: .none)

    var results: [HeroViewModel] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: RelayPaginationStrategy(
        pageExtractionStrategy: RelayPageExtractor { data in
          .init(
            hasNextPage: data.character?.friendsConnection.pageInfo.hasNextPage ?? false,
            endCursor: data.character?.friendsConnection.pageInfo.endCursor
          )
        },
        outputTransformer: CustomDataTransformer(transform: { data in
          HeroViewModel(
            name: data.character?.name ?? "",
            friends: data.character?.friendsConnection.friends?.compactMap { friend in
              guard let friend else { return nil }
              return HeroViewModel.Friend(name: friend.name, id: friend.id)
            } ?? []
          )
        }),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsConnectionQuery(id: "2001", first: 2, after: pageInfo.endCursor ?? nil)
        },
        mergeStrategy: CustomPaginationMergeStrategy(transform: { response in
          HeroViewModel(
            name: response.mostRecent.name,
            friends: response.allResponses.flatMap { $0.friends }
          )
        }),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Han Solo",
                    "id": "1002",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMg==",
                  "hasNextPage": true
                ]
              ]
            ],
          ]
        ]
      }

      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
      XCTAssertEqual(watcher.strategy.pages.count, 2)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(hasNextPage: true, endCursor: "Y3Vyc29yMg=="),
      ])
      XCTAssertEqual(watcher.strategy.currentPage, .init(hasNextPage: true, endCursor: "Y3Vyc29yMg=="))
    }

    runActivity("Fetch second page") { _ in
      let secondPageExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }

      _ = watcher.fetchMore()
      wait(for: [secondPageExpectation], timeout: 1.0)

      XCTAssertEqual(results.count, 2)
      XCTAssertEqual(results, [
        HeroViewModel(name: "R2-D2", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker", id: "1000"),
          HeroViewModel.Friend(name: "Han Solo", id: "1002"),
        ]),
        HeroViewModel(name: "R2-D2", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker", id: "1000"),
          HeroViewModel.Friend(name: "Han Solo", id: "1002"),
          HeroViewModel.Friend(name: "Leia Organa", id: "1003"),
        ])
      ])
      XCTAssertEqual(watcher.strategy.pages.count, 3)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(hasNextPage: true, endCursor: "Y3Vyc29yMg=="),
        .init(hasNextPage: false, endCursor: "Y3Vyc29yMw=="),
      ])
    }
  }

  func testRefetchSecondPage() {
    let query = HeroFriendsConnectionQuery(id: "2001", first: 2, after: .none)

    var results: [HeroViewModel] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: RelayPaginationStrategy(
        pageExtractionStrategy: RelayPageExtractor(
          hasNextPagePath: \HeroFriendsConnectionQuery.Data.character?.friendsConnection.pageInfo.hasNextPage,
          endCursorPath: \HeroFriendsConnectionQuery.Data.character?.friendsConnection.pageInfo.endCursor
        ),
        outputTransformer: CustomDataTransformer(transform: { data in
          HeroViewModel(
            name: data.character?.name ?? "",
            friends: data.character?.friendsConnection.friends?.compactMap { friend in
              guard let friend else { return nil }
              return HeroViewModel.Friend(name: friend.name, id: friend.id)
            } ?? []
          )
        }),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsConnectionQuery(id: "2001", first: 2, after: pageInfo.endCursor ?? nil)
        },
        mergeStrategy: CustomPaginationMergeStrategy(transform: { response in
          HeroViewModel(
            name: response.mostRecent.name,
            friends: response.allResponses.flatMap { $0.friends }
          )
        }),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Han Solo",
                    "id": "1002",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMg==",
                  "hasNextPage": true
                ]
              ]
            ],
          ]
        ]
      }

      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
    }

    runActivity("Fetch second page") { _ in
      let secondPageExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }

      _ = watcher.fetchMore()
      wait(for: [secondPageExpectation], timeout: 1.0)

      XCTAssertEqual(results.count, 2)
      XCTAssertEqual(results, [
        HeroViewModel(name: "R2-D2", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker", id: "1000"),
          HeroViewModel.Friend(name: "Han Solo", id: "1002"),
        ]),
        HeroViewModel(name: "R2-D2", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker", id: "1000"),
          HeroViewModel.Friend(name: "Han Solo", id: "1002"),
          HeroViewModel.Friend(name: "Leia Organa", id: "1003"),
        ])
      ])
    }

    runActivity("Re-fetch second page") { _ in
      let secondPageExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }

      let page = watcher.strategy.pages[1]
      watcher.refresh(page: page)
      wait(for: [secondPageExpectation], timeout: 1.0)
    }
  }

  func testFetchAndRefetch() {
    let query = HeroFriendsConnectionQuery(id: "2001", first: 3, after: .none)

    var results: [HeroViewModel] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: RelayPaginationStrategy(
        pageExtractionStrategy: RelayPageExtractor(
          hasNextPagePath: \HeroFriendsConnectionQuery.Data.character?.friendsConnection.pageInfo.hasNextPage,
          endCursorPath: \HeroFriendsConnectionQuery.Data.character?.friendsConnection.pageInfo.endCursor
        ),
        outputTransformer: CustomDataTransformer(transform: { data in
          HeroViewModel(
            name: data.character?.name ?? "",
            friends: data.character?.friendsConnection.friends?.compactMap { friend in
              guard let friend else { return nil }
              return HeroViewModel.Friend(name: friend.name, id: friend.id)
            } ?? []
          )
        }),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsConnectionQuery(id: "2001", first: 3, after: pageInfo.endCursor ?? nil)
        },
        mergeStrategy: CustomPaginationMergeStrategy(transform: { response in
          HeroViewModel(
            name: response.mostRecent.name,
            friends: response.allResponses.flatMap { $0.friends }
          )
        }),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Han Solo",
                    "id": "1002",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
    }

    runActivity("Re-fetch from server") { _ in
      let refetchExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Han Solo",
                    "id": "1002",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }
      watcher.refetch()
      wait(for: [refetchExpectation], timeout: 1.0)

      XCTAssertEqual(results.count, 2)
      XCTAssertEqual(results, [
        HeroViewModel(name: "R2-D2", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker", id: "1000"),
          HeroViewModel.Friend(name: "Han Solo", id: "1002"),
          HeroViewModel.Friend(name: "Leia Organa", id: "1003"),
        ]),
        HeroViewModel(name: "R2-D2", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker", id: "1000"),
          HeroViewModel.Friend(name: "Han Solo", id: "1002"),
          HeroViewModel.Friend(name: "Leia Organa", id: "1003"),
        ])
      ])
    }
  }

  func testFetchAndLocalCacheUpdate() {
    let query = HeroFriendsConnectionQuery(id: "2001", first: 3, after: .none)
    var results: [HeroViewModel] = []
    // Once for the initial update, once for the local cache update
    let resultExpectation = expectation(description: "Results block has been updated")
    resultExpectation.expectedFulfillmentCount = 2
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: RelayPaginationStrategy(
        pageExtractionStrategy: RelayPageExtractor(
          hasNextPagePath: \HeroFriendsConnectionQuery.Data.character?.friendsConnection.pageInfo.hasNextPage,
          endCursorPath: \HeroFriendsConnectionQuery.Data.character?.friendsConnection.pageInfo.endCursor
        ),
        outputTransformer: CustomDataTransformer(transform: { data in
          HeroViewModel(
            name: data.character?.name ?? "",
            friends: data.character?.friendsConnection.friends?.compactMap { friend in
              guard let friend else { return nil }
              return HeroViewModel.Friend(name: friend.name, id: friend.id)
            } ?? []
          )
        }),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsConnectionQuery(id: "2001", first: 3, after: pageInfo.endCursor ?? nil)
        },
        mergeStrategy: CustomPaginationMergeStrategy(transform: { response in
          HeroViewModel(
            name: response.mostRecent.name,
            friends: response.allResponses.flatMap { $0.friends }
          )
        }),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
          resultExpectation.fulfill()
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Han Solo",
                    "id": "1002",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
    }

    runActivity("Local Cache Mutation") { _ in
      client.store.withinReadWriteTransaction { transaction in
        let cacheMutation = HeroFriendsConnectionLocalCacheMutation(id: "2001", first: 3, after: .none)
        try transaction.update(cacheMutation) { data in
          data.character?.name = "Marty McFly"
          data.character?.friendsConnection.friends?[0]?.name = "Doc Brown"
        }
      }

      wait(for: [resultExpectation], timeout: 1.0)
      XCTAssertEqual(results.count, 2)
      XCTAssertEqual(results, [
        HeroViewModel(name: "R2-D2", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker", id: "1000"),
          HeroViewModel.Friend(name: "Han Solo", id: "1002"),
          HeroViewModel.Friend(name: "Leia Organa", id: "1003"),
        ]),
        HeroViewModel(name: "Marty McFly", friends: [
          HeroViewModel.Friend(name: "Doc Brown", id: "1000"),
          HeroViewModel.Friend(name: "Han Solo", id: "1002"),
          HeroViewModel.Friend(name: "Leia Organa", id: "1003"),
        ])
      ])
    }
  }

  func testFetchAndLocalCacheObjectDeletion() {
    let query = HeroFriendsConnectionQuery(id: "2001", first: 3, after: .none)
    var results: [HeroViewModel] = []
    // Once for the initial update, once for the local cache update
    let resultExpectation = expectation(description: "Results block has been updated")
    resultExpectation.expectedFulfillmentCount = 2
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: RelayPaginationStrategy(
        pageExtractionStrategy: RelayPageExtractor(
          hasNextPagePath: \HeroFriendsConnectionQuery.Data.character?.friendsConnection.pageInfo.hasNextPage,
          endCursorPath: \HeroFriendsConnectionQuery.Data.character?.friendsConnection.pageInfo.endCursor
        ),
        outputTransformer: CustomDataTransformer(transform: { data in
          HeroViewModel(
            name: data.character?.name ?? "",
            friends: data.character?.friendsConnection.friends?.compactMap { friend in
              guard let friend else { return nil }
              return HeroViewModel.Friend(name: friend.name, id: friend.id)
            } ?? []
          )
        }),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsConnectionQuery(id: "2001", first: 3, after: pageInfo.endCursor ?? nil)
        },
        mergeStrategy: CustomPaginationMergeStrategy(transform: { response in
          HeroViewModel(
            name: response.mostRecent.name,
            friends: response.allResponses.flatMap { $0.friends }
          )
        }),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
          resultExpectation.fulfill()
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Han Solo",
                    "id": "1002",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
    }

    runActivity("Local Cache Mutation: Delete Friends") { _ in
      client.store.withinReadWriteTransaction { transaction in
        let cacheMutation = HeroFriendsConnectionLocalCacheMutation(id: "2001", first: 3, after: .none)
        try transaction.update(cacheMutation) { data in
          data.character?.name = "Marty McFly"
          data.character?.friendsConnection.friends?.removeAll()
        }
      }

      wait(for: [resultExpectation], timeout: 1.0)
      XCTAssertEqual(results.count, 2)
      XCTAssertEqual(results, [
        HeroViewModel(name: "R2-D2", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker", id: "1000"),
          HeroViewModel.Friend(name: "Han Solo", id: "1002"),
          HeroViewModel.Friend(name: "Leia Organa", id: "1003"),
        ]),
        HeroViewModel(name: "Marty McFly", friends: [])
      ])
    }
  }

  func testFetchAndLocalCacheUpdateWithHeroNameMutation() {
    let query = HeroFriendsConnectionQuery(id: "2001", first: 3, after: .none)
    var results: [HeroViewModel] = []
    // Once for the initial update, once for the local cache update
    let resultExpectation = expectation(description: "Results block has been updated")
    resultExpectation.expectedFulfillmentCount = 2
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: RelayPaginationStrategy(
        pageExtractionStrategy: RelayPageExtractor(
          hasNextPagePath: \HeroFriendsConnectionQuery.Data.character?.friendsConnection.pageInfo.hasNextPage,
          endCursorPath: \HeroFriendsConnectionQuery.Data.character?.friendsConnection.pageInfo.endCursor
        ),
        outputTransformer: CustomDataTransformer(transform: { data in
          HeroViewModel(
            name: data.character?.name ?? "",
            friends: data.character?.friendsConnection.friends?.compactMap { friend in
              guard let friend else { return nil }
              return HeroViewModel.Friend(name: friend.name, id: friend.id)
            } ?? []
          )
        }),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsConnectionQuery(id: "2001", first: 3, after: pageInfo.endCursor ?? nil)
        },
        mergeStrategy: CustomPaginationMergeStrategy(transform: { response in
          HeroViewModel(
            name: response.mostRecent.name,
            friends: response.allResponses.flatMap { $0.friends }
          )
        }),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
          resultExpectation.fulfill()
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Han Solo",
                    "id": "1002",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
    }

    runActivity("Local Cache Mutation") { _ in
      client.store.withinReadWriteTransaction { transaction in
        let cacheMutation = HeroNameLocalCacheMutation(id: "2001")
        try! transaction.update(cacheMutation) { data in
          data.character?.name = "C3PO"
        }
      }

      wait(for: [resultExpectation], timeout: 1.0)
      XCTAssertEqual(results.count, 2)
      XCTAssertEqual(results, [
        HeroViewModel(name: "R2-D2", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker", id: "1000"),
          HeroViewModel.Friend(name: "Han Solo", id: "1002"),
          HeroViewModel.Friend(name: "Leia Organa", id: "1003"),
        ]),
        HeroViewModel(name: "C3PO", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker", id: "1000"),
          HeroViewModel.Friend(name: "Han Solo", id: "1002"),
          HeroViewModel.Friend(name: "Leia Organa", id: "1003"),
        ])
      ])
    }
  }

  // MARK: Simple Pagination Strategy

  func testSimpleMultipageFetch() {
    let query = HeroFriendsConnectionQuery(id: "2001", first: 2, after: .none)

    var results: [HeroFriendsConnectionQuery.Data] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: RelayPaginationStrategy(
        pageExtractionStrategy: RelayPageExtractor { data in
            .init(
              hasNextPage: data.character?.friendsConnection.pageInfo.hasNextPage ?? false,
              endCursor: data.character?.friendsConnection.pageInfo.endCursor
            )
        },
        outputTransformer: PassthroughDataTransformer(),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsConnectionQuery(id: "2001", first: 2, after: pageInfo.endCursor ?? nil)
        },
        mergeStrategy: SimplePaginationMergeStrategy(),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Han Solo",
                    "id": "1002",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMg==",
                  "hasNextPage": true
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
      XCTAssertEqual(watcher.strategy.pages.count, 2)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(hasNextPage: true, endCursor: "Y3Vyc29yMg=="),
      ])
      guard let firstResult = results.first else { return XCTFail() }
      XCTAssertEqual(firstResult.character?.friendsConnection.totalCount, 3)
      XCTAssertEqual(firstResult.character?.friendsConnection.friends?.count, 2)
    }

    runActivity("Fetch second page") { _ in
      let secondPageExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }

      _ = watcher.fetchMore()
      wait(for: [secondPageExpectation], timeout: 1.0)

      XCTAssertEqual(results.count, 2)
      guard let lastResult = results.last else { return XCTFail() }
      XCTAssertEqual(lastResult.character?.friendsConnection.totalCount, 3)
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?.count, 3)
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?[0]?.name, "Luke Skywalker")
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?[1]?.name, "Han Solo")
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?[2]?.name, "Leia Organa")
      XCTAssertEqual(watcher.strategy.pages.count, 3)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(hasNextPage: true, endCursor: "Y3Vyc29yMg=="),
        .init(hasNextPage: false, endCursor: "Y3Vyc29yMw=="),
      ])
    }
  }

  func testTargetedMultipageFetch() {
    let query = HeroFriendsConnectionQuery(id: "2001", first: 2, after: .none)

    var results: [HeroFriendsConnectionQuery.Data] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: RelayPaginationStrategy(
        pageExtractionStrategy: RelayPageExtractor { data in
            .init(
              hasNextPage: data.character?.friendsConnection.pageInfo.hasNextPage ?? false,
              endCursor: data.character?.friendsConnection.pageInfo.endCursor
            )
        },
        outputTransformer: PassthroughDataTransformer(),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsConnectionQuery(id: "2001", first: 2, after: pageInfo.endCursor ?? nil)
        },
        mergeStrategy: TargetedPaginationMergeStrategy(targetedKeyPath: \.character?.friendsConnection.friends),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Han Solo",
                    "id": "1002",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMg==",
                  "hasNextPage": true
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
      XCTAssertEqual(watcher.strategy.pages.count, 2)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(hasNextPage: true, endCursor: "Y3Vyc29yMg=="),
      ])
      guard let firstResult = results.first else { return XCTFail() }
      XCTAssertEqual(firstResult.character?.friendsConnection.totalCount, 3)
      XCTAssertEqual(firstResult.character?.friendsConnection.friends?.count, 2)
    }

    runActivity("Fetch second page") { _ in
      let secondPageExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }

      _ = watcher.fetchMore()
      wait(for: [secondPageExpectation], timeout: 1.0)

      XCTAssertEqual(results.count, 2)
      guard let lastResult = results.last else { return XCTFail() }
      XCTAssertEqual(lastResult.character?.friendsConnection.totalCount, 3)
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?.count, 3)
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?[0]?.name, "Luke Skywalker")
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?[1]?.name, "Han Solo")
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?[2]?.name, "Leia Organa")
      XCTAssertEqual(watcher.strategy.pages.count, 3)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(hasNextPage: true, endCursor: "Y3Vyc29yMg=="),
        .init(hasNextPage: false, endCursor: "Y3Vyc29yMw=="),
      ])
    }
  }

  func testSimpleRefetchSecondPage() {
    let query = HeroFriendsConnectionQuery(id: "2001", first: 2, after: .none)

    var results: [HeroFriendsConnectionQuery.Data] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: RelayPaginationStrategy(
        pageExtractionStrategy: RelayPageExtractor { data in
            .init(
              hasNextPage: data.character?.friendsConnection.pageInfo.hasNextPage ?? false,
              endCursor: data.character?.friendsConnection.pageInfo.endCursor
            )
        },
        outputTransformer: PassthroughDataTransformer(),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsConnectionQuery(id: "2001", first: 2, after: pageInfo.endCursor ?? nil)
        },
        mergeStrategy: SimplePaginationMergeStrategy(),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Han Solo",
                    "id": "1002",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMg==",
                  "hasNextPage": true
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
      XCTAssertEqual(watcher.strategy.pages.count, 2)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(hasNextPage: true, endCursor: "Y3Vyc29yMg=="),
      ])
      guard let firstResult = results.first else { return XCTFail() }
      XCTAssertEqual(firstResult.character?.friendsConnection.totalCount, 3)
      XCTAssertEqual(firstResult.character?.friendsConnection.friends?.count, 2)
    }

    runActivity("Fetch second page") { _ in
      let secondPageExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }

      _ = watcher.fetchMore()
      wait(for: [secondPageExpectation], timeout: 1.0)

      XCTAssertEqual(results.count, 2)
      guard let lastResult = results.last else { return XCTFail() }
      XCTAssertEqual(lastResult.character?.friendsConnection.totalCount, 3)
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?.count, 3)
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?[0]?.name, "Luke Skywalker")
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?[1]?.name, "Han Solo")
      XCTAssertEqual(lastResult.character?.friendsConnection.friends?[2]?.name, "Leia Organa")
      XCTAssertEqual(watcher.strategy.pages.count, 3)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(hasNextPage: true, endCursor: "Y3Vyc29yMg=="),
        .init(hasNextPage: false, endCursor: "Y3Vyc29yMw=="),
      ])
    }

    runActivity("Re-fetch second page") { _ in
      let secondPageExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }

      let page = watcher.strategy.pages[1]
      watcher.refresh(page: page)
      wait(for: [secondPageExpectation], timeout: 1.0)
    }
  }

  func testSimpleFetchAndLocalCacheUpdate() {
    let query = HeroFriendsConnectionQuery(id: "2001", first: 3, after: .none)

    var results: [HeroFriendsConnectionQuery.Data] = []
    // Once for the initial update, once for the local cache update
    let resultExpectation = expectation(description: "Results block has been updated")
    resultExpectation.expectedFulfillmentCount = 2
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: RelayPaginationStrategy(
        pageExtractionStrategy: RelayPageExtractor { data in
            .init(
              hasNextPage: data.character?.friendsConnection.pageInfo.hasNextPage ?? false,
              endCursor: data.character?.friendsConnection.pageInfo.endCursor
            )
        },
        outputTransformer: PassthroughDataTransformer(),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsConnectionQuery(id: "2001", first: 3, after: pageInfo.endCursor ?? nil)
        },
        mergeStrategy: SimplePaginationMergeStrategy(),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
          resultExpectation.fulfill()
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsConnectionQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "__typename": "FriendsConnection",
                "totalCount": 3,
                "friends": [
                  [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Han Solo",
                    "id": "1002",
                  ],
                  [
                    "__typename": "Human",
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "__typename": "PageInfo",
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
      XCTAssertEqual(watcher.strategy.pages.count, 2)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(hasNextPage: false, endCursor: "Y3Vyc29yMw=="),
      ])
      guard let firstResult = results.first else { return XCTFail() }
      XCTAssertEqual(firstResult.character?.friendsConnection.totalCount, 3)
      XCTAssertEqual(firstResult.character?.friendsConnection.friends?.count, 3)
    }

    runActivity("Local Cache Mutation") { _ in
      client.store.withinReadWriteTransaction { transaction in
        let cacheMutation = HeroFriendsConnectionLocalCacheMutation(id: "2001", first: 3, after: .none)
        try transaction.update(cacheMutation) { data in
          data.character?.name = "Marty McFly"
          data.character?.friendsConnection.friends?[0]?.name = "Doc Brown"
        }
      }
    }

    wait(for: [resultExpectation], timeout: 1.0)
    XCTAssertEqual(results.count, 2)
    guard let lastResult = results.last else { return XCTFail() }
    XCTAssertEqual(lastResult.character?.name, "Marty McFly")
    XCTAssertEqual(lastResult.character?.friendsConnection.friends?.first??.name, "Doc Brown")
  }

  // MARK: Offset Simple Paginated Strategy

  func testOffsetSimpleMultipageFetch() {
    let query = HeroFriendsOffsetPaginatedQuery(id: "2001", limit: 2, offset: 0)
    var results: [HeroFriendsOffsetPaginatedQuery.Data] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: OffsetPaginationStrategy(
        pageSize: 2,
        pageExtractionStrategy: OffsetPageExtractor { (input: OffsetPageExtractor<HeroFriendsOffsetPaginatedQuery>.Input) in
          let count = input.data.character?.friendsPaginated?.count ?? 0
          return .init(
            offset: input.offset + count,
            hasNextPage: count == input.pageSize
          )
        },
        outputTransformer: PassthroughDataTransformer(),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsOffsetPaginatedQuery(id: "2001", limit: 2, offset: pageInfo.offset)
        },
        mergeStrategy: SimplePaginationMergeStrategy(),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsOffsetPaginatedQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsPaginated": [
                [
                  "__typename": "Human",
                  "name": "Luke Skywalker",
                  "id": "1000",
                ],
                [
                  "__typename": "Human",
                  "name": "Han Solo",
                  "id": "1002",
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
      XCTAssertEqual(watcher.strategy.pages.count, 2)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(offset: 2, hasNextPage: true),
      ])
      guard let firstResult = results.first else { return XCTFail() }
      XCTAssertEqual(firstResult.character?.friendsPaginated?.count, 2)
    }

    runActivity("Fetch second page") { _ in
      let secondPageExpectation = server.expect(HeroFriendsOffsetPaginatedQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsPaginated": [
                [
                  "__typename": "Human",
                  "name": "Leia Organa",
                  "id": "1003",
                ]
              ]
            ],
          ]
        ]
      }

      _ = watcher.fetchMore()
      wait(for: [secondPageExpectation], timeout: 1.0)

      XCTAssertEqual(results.count, 2)
      guard let lastResult = results.last else { return XCTFail() }
      XCTAssertEqual(lastResult.character?.friendsPaginated?.count, 3)
      XCTAssertEqual(lastResult.character?.friendsPaginated?[0]?.name, "Luke Skywalker")
      XCTAssertEqual(lastResult.character?.friendsPaginated?[1]?.name, "Han Solo")
      XCTAssertEqual(lastResult.character?.friendsPaginated?[2]?.name, "Leia Organa")
      XCTAssertEqual(watcher.strategy.pages.count, 3)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(offset: 2, hasNextPage: true),
        .init(offset: 3, hasNextPage: false),
      ])
    }
  }

  func testOffsetTargetedMultipageFetch() {
    let query = HeroFriendsOffsetPaginatedQuery(id: "2001", limit: 2, offset: 0)
    var results: [HeroFriendsOffsetPaginatedQuery.Data] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: OffsetPaginationStrategy(
        pageSize: 2,
        pageExtractionStrategy: OffsetPageExtractor(arrayKeyPath: \.character?.friendsPaginated),
        outputTransformer: PassthroughDataTransformer(),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsOffsetPaginatedQuery(id: "2001", limit: 2, offset: pageInfo.offset)
        },
        mergeStrategy: TargetedPaginationMergeStrategy(targetedKeyPath: \.character?.friendsPaginated),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsOffsetPaginatedQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsPaginated": [
                [
                  "__typename": "Human",
                  "name": "Luke Skywalker",
                  "id": "1000",
                ],
                [
                  "__typename": "Human",
                  "name": "Han Solo",
                  "id": "1002",
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
      XCTAssertEqual(watcher.strategy.pages.count, 2)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(offset: 2, hasNextPage: true),
      ])
      guard let firstResult = results.first else { return XCTFail() }
      XCTAssertEqual(firstResult.character?.friendsPaginated?.count, 2)
    }

    runActivity("Fetch second page") { _ in
      let secondPageExpectation = server.expect(HeroFriendsOffsetPaginatedQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsPaginated": [
                [
                  "__typename": "Human",
                  "name": "Leia Organa",
                  "id": "1003",
                ]
              ]
            ],
          ]
        ]
      }

      _ = watcher.fetchMore()
      wait(for: [secondPageExpectation], timeout: 1.0)

      XCTAssertEqual(results.count, 2)
      guard let lastResult = results.last else { return XCTFail() }
      XCTAssertEqual(lastResult.character?.friendsPaginated?.count, 3)
      XCTAssertEqual(lastResult.character?.friendsPaginated?[0]?.name, "Luke Skywalker")
      XCTAssertEqual(lastResult.character?.friendsPaginated?[1]?.name, "Han Solo")
      XCTAssertEqual(lastResult.character?.friendsPaginated?[2]?.name, "Leia Organa")
      XCTAssertEqual(watcher.strategy.pages.count, 3)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(offset: 2, hasNextPage: true),
        .init(offset: 3, hasNextPage: false),
      ])
    }
  }

  func testOffsetSimpleRefetchPage() {
    let pageSize = 3
    let query = HeroFriendsOffsetPaginatedQuery(id: "2001", limit: pageSize, offset: 0)
    var results: [HeroFriendsOffsetPaginatedQuery.Data] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: OffsetPaginationStrategy(
        pageSize: pageSize,
        pageExtractionStrategy: OffsetPageExtractor(arrayKeyPath: \.character?.friendsPaginated),
        outputTransformer: PassthroughDataTransformer(),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsOffsetPaginatedQuery(id: "2001", limit: pageSize, offset: pageInfo.offset)
        },
        mergeStrategy: SimplePaginationMergeStrategy(),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsOffsetPaginatedQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsPaginated": [
                [
                  "__typename": "Human",
                  "name": "Luke Skywalker",
                  "id": "1000",
                ],
                [
                  "__typename": "Human",
                  "name": "Han Solo",
                  "id": "1002",
                ],
                [
                  "__typename": "Human",
                  "name": "Leia Organa",
                  "id": "1003",
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
      XCTAssertEqual(watcher.strategy.pages.count, 2)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(offset: 3, hasNextPage: true),
      ])
      guard let firstResult = results.first else { return XCTFail() }
      XCTAssertEqual(firstResult.character?.friendsPaginated?.count, 3)
    }

    runActivity("Re-fetch") { _ in
      let refreshExpectation = server.expect(HeroFriendsOffsetPaginatedQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsPaginated": [
                [
                  "__typename": "Human",
                  "name": "Luke Skywalker",
                  "id": "1000",
                ],
                [
                  "__typename": "Human",
                  "name": "Han Solo",
                  "id": "1002",
                ],
                [
                  "__typename": "Human",
                  "name": "Leia Organa",
                  "id": "1003",
                ]
              ]
            ],
          ]
        ]
      }

      watcher.refresh(page: nil)
      wait(for: [refreshExpectation], timeout: 1.0)
    }
  }

  func testOffsetSimpleFetchAndLocalCacheUpdate() {
    let pageSize = 3
    let query = HeroFriendsOffsetPaginatedQuery(id: "2001", limit: pageSize, offset: 0)
    var results: [HeroFriendsOffsetPaginatedQuery.Data] = []
    // Once for the initial update, once for the local cache update
    let resultExpectation = expectation(description: "Results block has been updated")
    resultExpectation.expectedFulfillmentCount = 2
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      strategy: OffsetPaginationStrategy(
        pageSize: pageSize,
        pageExtractionStrategy: OffsetPageExtractor(arrayKeyPath: \.character?.friendsPaginated),
        outputTransformer: PassthroughDataTransformer(),
        nextPageStrategy: CustomNextPageStrategy { pageInfo in
          HeroFriendsOffsetPaginatedQuery(id: "2001", limit: pageSize, offset: pageInfo.offset)
        },
        mergeStrategy: SimplePaginationMergeStrategy(),
        resultHandler: { result in
          guard case let .success(value) = result else { return XCTFail() }
          results.append(value.value)
          resultExpectation.fulfill()
        }
      ),
      initialQuery: query
    )
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(HeroFriendsOffsetPaginatedQuery.self) { _ in
        [
          "data": [
            "character": [
              "__typename": "Droid",
              "id": "2001",
              "name": "R2-D2",
              "friendsPaginated": [
                [
                  "__typename": "Human",
                  "name": "Luke Skywalker",
                  "id": "1000",
                ],
                [
                  "__typename": "Human",
                  "name": "Han Solo",
                  "id": "1002",
                ],
                [
                  "__typename": "Human",
                  "name": "Leia Organa",
                  "id": "1003",
                ]
              ]
            ],
          ]
        ]
      }
      watcher.fetch()
      wait(for: [serverExpectation], timeout: 1.0)
      XCTAssertEqual(watcher.strategy.pages.count, 2)
      XCTAssertEqual(watcher.strategy.pages, [
        nil,
        .init(offset: 3, hasNextPage: true)
      ])
      guard let firstResult = results.first else { return XCTFail() }
      XCTAssertEqual(firstResult.character?.friendsPaginated?.count, 3)
    }

    runActivity("Local Cache Mutation") { _ in
      client.store.withinReadWriteTransaction { transaction in
        let cacheMutation = HeroFriendsPaginatedLocalCacheMutation(id: "2001", limit: pageSize, offset: 0)
        try transaction.update(cacheMutation) { data in
          data.character?.name = "Marty McFly"
        }
      }
    }

    wait(for: [resultExpectation], timeout: 1.0)
    XCTAssertEqual(results.count, 2)
    guard let lastResult = results.last else { return XCTFail() }
    XCTAssertEqual(lastResult.character?.name, "Marty McFly")
  }

}

@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers
import Nimble
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

  struct HeroViewModel: Equatable {
    struct Friend: Equatable {
      let name: String
      let id: String
    }

    let name: String
    let friends: [Friend]
  }

  // MARK: - Tests

  func testMultiPageResults() {
    let query = MockQuery<MockPaginatedSelectionSet>()
    query.__variables = ["id": "2001", "first": 2, "after": GraphQLNullable<String>.null]

    var results: [HeroViewModel] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      query: query
    ) { pageInfo in
      let query = MockQuery<MockPaginatedSelectionSet>()
      query.__variables = ["id": "2001", "first": 2, "after": pageInfo.endCursor ?? GraphQLNullable<String>.null]
      return query
    } transform: { data in
      (
        HeroViewModel(
          name: data.hero.name,
          friends: data.hero.friendsConnection.friends.map {
            HeroViewModel.Friend(name: $0.name, id: $0.id)
          }
        ),
        GraphQLPaginatedQueryWatcher.Page(
          hasNextPage: data.hero.friendsConnection.pageInfo.hasNextPage,
          endCursor: data.hero.friendsConnection.pageInfo.endCursor
        )
      )
    } nextPageTransform: { response in
      return HeroViewModel(
        name: response.mostRecent.name,
        friends: response.allResponses.flatMap { $0.friends }
      )
    } onReceiveResults: { result in
      guard case let .success(value) = result else { return XCTFail() }
      results.append(value)
    }
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
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
      XCTAssertEqual(watcher.pages.count, 2)
      XCTAssertEqual(watcher.pages, [
        nil,
        .init(hasNextPage: true, endCursor: "Y3Vyc29yMg=="),
      ])
    }

    runActivity("Fetch second page") { _ in
      let secondPageExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
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
      XCTAssertEqual(watcher.pages.count, 3)
      XCTAssertEqual(watcher.pages, [
        nil,
        .init(hasNextPage: true, endCursor: "Y3Vyc29yMg=="),
        .init(hasNextPage: false, endCursor: "Y3Vyc29yMw=="),
      ])
    }
  }

  func testRefetchSecondPage() {
    let query = MockQuery<MockPaginatedSelectionSet>()
    query.__variables = ["id": "2001", "first": 2, "after": GraphQLNullable<String>.null]

    var results: [HeroViewModel] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      query: query
    ) { pageInfo in
      let query = MockQuery<MockPaginatedSelectionSet>()
      query.__variables = ["id": "2001", "first": 2, "after": pageInfo.endCursor ?? GraphQLNullable<String>.null]
      return query
    } transform: { data in
      (
        HeroViewModel(
          name: data.hero.name,
          friends: data.hero.friendsConnection.friends.map {
            HeroViewModel.Friend(name: $0.name, id: $0.id)
          }
        ),
        GraphQLPaginatedQueryWatcher.Page(
          hasNextPage: data.hero.friendsConnection.pageInfo.hasNextPage,
          endCursor: data.hero.friendsConnection.pageInfo.endCursor
        )
      )
    } nextPageTransform: { response in
      return HeroViewModel(
        name: response.mostRecent.name,
        friends: response.allResponses.flatMap { $0.friends }
      )
    } onReceiveResults: { result in
      guard case let .success(value) = result else { return XCTFail() }
      results.append(value)
    }
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
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
      let secondPageExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
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
      let secondPageExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
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

      let page = watcher.pages[1]
      watcher.refresh(page: page)
      wait(for: [secondPageExpectation], timeout: 1.0)
    }
  }

  func testFetchAndRefetch() {
    let query = MockQuery<MockPaginatedSelectionSet>()
    query.__variables = ["id": "2001", "first": 3, "after": GraphQLNullable<String>.null]

    var results: [HeroViewModel] = []
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      query: query
    ) { pageInfo in
      let query = MockQuery<MockPaginatedSelectionSet>()
      query.__variables = ["id": "2001", "first": 3, "after": pageInfo.endCursor ?? GraphQLNullable<String>.null]
      return query
    } transform: { data in
      (
        HeroViewModel(
          name: data.hero.name,
          friends: data.hero.friendsConnection.friends.map {
            HeroViewModel.Friend(name: $0.name, id: $0.id)
          }
        ),
        GraphQLPaginatedQueryWatcher.Page(
          hasNextPage: data.hero.friendsConnection.pageInfo.hasNextPage,
          endCursor: data.hero.friendsConnection.pageInfo.endCursor
        )
      )
    } nextPageTransform: { response in
      return HeroViewModel(
        name: response.mostRecent.name,
        friends: response.allResponses.flatMap { $0.friends }
      )
    } onReceiveResults: { result in
      guard case let .success(value) = result else { return XCTFail() }
      results.append(value)
    }
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
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
      let refetchExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
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
    let query = MockQuery<MockPaginatedSelectionSet>()
    query.__variables = ["id": "2001", "first": 3, "after": GraphQLNullable<String>.null]
    var results: [HeroViewModel] = []
    // Once for the initial update, once for the local cache update
    let resultExpectation = expectation(description: "Results block has been updated")
    resultExpectation.expectedFulfillmentCount = 2
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      query: query
    ) { pageInfo in
      let query = MockQuery<MockPaginatedSelectionSet>()
      query.__variables = ["id": "2001", "first": 3, "after": pageInfo.endCursor ?? GraphQLNullable<String>.null]
      return query
    } transform: { data in
      (
        HeroViewModel(
          name: data.hero.name,
          friends: data.hero.friendsConnection.friends.map {
            HeroViewModel.Friend(name: $0.name, id: $0.id)
          }
        ),
        GraphQLPaginatedQueryWatcher.Page(
          hasNextPage: data.hero.friendsConnection.pageInfo.hasNextPage,
          endCursor: data.hero.friendsConnection.pageInfo.endCursor
        )
      )
    } nextPageTransform: { response in
      return HeroViewModel(
        name: response.mostRecent.name,
        friends: response.allResponses.flatMap { $0.friends }
      )
    } onReceiveResults: { result in
      guard case let .success(value) = result else { return XCTFail() }
      results.append(value)
      resultExpectation.fulfill()
    }
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
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
        let cacheMutation = MockLocalCacheMutation<LocalCacheMutationSelection>()
        cacheMutation.__variables = ["id": "2001", "first": 3, "after": GraphQLNullable<String>.null]
        try transaction.update(cacheMutation) { data in
          data.hero?.name = "Marty McFly"
          data.hero?.friendsConnection.friends[0].name = "Doc Brown"
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
    let query = MockQuery<MockPaginatedSelectionSet>()
    query.__variables = ["id": "2001", "first": 3, "after": GraphQLNullable<String>.null]
    var results: [HeroViewModel] = []
    // Once for the initial update, once for the local cache update
    let resultExpectation = expectation(description: "Results block has been updated")
    resultExpectation.expectedFulfillmentCount = 2
    let watcher = GraphQLPaginatedQueryWatcher(
      client: client,
      query: query
    ) { pageInfo in
      let query = MockQuery<MockPaginatedSelectionSet>()
      query.__variables = ["id": "2001", "first": 3, "after": pageInfo.endCursor ?? GraphQLNullable<String>.null]
      return query
    } transform: { data in
      (
        HeroViewModel(
          name: data.hero.name,
          friends: data.hero.friendsConnection.friends.map {
            HeroViewModel.Friend(name: $0.name, id: $0.id)
          }
        ),
        GraphQLPaginatedQueryWatcher.Page(
          hasNextPage: data.hero.friendsConnection.pageInfo.hasNextPage,
          endCursor: data.hero.friendsConnection.pageInfo.endCursor
        )
      )
    } nextPageTransform: { response in
      return HeroViewModel(
        name: response.mostRecent.name,
        friends: response.allResponses.flatMap { $0.friends }
      )
    } onReceiveResults: { result in
      guard case let .success(value) = result else { return XCTFail() }
      results.append(value)
      resultExpectation.fulfill()
    }
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
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
        let cacheMutation = MockLocalCacheMutation<LocalCacheMutationSelection>()
        cacheMutation.__variables = ["id": "2001", "first": 3, "after": GraphQLNullable<String>.null]
        try transaction.update(cacheMutation) { data in
          data.hero?.name = "Marty McFly"
          data.hero?.friendsConnection.friends.removeAll()
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
}

// MARK: - Mock Selection Sets

// MARK: Mock Paginated Query

private class MockPaginatedSelectionSet: MockSelectionSet {
  override class var __selections: [Selection] { [
    .field("hero", Hero?.self, arguments: ["id": .variable("id")])
  ]}

  var hero: Hero { __data["hero"] }

  class Hero: MockSelectionSet {
    override class var __selections: [Selection] {[
      .field("__typename", String.self),
      .field("id", String.self),
      .field("name", String.self),
      .field("friendsConnection", FriendsConnection.self, arguments: [
        "first": .variable("first"),
        "after": .variable("after")
      ])
    ]}

    var name: String { __data["name"] }
    var id: String { __data["id"] }
    var friendsConnection: FriendsConnection { __data["friendsConnection"] }

    class FriendsConnection: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .field("totalCount", Int.self),
        .field("friends", [Character].self),
        .field("pageInfo", PageInfo.self)
      ]}

      var totalCount: Int { __data["totalCount"] }
      var friends: [Character] { __data["friends"] }
      var pageInfo: PageInfo { __data["pageInfo"] }

      class Character: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("id", String.self),
        ]}

        var name: String { __data["name"] }
        var id: String { __data["id"] }
      }

      class PageInfo: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("__typename", String.self),
          .field("endCursor", Optional<String>.self),
          .field("hasNextPage", Bool.self)
        ]}

        var endCursor: String? { __data["endCursor"] }
        var hasNextPage: Bool { __data["hasNextPage"] }
      }
    }
  }
}

// MARK: Mock Local Cache Mutation

private struct LocalCacheMutationSelection: MockMutableRootSelectionSet {
  public var __data: DataDict = .empty()
  init(_dataDict: DataDict) { __data = _dataDict }
  static var __selections: [Selection] { [
    .field("hero", Hero?.self, arguments: ["id": .variable("id")])
  ]}

  var hero: Hero? {
    get { __data["hero"] }
    set { __data["hero"] = newValue }
  }

  struct Hero: MockMutableRootSelectionSet {
    public var __data: DataDict = .empty()
    init(_dataDict: DataDict) { __data = _dataDict }
    static var __selections: [Selection] {[
      .field("__typename", String.self),
      .field("id", String.self),
      .field("name", String.self),
      .field("friendsConnection", FriendsConnection.self, arguments: [
        "first": .variable("first"),
        "after": .variable("after")
      ])
    ]}

    var id: String {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }

    var name: String {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }
    var friendsConnection: FriendsConnection {
      get { __data["friendsConnection"] }
      set { __data["friendsConnection"] = newValue }
    }

    struct FriendsConnection: MockMutableRootSelectionSet {
      public var __data: DataDict = .empty()
      init(_dataDict: DataDict) { __data = _dataDict }
      static var __selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Character].self),
      ]}

      var totalCount: Int { __data["totalCount"] }
      var friends: [Character] {
        get { __data["friends"] }
        set { __data["friends"] = newValue }
      }

      struct Character: MockMutableRootSelectionSet {
        public var __data: DataDict = .empty()
        init(_dataDict: DataDict) { __data = _dataDict }
        static var __selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("id", String.self),
        ]}

        var id: String {
          get { __data["id"] }
          set { __data["id"] = newValue }
        }

        var name: String {
          get { __data["name"] }
          set { __data["name"] = newValue }
        }
      }
    }
  }
}

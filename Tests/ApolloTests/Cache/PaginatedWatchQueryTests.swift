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
    var watcher: GraphQLPaginatedQueryWatcher<MockQuery<MockPaginatedSelectionSet>, HeroViewModel>?
    addTeardownBlock { watcher?.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "totalCount": 3,
                "friends": [
                  [
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "name": "Han Solo",
                    "id": "1002",
                  ]
                ],
                "pageInfo": [
                  "endCursor": "Y3Vyc29yMg==",
                  "hasNextPage": true
                ]
              ]
            ],
          ]
        ]
      }

      watcher = GraphQLPaginatedQueryWatcher(
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
      } nextPageTransform: { oldData, newData, _ in
        guard let oldData else { return newData }

        return HeroViewModel(
          name: newData.name,
          friends: oldData.friends + newData.friends
        )
      } onReceiveResults: { result in
        guard case let .success(value) = result else { return XCTFail() }
        results.append(value)
      }
      guard let watcher else { return XCTFail() }
      wait(for: [serverExpectation], timeout: 1.0)

      runActivity("Fetch second page") { _ in
        let secondPageExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
          [
            "data": [
              "hero": [
                "id": "2001",
                "name": "R2-D2",
                "friendsConnection": [
                  "totalCount": 3,
                  "friends": [
                    [
                      "name": "Leia Organa",
                      "id": "1003",
                    ]
                  ],
                  "pageInfo": [
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
    }
  }

  func testFetchAndRefetch() {
    let query = MockQuery<MockPaginatedSelectionSet>()
    query.__variables = ["id": "2001", "first": 3, "after": GraphQLNullable<String>.null]

    var results: [HeroViewModel] = []
    var watcher: GraphQLPaginatedQueryWatcher<MockQuery<MockPaginatedSelectionSet>, HeroViewModel>?
    addTeardownBlock { watcher?.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "totalCount": 3,
                "friends": [
                  [
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "name": "Han Solo",
                    "id": "1002",
                  ],
                  [
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ],
                "pageInfo": [
                  "endCursor": "Y3Vyc29yMw==",
                  "hasNextPage": false
                ]
              ]
            ],
          ]
        ]
      }

      watcher = GraphQLPaginatedQueryWatcher(
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
      } nextPageTransform: { oldData, newData, _ in
        guard let oldData else { return newData }

        return HeroViewModel(
          name: newData.name,
          friends: oldData.friends + newData.friends
        )
      } onReceiveResults: { result in
        guard case let .success(value) = result else { return XCTFail() }
        results.append(value)
      }
      guard let watcher else { return XCTFail() }
      wait(for: [serverExpectation], timeout: 1.0)

      // Re-fetch:

      runActivity("Re-fetch from server") { _ in
        let refetchExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
          [
            "data": [
              "hero": [
                "id": "2001",
                "name": "R2-D2",
                "friendsConnection": [
                  "totalCount": 3,
                  "friends": [
                    [
                      "name": "Luke Skywalker",
                      "id": "1000",
                    ],
                    [
                      "name": "Han Solo",
                      "id": "1002",
                    ],
                    [
                      "name": "Leia Organa",
                      "id": "1003",
                    ]
                  ],
                  "pageInfo": [
                    "endCursor": "Y3Vyc29yMw==",
                    "hasNextPage": false
                  ]
                ]
              ],
            ]
          ]
        }
        watcher.fetch()
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
  }

  func testFetchAndLocalCacheUpdate() {
    let query = MockQuery<MockLocalCacheMutationSelectionSet>()
    let resultObserver = makeResultObserver(for: query)
    query.__variables = ["id": "2001", "first": 3, "after": GraphQLNullable<String>.null]
    var results: [HeroViewModel] = []
    var watcher: GraphQLPaginatedQueryWatcher<MockQuery<MockLocalCacheMutationSelectionSet>, HeroViewModel>!
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(MockQuery<MockLocalCacheMutationSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
              "id": "2001",
              "name": "R2-D2",
              "friendsConnection": [
                "totalCount": 3,
                "friends": [
                  [
                    "name": "Luke Skywalker",
                    "id": "1000",
                  ],
                  [
                    "name": "Han Solo",
                    "id": "1002",
                  ],
                  [
                    "name": "Leia Organa",
                    "id": "1003",
                  ]
                ]
              ]
            ],
          ]
        ]
      }

      let resultExpectation = expectation(description: "Results block has been updated")
      resultExpectation.expectedFulfillmentCount = 2
      watcher = GraphQLPaginatedQueryWatcher(
        client: client,
        query: query
      ) { pageInfo in
        let query = MockQuery<MockLocalCacheMutationSelectionSet>()
        query.__variables = ["id": "2001", "first": 3, "after": pageInfo.endCursor ?? GraphQLNullable<String>.null]
        return query
      } transform: { data in
        (
          HeroViewModel(
            name: data.hero?.name ?? "",
            friends: data.hero?.friendsConnection.friends?.map {
              HeroViewModel.Friend(name: $0.name, id: $0.id)
            } ?? []
          ),
          GraphQLPaginatedQueryWatcher.Page(
            hasNextPage: false,
            endCursor: nil
          )
        )
      } nextPageTransform: { oldData, newData, source in
        guard let oldData else { return newData }
        switch source {
        case .server:
          // We have brand new data, from a new page
          // In practice, this should be an `OrderedSet` or `IdentifiedCollection` of some kind
          // to prevent duplicate keys, but this is left for the consumer to implement
          // as we cannot mandate what shape or form their data transform takes
          return HeroViewModel(
            name: newData.name,
            friends: oldData.friends + newData.friends
          )
        case .cache:
          // Data comes in from the cache, implying modification of existing data.
          // This is left to the consumer to implement.
          // In practice, the consumer must diff their new result with their old result and
          // apply the diffs in the appropriate manner.

          // This test doesn't account for removals or additions.
          // Only updates

          var friends = oldData.friends
          let diffs: [(Array.Index, HeroViewModel.Friend)] = oldData.friends
            .enumerated()
            .compactMap { index, element in
              guard let changedFriend = newData.friends.first(where: { $0.id == element.id })
              else { return nil }
              return (index, changedFriend)
            }

          diffs.forEach { (index, newFriend) in
            friends[index] = newFriend
          }
          return HeroViewModel(
            name: newData.name,
            friends: friends
          )
        }
      } onReceiveResults: { result in
        guard case let .success(value) = result else { return XCTFail() }
        results.append(value)
        resultExpectation.fulfill()
      }
      wait(for: [serverExpectation], timeout: 1.0)

      runActivity("Local Cache Mutation") { _ in
        client.store.withinReadWriteTransaction { transaction in
          let cacheMutation = MockLocalCacheMutation<MockLocalCacheMutationSelectionSet>()
          cacheMutation.__variables = ["id": "2001", "first": 3, "after": GraphQLNullable<String>.null]
          try transaction.update(cacheMutation) { data in
            data.hero?.name = "Marty McFly"
            data.hero?.friendsConnection.friends?[0].name = "Doc Brown"
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
  }
}

private class MockPaginatedSelectionSet: MockSelectionSet {
  override class var __selections: [Selection] { [
    .field("hero", Hero?.self, arguments: ["id": .variable("id")])
  ]}

  var hero: Hero { __data["hero"] }

  class Hero: MockSelectionSet {
    override class var __selections: [Selection] {[
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
        .field("totalCount", Int.self),
        .field("friends", [Character].self),
        .field("pageInfo", PageInfo.self)
      ]}

      var totalCount: Int { __data["totalCount"] }
      var friends: [Character] { __data["friends"] }
      var pageInfo: PageInfo { __data["pageInfo"] }

      class Character: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("name", String.self),
          .field("id", String.self),
        ]}

        var name: String { __data["name"] }
        var id: String { __data["id"] }
      }

      class PageInfo: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("endCursor", Optional<String>.self),
          .field("hasNextPage", Bool.self)
        ]}

        var endCursor: String? { __data["endCursor"] }
        var hasNextPage: Bool { __data["hasNextPage"] }
      }
    }
  }
}

private struct MockLocalCacheMutationSelectionSet: MockMutableRootSelectionSet {
  var __data: DataDict = .empty()
  init(_dataDict: DataDict) {
    self.__data = _dataDict
  }

  static var __selections: [Selection] { [
    .field("hero", Hero?.self, arguments: ["id": .variable("id")])
  ]}

  var hero: Hero? {
    get { __data["hero"] }
    set { __data["hero"] = newValue }
  }

  struct Hero: MockMutableRootSelectionSet {
    var __data: DataDict = .empty()
    init(_dataDict: DataDict) {
      self.__data = _dataDict
    }

    static var __selections: [Selection] {[
      .field("id", String.self),
      .field("name", String.self),
      .field("friendsConnection", FriendsConnection.self)
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
      var __data: DataDict = .empty()
      init(_dataDict: DataDict) {
        self.__data = _dataDict
      }
      static var __selections: [Selection] {[
        .field("friends", [Character]?.self),
      ]}

      var friends: [Character]? {
        get { __data["friends"] }
        set { __data["friends"] = newValue }
      }

      struct Character: MockMutableRootSelectionSet {
        var __data: DataDict = .empty()
        init(_dataDict: DataDict) {
          self.__data = _dataDict
        }

        static var __selections: [Selection] {[
          .field("name", String.self),
          .field("id", String.self)
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

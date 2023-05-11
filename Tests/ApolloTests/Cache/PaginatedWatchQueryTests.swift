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

  private class MockPaginatedSelectionSet: MockSelectionSet {
    override class var __selections: [Selection] { [
      .field("hero", Hero.self)
    ]}

    var hero: Hero { __data["hero"] }

    class Hero: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("name", String.self),
        .field("friendsConnection", FriendsConnection.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ])
      ]}

      var name: String { __data["name"] }
      var friends: FriendsConnection { __data["friendsConnection"] }

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
          ]}

          var name: String { __data["name"] }
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

  struct HeroViewModel: Equatable {
    struct Friend: Equatable {
      let name: String
    }

    let name: String
    let friends: [Friend]
  }

  struct Page: PageInfoType {
    var endCursor: Cursor?
    var hasNextPage: Bool
  }

  // MARK: - Tests

  func testMultiPageResults() {
    let query = MockQuery<MockPaginatedSelectionSet>()
    query.__variables = ["first": 2, "after": GraphQLNullable<String>.null]

    var results: [HeroViewModel] = []
    var watcher: GraphQLPaginatedQueryWatcher<MockQuery<MockPaginatedSelectionSet>, HeroViewModel>?
    addTeardownBlock { watcher?.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "friendsConnection": [
                "totalCount": 3,
                "friends": [
                  [
                    "name": "Luke Skywalker"
                  ],
                  [
                    "name": "Han Solo"
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
        query.__variables = ["first": 2, "after": "1"]
        return query
      } transform: { data in
        HeroViewModel(
          name: data.hero.name,
          friends: data.hero.friends.friends.map {
            HeroViewModel.Friend(name: $0.name)
          }
        )
      } nextPageTransform: { oldData, newData in
        guard let oldData else { return newData }

        return HeroViewModel(
          name: newData.name,
          friends: oldData.friends + newData.friends
        )
      } onReceiveResults: { result in
        switch result {
        case .success(let value):
          dump(value)
        case .failure(let error):
          XCTFail("Error \(error)")
        }
        guard case let .success(value) = result else { return XCTFail() }
        results.append(value)
      }
      guard let watcher else { return XCTFail() }
      wait(for: [serverExpectation], timeout: 1.0)

      let secondPageExpectation = server.expect(MockQuery<MockPaginatedSelectionSet>.self) { _ in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "friendsConnection": [
                "totalCount": 3,
                "friends": [
                  [
                    "name": "Leia Organa"
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

      _ = watcher.fetchNext(page: Page(endCursor: "Y3Vyc29yMg==", hasNextPage: true))
      wait(for: [secondPageExpectation], timeout: 1.0)

      XCTAssertEqual(results.count, 2)
      XCTAssertEqual(results, [
        HeroViewModel(name: "R2-D2", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker"),
          HeroViewModel.Friend(name: "Han Solo"),
        ]),
        HeroViewModel(name: "R2-D2", friends: [
          HeroViewModel.Friend(name: "Luke Skywalker"),
          HeroViewModel.Friend(name: "Han Solo"),
          HeroViewModel.Friend(name: "Leia Organa"),
        ])
      ])

    }
  }
}

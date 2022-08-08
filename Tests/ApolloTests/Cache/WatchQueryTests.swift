import XCTest
import Nimble
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

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

  // MARK: - Tests

  func testRefetchWatchedQueryFromServerThroughWatcherReturnsRefetchedResults() throws {
    class SimpleMockSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }
    }

    let watchedQuery = MockQuery<SimpleMockSelectionSet>()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<SimpleMockSelectionSet>.self) { request in
          [
            "data": [
              "hero": [
                "name": "R2-D2",
                "__typename": "Droid"
              ]
            ]
          ]
        }
      
      let initialWatcherResultExpectation =
        resultObserver.expectation(
          description: "Watcher received initial result from server"
        ) { result in
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
      let serverRequestExpectation =
        server.expect(MockQuery<SimpleMockSelectionSet>.self) { request in
          [
            "data": [
              "hero": [
                "name": "Artoo",
                "__typename": "Droid"
              ]
            ]
          ]
        }
      
      let refetchedWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received refetched result from server"
      ) { result in
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
    class SimpleMockSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }
    }

    let watchedQuery = MockQuery<SimpleMockSelectionSet>()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<SimpleMockSelectionSet>.self) { request in
          [
            "data": [
              "hero": [
                "name": "R2-D2",
                "__typename": "Droid"
              ]
            ]
          ]
        }
      
      let initialWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received initial result from server"
      ) { result in
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
      let serverRequestExpectation =
        server.expect(MockQuery<SimpleMockSelectionSet>.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let updatedWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received updated result from cache"
      ) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
        }
      }
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")
      
      client.fetch(query: MockQuery<SimpleMockSelectionSet>(),
                   cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryDoesNotRefetchAfterSameQueryWithDifferentArgument() throws {
    class GivenMockSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self, arguments: ["episode": .variable("episode")])
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }
    }

    let watchedQuery = MockQuery<GivenMockSelectionSet>()
    watchedQuery.variables = ["episode": "EMPIRE"]
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<GivenMockSelectionSet>.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let initialWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received initial result from server"
      ) { result in
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
      let serverRequestExpectation =
        server.expect(MockQuery<GivenMockSelectionSet>.self) { request in
          expect(request.operation.variables?["episode"] as? String).to(equal("JEDI"))

          return [
            "data": [
              "hero": [
                "name": "Artoo",
                "__typename": "Droid"
              ]
            ]
          ]
        }
      
      let noUpdatedResultExpectation = resultObserver.expectation(
        description: "Other query shouldn't trigger refetch"
      ) { _ in }
      noUpdatedResultExpectation.isInverted = true
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")

      let newQuery = MockQuery<GivenMockSelectionSet>()
      newQuery.variables = ["episode": "JEDI"]

      client.fetch(query: newQuery, cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, noUpdatedResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryGetsUpdatedWhenSameObjectHasChangedInAnotherQueryWithDifferentVariables() throws {
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self, arguments: ["episode": .variable("episode")])
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self)
        ]}
      }
    }

    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = IDCacheKeyProvider.resolver

    let watchedQuery = MockQuery<GivenSelectionSet>()
    watchedQuery.variables = ["episode": "EMPIRE"]
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client,
                                      query: watchedQuery,
                                      resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(MockQuery<GivenSelectionSet>.self) { request in
        expect(request.operation.variables?["episode"] as? String).to(equal("EMPIRE"))
        return [
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
      let serverRequestExpectation = server.expect(MockQuery<GivenSelectionSet>.self) { request in
        expect(request.operation.variables?["episode"] as? String).to(equal("JEDI"))
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

      let query = MockQuery<GivenSelectionSet>()
      query.variables = ["episode": "JEDI"]

      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryGetsUpdatedWhenOverlappingQueryReturnsChangedData() throws {
    class HeroNameSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }
    }

    class HeroAndFriendsNameSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("hero", Hero?.self)
      ]}

      var hero: Hero? { __data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self),
        ]}

        var friends: [Friend]? { __data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("name", String.self),
          ]}

          var name: String { __data["name"] }
        }
      }
    }

    let watchedQuery = MockQuery<HeroAndFriendsNameSelectionSet>()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client,
                                      query: watchedQuery,
                                      resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<HeroAndFriendsNameSelectionSet>.self) { request in
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
      
      let initialWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received initial result from server"
      ) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Fetch overlapping query from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<HeroNameSelectionSet>.self) { request in
        [
          "data": [
            "hero": [
              "name": "Artoo",
              "__typename": "Droid"
            ]
          ]
        ]
      }
      
      let updatedWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received updated result from cache"
      ) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
          let friendsNames = data.hero?.friends?.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")
      
      client.fetch(query: MockQuery<HeroNameSelectionSet>(),
                   cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testListInWatchedQueryGetsUpdatedByListOfKeysFromOtherQuery() throws {
    class HeroAndFriendsIdsSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("hero", Hero?.self)
      ]}

      var hero: Hero? { __data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self),
        ]}

        var friends: [Friend]? { __data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
          ]}
        }
      }
    }

    class HeroAndFriendsNameSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("hero", Hero?.self)
      ]}

      var hero: Hero? { __data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self),
        ]}

        var friends: [Friend]? { __data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
            .field("name", String.self),
          ]}

          var name: String { __data["name"] }
        }
      }
    }
    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = IDCacheKeyProvider.resolver
    
    let watchedQuery = MockQuery<HeroAndFriendsNameSelectionSet>()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client,
                                      query: watchedQuery,
                                      resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation = server.expect(MockQuery<HeroAndFriendsNameSelectionSet>.self) { request in
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
          let friendsNames = data.hero?.friends?.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Fetch other query with list of updated keys from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<HeroAndFriendsIdsSelectionSet>.self) { request in
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
      
      let updatedWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received updated result from cache"
      ) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
          let friendsNames = data.hero?.friends?.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Leia Organa", "Luke Skywalker"])
        }
      }
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")
      
      client.fetch(query: MockQuery<HeroAndFriendsIdsSelectionSet>(),
                   cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testWatchedQueryRefetchesFromServerAfterOtherQueryUpdatesListWithIncompleteObject() throws {
    class HeroAndFriendsIDsSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("hero", Hero?.self)
      ]}

      var hero: Hero? { __data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("friends", [Friend]?.self),
        ]}

        var friends: [Friend]? { __data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
          ]}
        }
      }
    }

    class HeroAndFriendsNameWithIDsSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("hero", Hero?.self)
      ]}

      var hero: Hero? { __data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self),
        ]}

        var friends: [Friend]? { __data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
            .field("name", String.self),
          ]}

          var name: String { __data["name"] }
        }
      }
    }

    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = IDCacheKeyProvider.resolver
    
    let watchedQuery = MockQuery<HeroAndFriendsNameWithIDsSelectionSet>()
    
    let resultObserver = makeResultObserver(for: watchedQuery)
    
    let watcher = GraphQLQueryWatcher(client: client,
                                      query: watchedQuery,
                                      resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }
    
    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<HeroAndFriendsNameWithIDsSelectionSet>.self) { request in
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
          let friendsNames = data.hero?.friends?.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }
      
      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)
      
      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
    
    runActivity("Fetch other query with list of updated keys from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<HeroAndFriendsIDsSelectionSet>.self) { request in
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
      
      let refetchServerRequestExpectation =
        server.expect(MockQuery<HeroAndFriendsNameWithIDsSelectionSet>.self) { request in
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
      
      let updatedWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received updated result from cache"
      ) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)
          
          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")
          let friendsNames = data.hero?.friends?.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Leia Organa", "Wilhuff Tarkin", "Luke Skywalker"])
        }
      }
      
      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")
      
      client.fetch(query: MockQuery<HeroAndFriendsIDsSelectionSet>(),
                   cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }
      
      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, refetchServerRequestExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func testWatchedQueryGetsUpdatedWhenObjectIsChangedByDirectStoreUpdate() throws {
    struct HeroAndFriendsNamesSelectionSet: MockMutableRootSelectionSet {
      public var __data: DataDict = DataDict([:], variables: nil)
      init(data: DataDict) { __data = data }

      static var selections: [Selection] {[
        .field("hero", Hero?.self)
      ]}

      var hero: Hero? {
        get { __data["hero"] }
        set { __data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var __data: DataDict = DataDict([:], variables: nil)
        init(data: DataDict) { __data = data }

        static var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self),
        ]}

        var name: String {
          get { __data["name"] }
          set { __data["name"] = newValue }
        }

        var friends: [Friend]? {
          get { __data["friends"] }
          set { __data["friends"] = newValue }
        }

        struct Friend: MockMutableRootSelectionSet {
          public var __data: DataDict = DataDict([:], variables: nil)
          init(data: DataDict) { __data = data }

          static var selections: [Selection] {[
            .field("__typename", String.self),
            .field("name", String.self),
          ]}

          var name: String {
            get { __data["name"] }
            set { __data["name"] = newValue }
          }
        }
      }
    }

    let watchedQuery = MockQuery<HeroAndFriendsNamesSelectionSet>()

    let resultObserver = makeResultObserver(for: watchedQuery)

    let watcher = GraphQLQueryWatcher(client: client,
                                      query: watchedQuery,
                                      resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<HeroAndFriendsNamesSelectionSet>.self) { request in
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

      let initialWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received initial result from server"
      ) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)

          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames: [String] = try XCTUnwrap(
            data.hero?.friends?.compactMap { $0.name }
          )
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }

      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)

      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }

    runActivity("Update object directly in store") { _ in
      let updatedWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received updated result from cache"
      ) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)

          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero?.name, "Artoo")

          let friendsNames = data.hero?.friends?.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }

      client.store.withinReadWriteTransaction({ transaction in
        let cacheMutation = MockLocalCacheMutation<HeroAndFriendsNamesSelectionSet>()
        try transaction.update(cacheMutation) { data in
          data.hero?.name = "Artoo"
        }
      })

      wait(for: [updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func testWatchedQuery_givenCachePolicyReturnCacheDataDontFetch_doesNotRefetchFromServerAfterOtherQueryUpdatesListWithIncompleteObject() throws {
    // given
    struct HeroAndFriendsNamesSelectionSet: MockMutableRootSelectionSet {
      public var __data: DataDict = DataDict([:], variables: nil)
      init(data: DataDict) { __data = data }

      static var selections: [Selection] {[
        .field("hero", Hero.self)
      ]}

      var hero: Hero {
        get { __data["hero"] }
        set { __data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var __data: DataDict = DataDict([:], variables: nil)
        init(data: DataDict) { __data = data }

        static var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self),
        ]}

        var id: String {
          get { __data["id"] }
          set { __data["id"] = newValue }
        }

        var name: String {
          get { __data["name"] }
          set { __data["name"] = newValue }
        }

        var friends: [Friend] {
          get { __data["friends"] }
          set { __data["friends"] = newValue }
        }

        struct Friend: MockMutableRootSelectionSet {
          public var __data: DataDict = DataDict([:], variables: nil)
          init(data: DataDict) { __data = data }

          static var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
            .field("name", String.self),
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

    struct HeroAndFriendsIDsOnlySelectionSet: MockMutableRootSelectionSet {
      public var __data: DataDict = DataDict([:], variables: nil)
      init(data: DataDict) { __data = data }

      static var selections: [Selection] {[
        .field("hero", Hero.self)
      ]}

      var hero: Hero {
        get { __data["hero"] }
        set { __data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var __data: DataDict = DataDict([:], variables: nil)
        init(data: DataDict) { __data = data }

        static var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("friends", [Friend].self),
        ]}

        var id: String {
          get { __data["id"] }
          set { __data["id"] = newValue }
        }

        var friends: [Friend] {
          get { __data["friends"] }
          set { __data["friends"] = newValue }
        }

        struct Friend: MockMutableRootSelectionSet {
          public var __data: DataDict = DataDict([:], variables: nil)
          init(data: DataDict) { __data = data }

          static var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
          ]}

          var id: String {
            get { __data["id"] }
            set { __data["id"] = newValue }
          }
        }
      }
    }

    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = IDCacheKeyProvider.resolver

    let watchedQuery = MockQuery<HeroAndFriendsNamesSelectionSet>()

    let resultObserver = makeResultObserver(for: watchedQuery)

    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }

    runActivity("Write data to cache") { _ in
      let writeToStoreExpectation = expectation(description: "Initial Data written to store")

      client.store.withinReadWriteTransaction({ transaction in
        let data = HeroAndFriendsNamesSelectionSet(
          data: DataDict(
            [
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
            ],
            variables: nil
          ))

        let cacheMutation = MockLocalCacheMutation<HeroAndFriendsNamesSelectionSet>()
        try transaction.write(data: data, for: cacheMutation)
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
          XCTAssertEqual(data.hero.name, "R2-D2")
          let friendsNames = data.hero.friends.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        }
      }

      watcher.fetch(cachePolicy: .returnCacheDataDontFetch)

      wait(for: [initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }

    runActivity("Fetch other query with list of updated keys from server") { _ in
      let serverRequestExpectation = server.expect(MockQuery<HeroAndFriendsIDsOnlySelectionSet>.self) { request in
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

      let query = MockQuery<HeroAndFriendsIDsOnlySelectionSet>()
      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }

      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, noRefetchExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func testWatchedQueryIsOnlyUpdatedOnceIfConcurrentFetchesAllReturnTheSameResult() throws {
    class HeroNameSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }
    }

    let watchedQuery = MockQuery<HeroNameSelectionSet>()

    let resultObserver = makeResultObserver(for: watchedQuery)

    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<HeroNameSelectionSet>.self) { request in
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
      let serverRequestExpectation =
        server.expect(MockQuery<HeroNameSelectionSet>.self) { request in
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

      let updatedWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received updated result from cache"
      ) { result in
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
        client.fetch(query: MockQuery<HeroNameSelectionSet>(),
                     cachePolicy: .fetchIgnoringCacheData) { [weak self] result in
          otherFetchesCompletedExpectation.fulfill()

          if let self = self, case .failure(let error) = result {
            self.record(error)
          }
        }
      }

      wait(for: [serverRequestExpectation, otherFetchesCompletedExpectation, updatedWatcherResultExpectation], timeout: 3)

      XCTAssertEqual(updatedWatcherResultExpectation.numberOfFulfillments, 1)
    }
  }

  func testWatchedQueryIsUpdatedMultipleTimesIfConcurrentFetchesReturnChangedData() throws {
    class HeroNameSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      var hero: Hero { __data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}

        var name: String { __data["name"] }
      }
    }

    let watchedQuery = MockQuery<HeroNameSelectionSet>()

    let resultObserver = makeResultObserver(for: watchedQuery)

    let watcher = GraphQLQueryWatcher(client: client,
                                      query: watchedQuery,
                                      resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<HeroNameSelectionSet>.self) { request in
        [
          "data": [
            "hero": [
              "name": "R2-D2",
              "__typename": "Droid"
            ]
          ]
        ]
      }

      let initialWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received initial result from server"
      ) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)

          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero.name, "R2-D2")
        }
      }

      watcher.fetch(cachePolicy: .fetchIgnoringCacheData)

      wait(for: [serverRequestExpectation, initialWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }

    let numberOfFetches = 10

    runActivity("Fetch same query concurrently \(numberOfFetches) times") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<HeroNameSelectionSet>.self) { request in
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

      let updatedWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received updated result from cache"
      ) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)

          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertTrue(try XCTUnwrap(data.hero.name).hasPrefix("Artoo"))
        }
      }

      updatedWatcherResultExpectation.expectedFulfillmentCount = numberOfFetches

      let otherFetchesCompletedExpectation = expectation(description: "Other fetches completed")
      otherFetchesCompletedExpectation.expectedFulfillmentCount = numberOfFetches

      DispatchQueue.concurrentPerform(iterations: numberOfFetches) { _ in
        client.fetch(query: MockQuery<HeroNameSelectionSet>(),
                     cachePolicy: .fetchIgnoringCacheData) { [weak self] result in
          otherFetchesCompletedExpectation.fulfill()

          if let self = self, case .failure(let error) = result {
            self.record(error)
          }
        }
      }

      wait(for: [serverRequestExpectation, otherFetchesCompletedExpectation, updatedWatcherResultExpectation], timeout: 3)

      XCTAssertEqual(updatedWatcherResultExpectation.numberOfFulfillments, numberOfFetches)
    }
  }

  func testWatchedQueryDependentKeysAreUpdatedAfterDirectStoreUpdate() {
    // given
    struct HeroAndFriendsNamesWithIDsSelectionSet: MockMutableRootSelectionSet {
      public var __data: DataDict = DataDict([:], variables: nil)
      init(data: DataDict) { __data = data }

      static var selections: [Selection] {[
        .field("hero", Hero.self)
      ]}

      var hero: Hero {
        get { __data["hero"] }
        set { __data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var __data: DataDict = DataDict([:], variables: nil)
        init(data: DataDict) { __data = data }

        static var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self),
        ]}

        var id: String {
          get { __data["id"] }
          set { __data["id"] = newValue }
        }

        var name: String {
          get { __data["name"] }
          set { __data["name"] = newValue }
        }

        var friends: [Friend] {
          get { __data["friends"] }
          set { __data["friends"] = newValue }
        }

        struct Friend: MockMutableRootSelectionSet {
          public var __data: DataDict = DataDict([:], variables: nil)
          init(data: DataDict) { __data = data }

          static var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
            .field("name", String.self),
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

    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = IDCacheKeyProvider.resolver

    typealias HeroAndFriendsNamesWithIDsQuery = MockQuery<HeroAndFriendsNamesWithIDsSelectionSet>
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

          XCTAssertEqual(data.hero.name, "R2-D2")

          let friendsNames = data.hero.friends.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker"])

          let expectedDependentKeys: Set = [
            "Droid:2001.__typename",
            "Droid:2001.friends",
            "Droid:2001.id",
            "Droid:2001.name",
            "Human:1000.__typename",
            "Human:1000.id",
            "Human:1000.name",
            "QUERY_ROOT.hero",
          ]
          let actualDependentKeys = try XCTUnwrap(graphQLResult.dependentKeys)
          expect(actualDependentKeys).to(equal(expectedDependentKeys))
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

          XCTAssertEqual(data.hero.name, "R2-D2")

          let friendsNames = data.hero.friends.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo"])

          let expectedDependentKeys: Set = [
            "Droid:2001.__typename",
            "Droid:2001.friends",
            "Droid:2001.id",
            "Droid:2001.name",
            "Human:1000.__typename",
            "Human:1000.id",
            "Human:1000.name",
            "Human:1002.__typename",
            "Human:1002.id",
            "Human:1002.name",
            "QUERY_ROOT.hero",
          ]
          let actualDependentKeys = try XCTUnwrap(graphQLResult.dependentKeys)
          expect(actualDependentKeys).to(equal(expectedDependentKeys))
        }
      }

      let cacheMutation = MockLocalCacheMutation<HeroAndFriendsNamesWithIDsSelectionSet>()
      client.store.withinReadWriteTransaction({ transaction in
        try transaction.update(cacheMutation) { data in
          var human = HeroAndFriendsNamesWithIDsSelectionSet.Hero.Friend()
          human.__typename = "Human"
          human.id = "1002"
          human.name = "Han Solo"
          data.hero.friends.append(human)
        }
      })

      wait(for: [updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func testWatchedQueryDependentKeysAreUpdatedAfterOtherFetchReturnsChangedData() {
    class HeroAndFriendsNameWithIDsSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("hero", Hero?.self)
      ]}

      var hero: Hero? { __data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self),
        ]}

        var friends: [Friend]? { __data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
            .field("name", String.self),
          ]}

          var name: String { __data["name"] }
        }
      }
    }
    
    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = IDCacheKeyProvider.resolver

    let watchedQuery = MockQuery<HeroAndFriendsNameWithIDsSelectionSet>()

    let resultObserver = makeResultObserver(for: watchedQuery)

    let watcher = GraphQLQueryWatcher(client: client, query: watchedQuery, resultHandler: resultObserver.handler)
    addTeardownBlock { watcher.cancel() }

    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<HeroAndFriendsNameWithIDsSelectionSet>.self) { request in
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

      let initialWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received initial result from server"
      ) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)

          let data = try XCTUnwrap(graphQLResult.data)

          XCTAssertEqual(data.hero?.name, "R2-D2")

          let friendsNames = data.hero?.friends?.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker"])

          let expectedDependentKeys: Set = [
            "Droid:2001.__typename",
            "Droid:2001.friends",
            "Droid:2001.id",
            "Droid:2001.name",
            "Human:1000.__typename",
            "Human:1000.id",
            "Human:1000.name",
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
      let serverRequestExpectation =
        server.expect(MockQuery<HeroAndFriendsNameWithIDsSelectionSet>.self) { request in
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

          let friendsNames = data.hero?.friends?.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo"])

          let expectedDependentKeys: Set = [
            "Droid:2001.__typename",
            "Droid:2001.friends",
            "Droid:2001.id",
            "Droid:2001.name",
            "Human:1000.__typename",
            "Human:1000.id",
            "Human:1000.name",
            "Human:1002.__typename",
            "Human:1002.id",
            "Human:1002.name",
            "QUERY_ROOT.hero",
          ]
          let actualDependentKeys = try XCTUnwrap(graphQLResult.dependentKeys)
          XCTAssertEqual(actualDependentKeys, expectedDependentKeys)
        }
      }

      let otherFetchCompletedExpectation = expectation(description: "Other fetch completed")

      client.fetch(query: MockQuery<HeroAndFriendsNameWithIDsSelectionSet>(),
                   cachePolicy: .fetchIgnoringCacheData) { result in
        defer { otherFetchCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      }

      wait(for: [serverRequestExpectation, otherFetchCompletedExpectation, updatedWatcherResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func testQueryWatcherDoesNotHaveARetainCycle() {
    class HeroAndFriendsNameWithIDsSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("hero", Hero?.self)
      ]}

      var hero: Hero? { __data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self),
        ]}

        var friends: [Friend]? { __data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
            .field("name", String.self),
          ]}

          var name: String { __data["name"] }
        }
      }
    }
    MockSchemaConfiguration.stub_cacheKeyInfoForType_Object = IDCacheKeyProvider.resolver

    let watchedQuery = MockQuery<HeroAndFriendsNameWithIDsSelectionSet>()

    let resultObserver = makeResultObserver(for: watchedQuery)

    var watcher: GraphQLQueryWatcher<MockQuery<HeroAndFriendsNameWithIDsSelectionSet>>? =
      GraphQLQueryWatcher(client: client,
                          query: watchedQuery,
                          resultHandler: resultObserver.handler)

    weak var weakWatcher = watcher

    runActivity("Initial fetch from server") { _ in
      let serverRequestExpectation =
        server.expect(MockQuery<HeroAndFriendsNameWithIDsSelectionSet>.self) { request in
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

      let initialWatcherResultExpectation = resultObserver.expectation(
        description: "Watcher received initial result from server"
      ) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .server)
          XCTAssertNil(graphQLResult.errors)

          let data = try XCTUnwrap(graphQLResult.data)

          XCTAssertEqual(data.hero?.name, "R2-D2")

          let friendsNames = data.hero?.friends?.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker"])

          let expectedDependentKeys: Set = [
            "Droid:2001.__typename",
            "Droid:2001.friends",
            "Droid:2001.id",
            "Droid:2001.name",
            "Human:1000.__typename",
            "Human:1000.id",
            "Human:1000.name",
            "QUERY_ROOT.hero",
          ]
          let actualDependentKeys = try XCTUnwrap(graphQLResult.dependentKeys)
          XCTAssertEqual(actualDependentKeys, expectedDependentKeys)
        }
      }

      watcher!.fetch(cachePolicy: .fetchIgnoringCacheData)

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

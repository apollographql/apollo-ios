import XCTest
import Nimble
@testable import Apollo
import ApolloUtils
import ApolloAPI
import ApolloInternalTestHelpers

class ReadWriteFromStoreTests: XCTestCase, CacheDependentTesting, StoreLoading {

  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }

  static let defaultWaitTimeout: TimeInterval = 5.0

  var cache: NormalizedCache!
  var store: ApolloStore!

  override func setUpWithError() throws {
    try super.setUpWithError()

    cache = try makeNormalizedCache()
    store = ApolloStore(cache: cache)
  }

  override func tearDownWithError() throws {
    cache = nil
    store = nil

    try super.tearDownWithError()
  }

  // MARK: - Read Query Tests

  func test_readQuery_givenQueryDataInCache_returnsData() throws {
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

    let query = MockQuery<HeroNameSelectionSet>()

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])

    let readCompletedExpectation = expectation(description: "Read completed")

    store.withinReadTransaction({ transaction in
      let data = try transaction.read(query: query)

      expect(data.hero?.__typename).to(equal("Droid"))
      expect(data.hero?.name).to(equal("R2-D2"))
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })

    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }

  func test_readQuery_givenQueryDataDoesNotExist_throwsMissingValueError() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("name", String.self)
      ]}
    }

    let query = MockQuery<GivenSelectionSet>()

    mergeRecordsIntoCache([
      "QUERY_ROOT": [:],
    ])

    // when
    let readCompletedExpectation = expectation(description: "Read completed")

    store.withinReadWriteTransaction({ transaction in
      _ = try transaction.read(query: query)
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }

      // then
      expectJSONMissingValueError(result, atPath: ["name"])
    })

    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }

  func test_readQuery_givenQueryDataWithVariableInCache_readsQuery() throws {
    // given
    enum Episode: String, EnumType {
      case JEDI
    }

    class HeroNameSelectionSet: MockSelectionSet {
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

    let query = MockQuery<HeroNameSelectionSet>()
    query.variables = ["episode": Episode.JEDI]

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero(episode:JEDI)": CacheReference("hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ])

    // when
    runActivity("read query") { _ in
      let readCompletedExpectation = expectation(description: "Read completed")
      store.withinReadTransaction({ transaction in
        let data = try transaction.read(query: query)

        // then
        expect(data.hero?.__typename).to(equal("Droid"))
        expect(data.hero?.name).to(equal("R2-D2"))

      }, completion: { result in
        defer { readCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      })

      self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func test_readQuery_givenQueryDataWithOtherVariableValueInCache_throwsMissingValueError() throws {
    // given
    enum Episode: String, EnumType {
      case JEDI
      case PHANTOM_MENACE
    }

    class HeroNameSelectionSet: MockSelectionSet {
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

    let query = MockQuery<HeroNameSelectionSet>()
    query.variables = ["episode": Episode.PHANTOM_MENACE]

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero(episode:JEDI)": CacheReference("hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ])

    // when
    runActivity("read query") { _ in
      let readCompletedExpectation = expectation(description: "Read completed")
      store.withinReadTransaction({ transaction in
        _ = try transaction.read(query: query)
      }, completion: { result in
        defer { readCompletedExpectation.fulfill() }

        // then
        expectJSONMissingValueError(result, atPath: ["hero"])
      })

      self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func test_readQuery_withCacheReferencesByCustomKey_resolvesReferences() throws {
    // given
    class HeroFriendsSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      var hero: Hero { data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self)
        ]}

        var friends: [Friend] { data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
            .field("name", String.self),
          ]}
        }
      }
    }

    let query = MockQuery<HeroFriendsSelectionSet>()
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("2001")],
      "2001": [
        "name": "R2-D2",
        "id": "2001",
        "__typename": "Droid",
        "friends": [
          CacheReference("1000"),
          CacheReference("1002"),
          CacheReference("1003")
        ]
      ],
      "1000": ["__typename": "Human", "name": "Luke Skywalker", "id": "1000"],
      "1002": ["__typename": "Human", "name": "Han Solo", "id": "1002"],
      "1003": ["__typename": "Human", "name": "Leia Organa", "id": "1003"],
    ])

    let readCompletedExpectation = expectation(description: "Read completed")

    store.withinReadTransaction({ transaction in
      let data = try transaction.read(query: query)

      XCTAssertEqual(data.hero.name, "R2-D2")
      let friendsNames: [String] = data.hero.friends.compactMap { $0.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })

    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }

  func test_readObject_givenFragmentWithTypeSpecificProperty() throws {
    // given
    class Droid: Object {}
    MockSchemaConfiguration.stub_objectTypeForTypeName = { typename in
      switch typename {
      case "Droid": return Droid.self
      default: return nil
      }
    }

    class GivenSelectionSet: MockFragment, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
        .inlineFragment(AsDroid.self),
      ]}

      var asDroid: AsDroid? { _asInlineFragment() }

      class AsDroid: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration
        override class var __parentType: ParentType { .Object(Droid.self) }

        override class var selections: [Selection] { [
          .field("primaryFunction", String.self),
        ]}
      }
    }

    mergeRecordsIntoCache([
      "2001": ["name": "R2-D2", "__typename": "Droid", "primaryFunction": "Protocol"]
    ])

    let readCompletedExpectation = expectation(description: "Read completed")

    store.withinReadTransaction({ transaction in
      let r2d2 = try transaction.readObject(
        ofType: GivenSelectionSet.self,
        withKey: "2001"
      )

      XCTAssertEqual(r2d2.name, "R2-D2")
      XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })

    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }

  func test_readObject_givenFragmentWithMissingTypeSpecificProperty() throws {
    // given
    class Droid: Object {}
    MockSchemaConfiguration.stub_objectTypeForTypeName = { typename in
      switch typename {
      case "Droid": return Droid.self
      default: return nil
      }
    }

    class GivenSelectionSet: MockFragment, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
        .inlineFragment(AsDroid.self),
      ]}

      var asDroid: AsDroid? { _asInlineFragment() }

      class AsDroid: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration
        override class var __parentType: ParentType { .Object(Droid.self) }

        override class var selections: [Selection] { [
          .field("primaryFunction", String.self),
        ]}
      }
    }

    mergeRecordsIntoCache([
      "2001": ["name": "R2-D2", "__typename": "Droid"]
    ])

    let readCompletedExpectation = expectation(description: "Read completed")

    store.withinReadTransaction({ transaction in
      XCTAssertThrowsError(try transaction.readObject(
        ofType: GivenSelectionSet.self,
        withKey: "2001")
      ) { error in
        if case let error as GraphQLExecutionError = error {
          XCTAssertEqual(error.path, ["primaryFunction"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })

    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }

  // MARK: - Write Local Cache Mutation Tests

  func test_updateCacheMutation_updateNestedField_updatesObjects() throws {
    // given
    struct GivenSelectionSet: MockMutableRootSelectionSet {
      public var data: DataDict = DataDict([:], variables: nil)

      static var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      var hero: Hero {
        get { data["hero"] }
        set { data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var data: DataDict = DataDict([:], variables: nil)
        
        static var selections: [Selection] { [
          .field("name", String.self)
        ]}

        var name: String {
          get { data["name"] }
          set { data["name"] = newValue }
        }
      }
    }

    let cacheMutation = MockLocalCacheMutation<GivenSelectionSet>()

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": ["__typename": "Droid", "name": "R2-D2"]
    ])

    runActivity("update mutation") { _ in
      let updateCompletedExpectation = expectation(description: "Update completed")

      store.withinReadWriteTransaction({ transaction in
        try transaction.update(cacheMutation) { data in
          data.hero.name = "Artoo"
        }
      }, completion: { result in
        defer { updateCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      })

      self.wait(for: [updateCompletedExpectation], timeout: Self.defaultWaitTimeout)
    }

    let query = MockQuery<GivenSelectionSet>()

    loadFromStore(query: query) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)

        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero.name, "Artoo")
      }
    }
  }

  func test_updateCacheMutation_givenQueryWithVariables_updateNestedField_updatesObjectsOnlyForQueryWithMatchingVariables() throws {
    // given
    enum Episode: String, EnumType {
      case JEDI
      case PHANTOM_MENACE
    }

    struct GivenSelectionSet: MockMutableRootSelectionSet {
      public var data: DataDict = DataDict([:], variables: nil)

      static var selections: [Selection] { [
        .field("hero", Hero.self, arguments: ["episode": .variable("episode")])
      ]}

      var hero: Hero {
        get { data["hero"] }
        set { data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var data: DataDict = DataDict([:], variables: nil)

        static var selections: [Selection] { [
          .field("name", String.self)
        ]}

        var name: String {
          get { data["name"] }
          set { data["name"] = newValue }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": [
        "hero(episode:JEDI)": CacheReference("hero(episode:JEDI)"),
        "hero(episode:PHANTOM_MENACE)": CacheReference("hero(episode:PHANTOM_MENACE)")
      ],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"],
      "hero(episode:PHANTOM_MENACE)": ["__typename": "Human", "name": "Qui-Gon Jinn"]
    ])

    runActivity("update mutation") { _ in
      let updateCompletedExpectation = expectation(description: "Update completed")
      let cacheMutation = MockLocalCacheMutation<GivenSelectionSet>()
      cacheMutation.variables = ["episode": Episode.JEDI]

      store.withinReadWriteTransaction({ transaction in
        try transaction.update(cacheMutation) { data in
          data.hero.name = "Artoo"
        }
      }, completion: { result in
        defer { updateCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      })

      self.wait(for: [updateCompletedExpectation], timeout: Self.defaultWaitTimeout)
    }

    runActivity("read queries") { _ in
      let readCompletedExpectation = expectation(description: "Read completed")
      readCompletedExpectation.expectedFulfillmentCount = 2

      let query = MockQuery<GivenSelectionSet>()
      query.variables = ["episode": Episode.JEDI]

      loadFromStore(query: query) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)

          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero.name, "Artoo")

          readCompletedExpectation.fulfill()
        }
      }

      query.variables = ["episode": Episode.PHANTOM_MENACE]

      loadFromStore(query: query) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)

          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero.name, "Qui-Gon Jinn")

          readCompletedExpectation.fulfill()
        }
      }

      self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func test_updateCacheMutation_givenAddNewReferencedEntity_entityIsIncludedOnRead() throws {
    /// given
    struct GivenSelectionSet: MockMutableRootSelectionSet {
      public var data: DataDict = DataDict([:], variables: nil)

      static var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      var hero: Hero {
        get { data["hero"] }
        set { data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var data: DataDict = DataDict([:], variables: nil)

        static var selections: [Selection] { [
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self),
        ]}

        var name: String {
          get { data["name"] }
          set { data["name"] = newValue }
        }

        var friends: [Friend] {
          get { data["friends"] }
          set { data["friends"] = newValue }
        }

        struct Friend: MockMutableRootSelectionSet {
          public var data: DataDict = DataDict([:], variables: nil)

          static var selections: [Selection] { [
            .field("id", String.self),
            .field("name", String.self),
          ]}

          var id: String {
            get { data["id"] }
            set { data["id"] = newValue }
          }

          var name: String {
            get { data["name"] }
            set { data["name"] = newValue }
          }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("2001")],
      "2001": [
        "name": "R2-D2",
        "id": "2001",
        "__typename": "Droid",
        "friends": [
          CacheReference("1000"),
          CacheReference("1002"),
          CacheReference("1003")
        ]
      ],
      "1000": ["__typename": "Human", "name": "Luke Skywalker", "id": "1000"],
      "1002": ["__typename": "Human", "name": "Han Solo", "id": "1002"],
      "1003": ["__typename": "Human", "name": "Leia Organa", "id": "1003"],
    ])

    runActivity("Add C-3PO Entity and Reference") { _ in
      let updateCompletedExpectation = expectation(description: "Update completed")
      let cacheMutation = MockLocalCacheMutation<GivenSelectionSet>()

      store.withinReadWriteTransaction({ transaction in
        try transaction.update(cacheMutation) { data in
          var c3po = GivenSelectionSet.Hero.Friend()
          c3po.__typename = "Droid"
          c3po.id = "1004"
          c3po.name = "C-3PO"

          data.hero.friends.append(c3po)
        }
      }, completion: { result in
        defer { updateCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      })

      self.wait(for: [updateCompletedExpectation], timeout: Self.defaultWaitTimeout)
    }

    runActivity("read query") { _ in
      let readCompletedExpectation = expectation(description: "Read completed")
      let query = MockQuery<GivenSelectionSet>()

      loadFromStore(query: query) { result in
        try XCTAssertSuccessResult(result) { graphQLResult in
          XCTAssertEqual(graphQLResult.source, .cache)
          XCTAssertNil(graphQLResult.errors)

          let data = try XCTUnwrap(graphQLResult.data)
          XCTAssertEqual(data.hero.name, "R2-D2")
          let friendsNames = data.hero.friends.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])

          readCompletedExpectation.fulfill()
        }
      }

      self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func test_writeDataForCacheMutation_givenInvalidData_throwsError() throws {
    // given
    struct GivenSelectionSet: MockMutableRootSelectionSet {
      public var data: DataDict = DataDict([:], variables: nil)

      static var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      var hero: Hero? {
        get { data["hero"] }
        set { data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var data: DataDict = DataDict([:], variables: nil)

        static var selections: [Selection] { [
          .field("name", String.self)
        ]}

        var name: String? {
          get { data["name"] }
          set { data["name"] = newValue }
        }
      }
    }

    // when
    let writeCompletedExpectation = expectation(description: "Write completed")

    store.withinReadWriteTransaction({ transaction in
      let data = GivenSelectionSet(data: DataDict([:], variables: nil))
      let cacheMutation = MockLocalCacheMutation<GivenSelectionSet>()
      try transaction.write(data: data, for: cacheMutation)
    }, completion: { result in
      defer { writeCompletedExpectation.fulfill() }

      XCTAssertFailureResult(result) { error in
        if let error = error as? GraphQLExecutionError {
          XCTAssertEqual(error.path, ["hero"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    })

    self.wait(for: [writeCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }

  func test_updateObjectWithKey_readAfterUpdateWithinSameTransaction_hasUpdatedValue() throws {
    // given
    struct GivenSelectionSet: MockMutableRootSelectionSet {
      public var data: DataDict = DataDict([:], variables: nil)

      static var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      var hero: Hero {
        get { data["hero"] }
        set { data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var data: DataDict = DataDict([:], variables: nil)

        static var selections: [Selection] { [
          .field("name", String.self)
        ]}

        var name: String {
          get { data["name"] }
          set { data["name"] = newValue }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": ["__typename": "Droid", "name": "R2-D2"]
    ])

    // then
    let readAfterUpdateCompletedExpectation = expectation(description: "Read after update completed")

    store.withinReadWriteTransaction({ transaction in
      try transaction.updateObject(
        ofType: GivenSelectionSet.self,
        withKey: "QUERY_ROOT", { data in
          data.hero.name = "Artoo"
        })

      let data = try transaction.readObject(
        ofType: GivenSelectionSet.self,
        withKey: "QUERY_ROOT"
      )

      XCTAssertEqual(data.hero.name, "Artoo")

    }, completion: { result in
      defer { readAfterUpdateCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })

    self.wait(for: [readAfterUpdateCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }

  func testUpdateObjectWithKey_givenFragment_updatesObject() throws {
    /// given
    struct GivenFragment: MockMutableRootSelectionSet, Fragment {
      static var fragmentDefinition: StaticString { "" }

      public var data: DataDict = DataDict([:], variables: nil)

      static var selections: [Selection] { [
        .field("id", String.self),
        .field("friends", [Friend].self),
      ]}

      var friends: [Friend] {
        get { data["friends"] }
        set { data["friends"] = newValue }
      }

      struct Friend: MockMutableRootSelectionSet {
        public var data: DataDict = DataDict([:], variables: nil)

        static var selections: [Selection] { [
          .field("id", String.self),
          .field("name", String.self),
        ]}

        var id: String {
          get { data["id"] }
          set { data["id"] = newValue }
        }

        var name: String {
          get { data["name"] }
          set { data["name"] = newValue }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("2001")],
      "2001": [
        "name": "R2-D2",
        "id": "2001",
        "__typename": "Droid",
        "friends": [
          CacheReference("1000"),
          CacheReference("1002"),
          CacheReference("1003")
        ]
      ],
      "1000": ["__typename": "Human", "name": "Luke Skywalker", "id": "1000"],
      "1002": ["__typename": "Human", "name": "Han Solo", "id": "1002"],
      "1003": ["__typename": "Human", "name": "Leia Organa", "id": "1003"],
    ])

    let updateCompletedExpectation = expectation(description: "Update completed")

    store.withinReadWriteTransaction({ transaction in
      try transaction.updateObject(
        ofType: GivenFragment.self,
        withKey: "2001"
      ) { friendsNamesFragment in
        var c3po = GivenFragment.Friend()
        c3po.__typename = "Droid"
        c3po.id = "1004"
        c3po.name = "C-3PO"

        friendsNamesFragment.friends.append(c3po)
      }
    }, completion: { result in
      defer { updateCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })

    self.wait(for: [updateCompletedExpectation], timeout: Self.defaultWaitTimeout)

    class HeroFriendsSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      var hero: Hero { data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self)
        ]}

        var friends: [Friend] { data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
            .field("name", String.self),
          ]}
        }
      }
    }

    let query = MockQuery<HeroFriendsSelectionSet>()
    loadFromStore(query: query) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)

        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero.name, "R2-D2")
        let friendsNames: [String] = data.hero.friends.compactMap { $0.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
      }
    }
  }

  // MARK: - Remove Object

  func test_removeObject_givenReferencedByOtherRecord_thenReadQueryReferencingRemovedRecord_throwsError() throws {
    /// given
    struct GivenSelectionSet: MockMutableRootSelectionSet {
      public var data: DataDict = DataDict([:], variables: nil)

      static var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      var hero: Hero? {
        get { data["hero"] }
        set { data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var data: DataDict = DataDict([:], variables: nil)

        static var selections: [Selection] { [
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self),
        ]}

        var name: String? {
          get { data["name"] }
          set { data["name"] = newValue }
        }

        var friends: [Friend] {
          get { data["friends"] }
          set { data["friends"] = newValue }
        }

        struct Friend: MockMutableRootSelectionSet {
          public var data: DataDict = DataDict([:], variables: nil)

          static var selections: [Selection] { [
            .field("id", String.self),
            .field("name", String.self),
          ]}

          var name: String {
            get { data["name"] }
            set { data["name"] = newValue }
          }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("2001")],
      "2001": [
        "name": "R2-D2",
        "id": "2001",
        "__typename": "Droid",
        "friends": [
          CacheReference("1000"),
          CacheReference("1002"),
          CacheReference("1003")
        ]
      ],
      "1000": ["__typename": "Human", "name": "Luke Skywalker", "id": "1000"],
      "1002": ["__typename": "Human", "name": "Han Solo", "id": "1002"],
      "1003": ["__typename": "Human", "name": "Leia Organa", "id": "1003"],
    ])

    runActivity("delete record for Leia Organa") { _ in
      let readWriteCompletedExpectation = expectation(description: "ReadWrite completed")

      store.withinReadWriteTransaction({ transaction in
        try transaction.removeObject(for: "1003")
      }, completion: { result in
        defer { readWriteCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      })

      self.wait(for: [readWriteCompletedExpectation], timeout: Self.defaultWaitTimeout)
    }

    runActivity("Read query with deleted record reference") { _ in
      let query = MockQuery<GivenSelectionSet>()
      let readCompletedExpectation = expectation(description: "Read completed")

      store.withinReadTransaction({ transaction in
        _ = try transaction.read(query: query)
      }, completion: { result in
        defer { readCompletedExpectation.fulfill() }
        XCTAssertFailureResult(result) { readError in
          guard let error = readError as? GraphQLExecutionError else {
            XCTFail("Unexpected error for reading removed record: \(readError)")
            return
          }

          /// The error should occur when trying to load all the hero's friend references, since one has been deleted
          XCTAssertEqual(error.path, ["hero", "friends", "2"])
          expect(error.underlying as? JSONDecodingError).to(equal(JSONDecodingError.missingValue))
        }
      })

      self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
    }
  }

  func test_removeObjectsMatchingPattern_givenPatternNotMatchingKeyCase_deletesCaseInsensitiveMatchingRecords() throws {
    // given
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

    let query = MockQuery<HeroNameSelectionSet>()

    // then
    let heroKey = "hero"

    //
    // 1. Merge all required records into the cache with lowercase key
    //

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["\(heroKey.lowercased())": CacheReference("QUERY_ROOT.\(heroKey.lowercased())")],
      "QUERY_ROOT.\(heroKey.lowercased())": ["__typename": "Droid", "name": "R2-D2"]
    ])

    //
    // 2. Remove object matching case insensitive (uppercase) key
    // - This should remove `QUERY_ROOT.hero` using pattern `QUERY_ROOT.HERO`
    //

    let removeRecordsCompletedExpectation = expectation(description: "Remove cache record by key pattern")

    store.withinReadWriteTransaction({ transaction in
      try transaction.removeObjects(matching: "\(heroKey.uppercased())")
    }, completion: { result in
      defer { removeRecordsCompletedExpectation.fulfill() }

      XCTAssertSuccessResult(result)
    })

    waitForExpectations(timeout: Self.defaultWaitTimeout)

    //
    // 3. Attempt to read records after pattern removal - expected FAIL
    //

    let readAfterRemoveCompletedExpectation = expectation(description: "Read from cache after removal by pattern")

    store.withinReadTransaction({ transaction in
      _ = try transaction.read(query: query)

    }, completion: { result in
      defer { readAfterRemoveCompletedExpectation.fulfill() }

      XCTAssertFailureResult(result) { error in
        if let error = error as? GraphQLExecutionError {
          XCTAssertEqual(error.path, ["hero"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    })

    waitForExpectations(timeout: Self.defaultWaitTimeout)
  }

  func test_removeObjectsMatchingPattern_givenKeyMatchingSubrangePattern_deletesMultipleRecords() throws {
    // given
    enum Episode: String, EnumType {
      case NEWHOPE
      case JEDI
      case EMPIRE
    }

    class HeroFriendsSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self, arguments: ["episode": .variable("episode")])
      ]}

      var hero: Hero { data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self)
        ]}

        var friends: [Friend] { data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
            .field("name", String.self),
          ]}
        }
      }
    }

    //
    // 1. Merge all required records into the cache
    //
    mergeRecordsIntoCache([
      "QUERY_ROOT": [
        "hero(episode:NEWHOPE)": CacheReference("1002"),
        "hero(episode:JEDI)": CacheReference("1101"),
        "hero(episode:EMPIRE)": CacheReference("2001")
      ],
      "2001": [
        "id": "2001",
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          CacheReference("1101"),
          CacheReference("1003")
        ]
      ],
      "1101": [
        "__typename": "Human", "name": "Luke Skywalker", "id": "1101", "friends": []
      ],
      "1002": [
        "__typename": "Human", "name": "Han Solo", "id": "1002", "friends": []
      ],
      "1003": [
        "__typename": "Human", "name": "Leia Organa", "id": "1003", "friends": []
      ],
    ])

    //
    // 2. Remove all objects matching the pattern `100`
    // - This will remove `1002` (Han Solo, hero for the .newhope episode)
    // - This will remove `1003` (Leia Organa, friend of the hero in .empire episode)
    //

    let removeFromCacheCompletedExpectation = expectation(description: "Hero objects removed from cache by pattern")

    store.withinReadWriteTransaction({ transaction in
      try transaction.removeObjects(matching: "100")
    }, completion: { result in
      defer { removeFromCacheCompletedExpectation.fulfill() }

      XCTAssertSuccessResult(result)
    })

    waitForExpectations(timeout: Self.defaultWaitTimeout)

    //
    // 3. Attempt to read records after pattern removal
    // - .newhope episode query expected to FAIL on the `hero` path
    // - .jedi episdoe query expected to SUCCEED
    // - .empire episode query expected to FAIL on the `hero.friends` path
    //

    let readHeroNewHopeAfterRemoveCompletedExpectation = expectation(description: "Read removed hero object for .newhope episode from cache")

    store.withinReadTransaction({ transaction in
      let query = MockQuery<HeroFriendsSelectionSet>()
      query.variables = ["episode": "NEWHOPE"]
      _ = try transaction.read(query: query)

    }, completion: { newHopeResult in
      defer { readHeroNewHopeAfterRemoveCompletedExpectation.fulfill() }

      XCTAssertFailureResult(newHopeResult) { error in
        if let error = error as? GraphQLExecutionError {
          XCTAssertEqual(error.path, ["hero"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    })

    let readHeroJediAfterRemoveCompletedExpectation = expectation(description: "Read removed hero object for .jedi episode from cache")

    store.withinReadTransaction({ transaction in
      let query = MockQuery<HeroFriendsSelectionSet>()
      query.variables = ["episode": "JEDI"]
      let data = try transaction.read(query: query)

      XCTAssertEqual(data.hero.__typename, "Human")
      XCTAssertEqual(data.hero.name, "Luke Skywalker")

    }, completion: { jediResult in
      defer { readHeroJediAfterRemoveCompletedExpectation.fulfill() }

      XCTAssertSuccessResult(jediResult)
    })

    let readHeroEmpireAfterRemoveCompletedExpectation = expectation(description: "Read removed hero object for .empire episode from cache")

    store.withinReadTransaction({ transaction in
      let query = MockQuery<HeroFriendsSelectionSet>()
      query.variables = ["episode": "EMPIRE"]
      _ = try transaction.read(query: query)

    }, completion: { empireResult in
      defer { readHeroEmpireAfterRemoveCompletedExpectation.fulfill() }

      XCTAssertFailureResult(empireResult) { error in
        if let error = error as? GraphQLExecutionError {
          XCTAssertEqual(error.path, ["hero.friends.1"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    })

    waitForExpectations(timeout: Self.defaultWaitTimeout)
  }
}

// MARK: Helpers

fileprivate func expectJSONMissingValueError(
  _ result: Result<(), Error>,
  atPath path: ResponsePath,
  file: FileString = #file, line: UInt = #line
) {
  guard case let .failure(readError) = result else {
    fail("Expected JSON Missing Value Error: \(result)",
         file: file, line: line)
    return
  }

  if let error = readError as? GraphQLExecutionError {
    expect(file: file, line: line, error.path).to(equal(path))
    switch error.underlying {
    case JSONDecodingError.missingValue:
      // This is correct.
      break
    default:
      fail("Expected JSON Missing Value Error: \(result)",
           file: file, line: line)
    }
  } else {
    expect(readError as? JSONDecodingError).to(equal(.missingValue))
  }
}

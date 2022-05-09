import XCTest
@testable import Apollo
import ApolloAPI
#if canImport(ApolloSQLite)
import ApolloSQLite
#endif
import ApolloInternalTestHelpers

class LoadQueryFromStoreTests: XCTestCase, CacheDependentTesting, StoreLoading {
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
  
  func testLoadingHeroNameQuery() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
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

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])

    // when
    let query = MockQuery<GivenSelectionSet>()
    
    loadFromStore(query: query) { result in
      // then
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
    }
  }
  
  func testLoadingHeroNameQueryWithVariable() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
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

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero(episode:JEDI)": CacheReference("hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ])

    // when
    let query = MockQuery<GivenSelectionSet>()
    query.variables = ["episode": "JEDI"]
    
    loadFromStore(query: query) { result in
      // then
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
    }
  }
  
  func testLoadingHeroNameQueryWithMissingName_throwsMissingValueError() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
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

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": ["__typename": "Droid"]
    ])

    // when
    let query = MockQuery<GivenSelectionSet>()
    
    loadFromStore(query: query) { result in
      // then
      XCTAssertThrowsError(try result.get()) { error in
        if let error = error as? GraphQLResultError {
          XCTAssertEqual(error.path, ["hero", "name"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
  }
  
  func testLoadingHeroNameQueryWithNullName_throwsNullValueError() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
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

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": ["__typename": "Droid", "name": NSNull()]
    ])
    
    // when
    let query = MockQuery<GivenSelectionSet>()
    
    loadFromStore(query: query) { result in
      // then
      XCTAssertThrowsError(try result.get()) { error in
        if let error = error as? GraphQLResultError {
          XCTAssertEqual(error.path, ["hero", "name"])
          XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithoutIDs() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}
      var hero: Hero { data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self)
        ]}
        var friends: [Friend] { data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("name", String.self)
          ]}
          var name: String { data["name"] }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          CacheReference("hero.friends.0"),
          CacheReference("hero.friends.1"),
          CacheReference("hero.friends.2")
        ]
      ],
      "hero.friends.0": ["__typename": "Human", "name": "Luke Skywalker"],
      "hero.friends.1": ["__typename": "Human", "name": "Han Solo"],
      "hero.friends.2": ["__typename": "Human", "name": "Leia Organa"],
    ])

    // when
    let query = MockQuery<GivenSelectionSet>()

    loadFromStore(query: query) { result in
      // then
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero.name, "R2-D2")
        let friendsNames = data.hero.friends.compactMap { $0.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithIDs() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}
      var hero: Hero { data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self)
        ]}
        var friends: [Friend] { data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("name", String.self)
          ]}
          var name: String { data["name"] }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("2001")],
      "2001": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          CacheReference("1000"),
          CacheReference("1002"),
          CacheReference("1003"),
        ]
      ],
      "1000": ["__typename": "Human", "name": "Luke Skywalker"],
      "1002": ["__typename": "Human", "name": "Han Solo"],
      "1003": ["__typename": "Human", "name": "Leia Organa"],
    ])
    
    // when
    let query = MockQuery<GivenSelectionSet>()

    loadFromStore(query: query) { result in
      // then
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero.name, "R2-D2")
        let friendsNames = data.hero.friends.compactMap { $0.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQuery_withOptionalFriendsSelection_withNullFriends() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}
      var hero: Hero { data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self)
        ]}
        var friends: [Friend]? { data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("name", String.self)
          ]}
          var name: String { data["name"] }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": NSNull(),
      ]
    ])
    
    // when
    let query = MockQuery<GivenSelectionSet>()
    
    loadFromStore(query: query) { result in
      // then
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero.name, "R2-D2")
        XCTAssertNil(data.hero.friends)
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQuery_withOptionalFriendsSelection_withFriendsNotInCache_throwsMissingValueError() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}
      var hero: Hero { data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self)
        ]}
        var friends: [Friend]? { data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("name", String.self)
          ]}
          var name: String { data["name"] }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    // when
    let query = MockQuery<GivenSelectionSet>()
    
    loadFromStore(query: query) { result in
      // then
      XCTAssertThrowsError(try result.get()) { error in
        if let error = error as? GraphQLResultError {
          XCTAssertEqual(error.path, ["hero", "friends"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
  }
  
  func testLoadingWithBadCacheSerialization() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}
      var hero: Hero { data["hero"] }

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self)
        ]}
        var friends: [Friend]? { data["friends"] }

        class Friend: MockSelectionSet {
          override class var selections: [Selection] {[
            .field("__typename", String.self),
            .field("name", String.self)
          ]}
          var name: String { data["name"] }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("2001")],
      "2001": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          CacheReference("1000"),
          CacheReference("1002"),
          CacheReference("1003")
        ]
      ],
      "1000": ["__typename": "Human", "name": ["dictionary": "badValues", "nested bad val": ["subdictionary": "some value"] ]
      ],
      "1002": ["__typename": "Human", "name": "Han Solo"],
      "1003": ["__typename": "Human", "name": "Leia Organa"],
    ])
    
    // when
    let query = MockQuery<GivenSelectionSet>()
    
    loadFromStore(query: query) { result in
      XCTAssertThrowsError(try result.get()) { error in
        // then
        if let error = error as? GraphQLResultError,
           case JSONDecodingError.couldNotConvert(_, let expectedType) = error.underlying {
          XCTAssertEqual(error.path, ["hero", "friends", "0", "name"])
          XCTAssertTrue(expectedType == String.self)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
  }
  
  func testLoadingQueryWithFloats() throws {
    // given
    let starshipLength: Float = 1234.5
    let coordinates: [[Double]] = [[38.857150, -94.798464]]

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("starshipCoordinates", Starship.self)
      ]}

      class Starship: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("length", Float.self),
          .field("coordinates", [[Double]].self)
        ]}
      }
    }
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["starshipCoordinates": CacheReference("starshipCoordinates")],
      "starshipCoordinates": ["__typename": "Starship",
                              "name": "Millennium Falcon",
                              "length": starshipLength,
                              "coordinates": coordinates]
    ])
    
    // when
    let query = MockQuery<GivenSelectionSet>()
    
    loadFromStore(query: query) { result in
      // then
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        let coordinateData: GivenSelectionSet.Starship? = data.starshipCoordinates
        XCTAssertEqual(coordinateData?.name, "Millennium Falcon")
        XCTAssertEqual(coordinateData?.length, starshipLength)
        XCTAssertEqual(coordinateData?.coordinates, coordinates)
      }
    }
  }
}

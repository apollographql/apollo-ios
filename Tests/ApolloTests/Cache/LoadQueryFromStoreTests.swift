import XCTest
@testable import Apollo
#if canImport(ApolloSQLite)
import ApolloSQLite
#endif
import ApolloTestSupport
import StarWarsAPI

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
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery()
    
    loadFromStore(query: query) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
    }
  }
  
  func testLoadingHeroNameQueryWithVariable() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero(episode:JEDI)": CacheReference(key: "hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery(episode: .jedi)
    
    loadFromStore(query: query) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
    }
  }
  
  func testLoadingHeroNameQueryWithMissingName() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": ["__typename": "Droid"]
    ])
    
    let query = HeroNameQuery()
    
    loadFromStore(query: query) { result in
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
  
  func testLoadingHeroNameQueryWithNullName() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": ["__typename": "Droid", "name": NSNull()]
    ])
    
    let query = HeroNameQuery()
    
    loadFromStore(query: query) { result in
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
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero(episode:JEDI)": CacheReference(key: "hero(episode:JEDI)")],
      "hero(episode:JEDI)": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          CacheReference(key: "hero(episode:JEDI).friends.0"),
          CacheReference(key: "hero(episode:JEDI).friends.1"),
          CacheReference(key: "hero(episode:JEDI).friends.2")
        ]
      ],
      "hero(episode:JEDI).friends.0": ["__typename": "Human", "name": "Luke Skywalker"],
      "hero(episode:JEDI).friends.1": ["__typename": "Human", "name": "Han Solo"],
      "hero(episode:JEDI).friends.2": ["__typename": "Human", "name": "Leia Organa"],
    ])
    
    let query = HeroAndFriendsNamesQuery(episode: .jedi)
    
    loadFromStore(query: query) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithIDs() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "2001")],
      "2001": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          CacheReference(key: "1000"),
          CacheReference(key: "1002"),
          CacheReference(key: "1003"),
        ]
      ],
      "1000": ["__typename": "Human", "name": "Luke Skywalker"],
      "1002": ["__typename": "Human", "name": "Han Solo"],
      "1003": ["__typename": "Human", "name": "Leia Organa"],
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    loadFromStore(query: query) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithNullFriends() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": NSNull(),
      ]
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    loadFromStore(query: query) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        XCTAssertNil(data.hero?.friends)
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithMissingFriends() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    loadFromStore(query: query) { result in
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
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "2001")],
      "2001": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          CacheReference(key: "1000"),
          CacheReference(key: "1002"),
          CacheReference(key: "1003")
        ]
      ],
      "1000": ["__typename": "Human", "name": ["dictionary": "badValues", "nested bad val": ["subdictionary": "some value"] ]
      ],
      "1002": ["__typename": "Human", "name": "Han Solo"],
      "1003": ["__typename": "Human", "name": "Leia Organa"],
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    loadFromStore(query: query) { result in
      XCTAssertThrowsError(try result.get()) { error in
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
    let starshipLength = 1234.5
    let coordinates = [[38.857150, -94.798464]]
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["starshipCoordinates(coordinates:\(coordinates))": CacheReference(key: "starshipCoordinates(coordinates:\(coordinates))")],
      "starshipCoordinates(coordinates:\(coordinates))": ["__typename": "Starship",
                                                          "name": "Millennium Falcon",
                                                          "length": starshipLength,
                                                          "coordinates": coordinates]
    ])
    
    let query = StarshipCoordinatesQuery(coordinates: coordinates)
    
    loadFromStore(query: query) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.starshipCoordinates?.name, "Millennium Falcon")
        XCTAssertEqual(data.starshipCoordinates?.length, starshipLength)
        XCTAssertEqual(data.starshipCoordinates?.coordinates, coordinates)
      }
    }
  }
}

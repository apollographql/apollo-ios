import XCTest
@testable import Apollo

class LoadQueryFromStoreTests: XCTestCase {
  var store: ApolloStore!
  
  func testLoadingHeroNameQuery() throws {
    store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery()
    
    let data = try store.load(query: query)
    
    XCTAssertEqual(data.hero?.name, "R2-D2")
  }
  
  func testLoadingHeroNameQueryWithVariable() throws {
    store = ApolloStore(records: [
      "QUERY_ROOT": ["hero(episode:JEDI)": Reference(key: "hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery(episode: .jedi)
    
    let data = try store.load(query: query)
    
    XCTAssertEqual(data.hero?.name, "R2-D2")
  }
  
  func testLoadingHeroNameQueryWithMissingName() throws {
    store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid"]
      ])
    
    let query = HeroNameQuery()
    
    XCTAssertThrowsError(try store.load(query: query)) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["hero", "name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testLoadingHeroNameQueryWithNullName() throws {
    store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid", "name": NSNull()]
      ])
    
    let query = HeroNameQuery()
    
    XCTAssertThrowsError(try store.load(query: query)) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["hero", "name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQuery() throws {
    store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "2001")],
      "2001": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          Reference(key: "1000"),
          Reference(key: "1002"),
          Reference(key: "1003")
        ]
      ],
      "1000": ["__typename": "Human", "name": "Luke Skywalker"],
      "1002": ["__typename": "Human", "name": "Han Solo"],
      "1003": ["__typename": "Human", "name": "Leia Organa"],
      ])
    
    let query = HeroAndFriendsNamesQuery()
    
    let data = try store.load(query: query)
    
    XCTAssertEqual(data.hero?.name, "R2-D2")
    let friendsNames = data.hero?.friends?.flatMap { $0?.name }
    XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithNullFriends() throws {
    store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": NSNull(),
      ]
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    let data = try store.load(query: query)
    
    XCTAssertEqual(data.hero?.name, "R2-D2")
    XCTAssertNil(data.hero?.friends)
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithMissingFriends() throws {
    store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    XCTAssertThrowsError(try store.load(query: query)) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["hero", "friends"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
}

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
    
    load(query: query) { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      XCTAssertEqual(result?.data?.hero?.name, "R2-D2")
    }
  }
  
  func testLoadingHeroNameQueryWithVariable() throws {
    store = ApolloStore(records: [
      "QUERY_ROOT": ["hero(episode:JEDI)": Reference(key: "hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery(episode: .jedi)
    
    load(query: query) { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      XCTAssertEqual(result?.data?.hero?.name, "R2-D2")
    }
  }
  
  func testLoadingHeroNameQueryWithMissingName() throws {
    store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid"]
    ])
    
    let query = HeroNameQuery()
    
    load(query: query) { (result, error) in
      XCTAssertNil(result)
      
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
    
    load(query: query) { (result, error) in
      XCTAssertNil(result)
      
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["hero", "name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithoutIDs() throws {
    store = ApolloStore(records: [
      "QUERY_ROOT": ["hero(episode:JEDI)": Reference(key: "hero(episode:JEDI)")],
      "hero(episode:JEDI)": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          Reference(key: "hero(episode:JEDI).friends.0"),
          Reference(key: "hero(episode:JEDI).friends.1"),
          Reference(key: "hero(episode:JEDI).friends.2")
        ]
      ],
      "hero(episode:JEDI).friends.0": ["__typename": "Human", "name": "Luke Skywalker"],
      "hero(episode:JEDI).friends.1": ["__typename": "Human", "name": "Han Solo"],
      "hero(episode:JEDI).friends.2": ["__typename": "Human", "name": "Leia Organa"],
    ])
    
    let query = HeroAndFriendsNamesQuery(episode: .jedi)
    
    load(query: query) { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      
      guard let data = result?.data else { XCTFail(); return }
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithIDs() throws {
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
    
    load(query: query) { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      
      guard let data = result?.data else { XCTFail(); return }
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
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
    
    load(query: query) { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      
      guard let data = result?.data else { XCTFail(); return }
      XCTAssertEqual(data.hero?.name, "R2-D2")
      XCTAssertNil(data.hero?.friends)
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithMissingFriends() throws {
    store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    load(query: query) { (result, error) in
      XCTAssertNil(result)
      
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["hero", "friends"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  // MARK: - Helpers
  
  private func load<Query: GraphQLQuery>(query: Query, resultHandler: @escaping OperationResultHandler<Query>) {
    let expectation = self.expectation(description: "Loading query from store")
    
    store.load(query: query, cacheKeyForObject: nil) { (result, error) in
      resultHandler(result, error)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1, handler: nil)
  }
}

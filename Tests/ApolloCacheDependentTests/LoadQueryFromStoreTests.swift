import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class LoadQueryFromStoreTests: XCTestCase {
  var store: ApolloStore!
  
  func testLoadingHeroNameQuery() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ]

    withCache(initialRecords: initialRecords) { (cache) in
      store = ApolloStore(cache: cache)

      let query = HeroNameQuery()

      load(query: query) { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
  }
  
  func testLoadingHeroNameQueryWithVariable() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero(episode:JEDI)": Reference(key: "hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ]

    withCache(initialRecords: initialRecords) { (cache) in
      store = ApolloStore(cache: cache)

      let query = HeroNameQuery(episode: .jedi)

      load(query: query) { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
  }
  
  func testLoadingHeroNameQueryWithMissingName() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid"]
    ]

    withCache(initialRecords: initialRecords) { (cache) in
      store = ApolloStore(cache: cache)

      let query = HeroNameQuery()

      load(query: query) { result in
        switch result {
        case .success:
          XCTFail("This should not have succeeded!")
        case .failure(let error):
          if let graphQLError = error as? GraphQLResultError {
            XCTAssertEqual(graphQLError.path, ["hero", "name"])
            XCTAssertMatch(graphQLError.underlying, JSONDecodingError.missingValue)
          } else {
            XCTFail("Unexpected error: \(error)")
          }
        }
      }
    }
  }
  
  func testLoadingHeroNameQueryWithNullName() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid", "name": NSNull()]
    ]

    withCache(initialRecords: initialRecords) { (cache) in
      store = ApolloStore(cache: cache)

      let query = HeroNameQuery()

      load(query: query) { result in
        switch result {
        case .success:
          XCTFail("This should not have succeeded!")
        case .failure(let error):
          if let graphQLError = error as? GraphQLResultError {
            XCTAssertEqual(graphQLError.path, ["hero", "name"])
            XCTAssertMatch(graphQLError.underlying, JSONDecodingError.nullValue)
          } else {
            XCTFail("Unexpected error: \(error)")
          }
        }
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithoutIDs() throws {
    let initialRecords: RecordSet = [
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
      ]

    withCache(initialRecords: initialRecords) { (cache) in
      store = ApolloStore(cache: cache)

      let query = HeroAndFriendsNamesQuery(episode: .jedi)

      load(query: query) { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          
          guard let data = graphQLResult.data else {
            XCTFail("No data returned with result")
            return
          }
          
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, [
            "Luke Skywalker",
            "Han Solo",
            "Leia Organa",
          ])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithIDs() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "2001")],
      "2001": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          Reference(key: "1000"),
          Reference(key: "1002"),
          Reference(key: "1003"),
        ]
      ],
      "1000": ["__typename": "Human", "name": "Luke Skywalker"],
      "1002": ["__typename": "Human", "name": "Han Solo"],
      "1003": ["__typename": "Human", "name": "Leia Organa"],
      ]

    withCache(initialRecords: initialRecords) { (cache) in
      store = ApolloStore(cache: cache)

      let query = HeroAndFriendsNamesQuery()

      load(query: query) { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          
          guard let data = graphQLResult.data else {
            XCTFail("No data in result!")
            return
          }
          
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, [
            "Luke Skywalker",
            "Han Solo",
            "Leia Organa",
          ])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithNullFriends() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": NSNull(),
      ]
    ]

    withCache(initialRecords: initialRecords) { (cache) in
      store = ApolloStore(cache: cache)

      let query = HeroAndFriendsNamesQuery()

      load(query: query) { result in
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          
          guard let data = graphQLResult.data else {
            XCTFail("No data in result!")
            return
          }
          
          XCTAssertEqual(data.hero?.name, "R2-D2")
          XCTAssertNil(data.hero?.friends)
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
  }
  
  func testLoadingHeroAndFriendsNamesQueryWithMissingFriends() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ]

    withCache(initialRecords: initialRecords) { (cache) in
      store = ApolloStore(cache: cache)

      let query = HeroAndFriendsNamesQuery()

      load(query: query) { result in
        switch result {
        case .success:
          XCTFail("This should not have succeeded!")
        case .failure(let error):
          if let graphQLError = error as? GraphQLResultError {
            XCTAssertEqual(graphQLError.path, ["hero", "friends"])
            XCTAssertMatch(graphQLError.underlying, JSONDecodingError.missingValue)
          } else {
            XCTFail("Unexpected error: \(String(describing: error))")
          }
        }
      }
    }
  }
  
  // MARK: - Helpers
  
  private func load<Query: GraphQLQuery>(query: Query, resultHandler: @escaping GraphQLResultHandler<Query.Data>) {
    let expectation = self.expectation(description: "Loading query from store")
    
    store.load(query: query) { result in
      resultHandler(result)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
}

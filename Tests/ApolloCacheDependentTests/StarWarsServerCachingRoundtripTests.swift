import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class StarWarsServerCachingRoundtripTests: XCTestCase, CacheTesting {
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  func testHeroAndFriendsNamesQuery() {
    let query = HeroAndFriendsNamesQuery()
    
    fetchAndLoadFromStore(query: query) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }
  
  func testHeroAndFriendsNamesQueryWithVariable() {
    let query = HeroAndFriendsNamesQuery(episode: .jedi)
    
    fetchAndLoadFromStore(query: query) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }
  
  func testHeroAndFriendsNamesWithIDsQuery() {
    let query = HeroAndFriendsNamesWithIDsQuery()
    
    fetchAndLoadFromStore(query: query, setupClient: { $0.store.cacheKeyForObject = {$0["id"]} }) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }
  
  private func fetchAndLoadFromStore<Query: GraphQLQuery>(query: Query, setupClient: ((ApolloClient) -> Void)? = nil, completionHandler: @escaping (_ data: Query.Data) -> Void) {
    withCache { (cache) in
      let network = HTTPNetworkTransport(url: URL(string: "http://localhost:8080/graphql")!)
      let store = ApolloStore(cache: cache)
      let client = ApolloClient(networkTransport: network, store: store)

      if let setupClient = setupClient {
        setupClient(client)
      }

      let expectation = self.expectation(description: "Fetching query")

      client.fetch(query: query) { outerResult in
        switch outerResult {
        case .failure(let error):
          XCTFail("Unexpected error with fetch: \(error)")
          expectation.fulfill()
          return
        case .success(let fetchGraphQLResult):
          XCTAssertNil(fetchGraphQLResult.errors)
          
          guard fetchGraphQLResult.data != nil else {
            XCTFail("No query result data from fetching!")
            expectation.fulfill()
            return
          }
          
          client.store.load(query: query) { innerResult in
            defer { expectation.fulfill() }
            
            switch innerResult {
            case .success(let loadGraphQLResult):
              guard let data = loadGraphQLResult.data else {
                XCTFail("No query result data from loading!")
                return
              }
              
              completionHandler(data)
            case .failure(let error):
              XCTFail("Error while loading query from store: \(error.localizedDescription)")
            }
          }
        }
      }

      waitForExpectations(timeout: 5, handler: nil)
    }
  }
}

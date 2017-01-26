import XCTest
@testable import Apollo

class StarWarsServerCachingRoundtripTests: XCTestCase {
  var client: ApolloClient!
  
  override func setUp() {
    super.setUp()
    
    client = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)
  }
  
  func testHeroAndFriendsNamesQuery() {
    let query = HeroAndFriendsNamesQuery()
    
    fetchAndLoadFromStore(query: query) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }
  
  func testHeroAndFriendsNamesQueryWithVariable() {
    let query = HeroAndFriendsNamesQuery(episode: .jedi)
    
    fetchAndLoadFromStore(query: query) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }
  
  func testHeroAndFriendsNamesWithIDsQuery() {
    client.cacheKeyForObject = { $0["id"] }
    
    let query = HeroAndFriendsNamesWithIDsQuery()
    
    fetchAndLoadFromStore(query: query) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }
  
  private func fetchAndLoadFromStore<Query: GraphQLQuery>(query: Query, completionHandler: @escaping (_ data: Query.Data) -> Void) {
    let expectation = self.expectation(description: "Fetching query")
    
    client.fetch(query: query) { (result, error) in
      if let error = error { XCTFail("Error while fetching query: \(error.localizedDescription)");  return }
      guard let result = result else { XCTFail("No query result");  return }
      
      if let errors = result.errors {
        XCTFail("Errors in query result: \(errors)")
      }
      
      guard result.data != nil else { XCTFail("No query result data");  return }
            
      self.client.store.load(query: query, cacheKeyForObject: self.client.cacheKeyForObject) { (result, error) in
        defer { expectation.fulfill() }
        
        if let error = error { XCTFail("Error while loading query from store: \(error.localizedDescription)");  return }
        
        guard let data = result?.data else { XCTFail("No query result data");  return }
        
        completionHandler(data)
      }
    }
    
    waitForExpectations(timeout: 1, handler: nil)
  }
}

import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class SQLiteStarWarsServerCachingRoundtripTests: StarWarsServerCachingRoundtripTests {
  override var cacheType: TestCacheProvider.Type {
    SQLiteTestCacheProvider.self
  }
}

class StarWarsServerCachingRoundtripTests: XCTestCase, CacheDependentTesting {
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  var defaultWaitTimeout: TimeInterval = 5
  
  var cache: NormalizedCache!
  var store: ApolloStore!
  var client: ApolloClient!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    cache = try makeNormalizedCache()
    store = ApolloStore(cache: cache)
    let provider = LegacyInterceptorProvider(store: store)
    let network = RequestChainNetworkTransport(interceptorProvider: provider,
                                               endpointURL: TestServerURL.starWarsServer.url)
    
    client = ApolloClient(networkTransport: network, store: store)
  }
  
  override func tearDownWithError() throws {
    cache = nil
    store = nil
    client = nil
    
    try super.tearDownWithError()
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
    client.store.cacheKeyForObject = { $0["id"] }
    
    let query = HeroAndFriendsNamesWithIDsQuery()
    
    fetchAndLoadFromStore(query: query) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }
  
  // MARK: - Helpers
  
  private func fetchAndLoadFromStore<Query: GraphQLQuery>(query: Query, file: StaticString = #filePath, line: UInt = #line, completionHandler: @escaping (_ data: Query.Data) -> Void) {
    let fetchedFromServerExpectation = expectation(description: "Fetched query from server")
    
    client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
      defer { fetchedFromServerExpectation.fulfill() }
      XCTAssertSuccessResult(result, file: file, line: line)
    }
    
    wait(for: [fetchedFromServerExpectation], timeout: defaultWaitTimeout)
    
    let resultObserver = makeResultObserver(for: query, file: file, line: line)
    
    let loadedFromStoreExpectation = resultObserver.expectation(description: "Loaded query from store", file: file, line: line) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache, file: file, line: line)
        XCTAssertNil(graphQLResult.errors, file: file, line: line)
        
        let data = try XCTUnwrap(graphQLResult.data, file: file, line: line)
        completionHandler(data)
      }
    }
    
    store.load(query: query, resultHandler: resultObserver.handler)
    
    wait(for: [loadedFromStoreExpectation], timeout: defaultWaitTimeout)
  }
}

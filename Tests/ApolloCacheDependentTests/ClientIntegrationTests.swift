import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class ClientIntegrationTests: XCTestCase, CacheTesting {
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  var defaultWaitTimeout: TimeInterval = 1
  
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
  
  // MARK: - Helpers
  
  func mergeRecordsIntoCache(_ records: RecordSet) {
    let expectation = expectSuccessfulResult(description: "Merged records into cache") { handler in
      cache.merge(records: records, callbackQueue: nil, completion: handler)
    }
        
    wait(for: [expectation], timeout: defaultWaitTimeout)
  }
}

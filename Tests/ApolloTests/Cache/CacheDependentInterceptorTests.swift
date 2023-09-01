import XCTest
import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

class CacheDependentInterceptorTests: XCTestCase, CacheDependentTesting {
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  var cache: NormalizedCache!
  var store: ApolloStore!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    cache = try makeNormalizedCache()
    store = ApolloStore(cache: cache)
  }

  override func tearDown() {
    cache = nil
    store = nil
    
    super.tearDown()
  }
  
  func testChangingCachePolicyInErrorInterceptorWorks() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }
    }

    // Set up initial cache state
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    /// This interceptor will reroute anything that fails with a response code error to retry hitting only the cache
    class RerouteToCacheErrorInterceptor: ApolloErrorInterceptor {
      var handledError: Error?
      
      func handleErrorAsync<Operation: GraphQLOperation>(
        error: Error,
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
        
        self.handledError = error
        
        switch error {
        case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode:
          request.cachePolicy = .returnCacheDataDontFetch
          chain.retry(request: request, completion: completion)
        default:
          completion(.failure(error))
        }
      }
    }
    
    
    class TestProvider: DefaultInterceptorProvider {
      init(store: ApolloStore) {
        super.init(client: self.mockClient,
                   store: store)
      }
      
      let mockClient: MockURLSessionClient = {
        let client = MockURLSessionClient()
        client.response = HTTPURLResponse(url: TestURL.mockServer.url,
                                          statusCode: 401,
                                          httpVersion: nil,
                                          headerFields: nil)
        client.data = Data()
        return client
      }()
      
      let additionalInterceptor = RerouteToCacheErrorInterceptor()

      override func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor? {
        self.additionalInterceptor
      }
    }
    
    let testProvider = TestProvider(store: self.store)
    let network = RequestChainNetworkTransport(interceptorProvider: testProvider,
                                               endpointURL: TestURL.mockServer.url)
    
    let expectation = self.expectation(description: "Request sent")
    
    // Send the initial request ignoring cache data so it doesn't initially get the data from the cache,
    _ = network.send(operation: MockQuery<GivenSelectionSet>(), cachePolicy: .fetchIgnoringCacheData) { result in
      defer {
        expectation.fulfill()
      }
      
      // Check that the final result is what we expected
      switch result {
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      case .success(let graphQLResult):
        guard let heroName: String = graphQLResult.data?.hero?.name else {
          XCTFail("Could not access hero name from returned result")
          return
        }
        
        XCTAssertEqual(heroName, "R2-D2")
      }
      
      // Validate that there was a handled error before we went to the cache and we didn't just go straight to the cache
      guard let handledError =  testProvider.additionalInterceptor.handledError else {
        XCTFail("No error was handled!")
        return
      }
      switch handledError {
      case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(let response, _):
        XCTAssertEqual(response?.statusCode, 401)
      default:
        XCTFail("Unexpected error on the additional error handler: \(handledError)")
      }
    }
    
    self.wait(for: [expectation], timeout: 5.0)
  }
}


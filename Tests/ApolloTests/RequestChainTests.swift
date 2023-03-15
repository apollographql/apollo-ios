import XCTest
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

class RequestChainTests: XCTestCase {

  func testEmptyInterceptorArrayReturnsCorrectError() {
    class TestProvider: InterceptorProvider {
      func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        []
      }
    }

    let transport = RequestChainNetworkTransport(interceptorProvider: TestProvider(),
                                                 endpointURL: TestURL.mockServer.url)
    let expectation = self.expectation(description: "kickoff failed")
    _ = transport.send(operation: MockQuery.mock()) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success:
        XCTFail("This should not have succeeded")
      case .failure(let error):
        switch error {
        case InterceptorRequestChain.ChainError.noInterceptors:
          // This is what we want.
          break
        default:
          XCTFail("Incorrect error for no interceptors: \(error)")
        }
      }
    }
    
    
    self.wait(for: [expectation], timeout: 1)
  }
  
  func testCancellingChainCallsCancelOnInterceptorsWhichImplementCancellableAndNotOnOnesThatDont() {
    class TestProvider: InterceptorProvider {
      let cancellationInterceptor = CancellationHandlingInterceptor()
      let retryInterceptor = BlindRetryingTestInterceptor()

      func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        [
          self.cancellationInterceptor,
          self.retryInterceptor
        ]
      }
    }

    let provider = TestProvider()
    let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                 endpointURL: TestURL.mockServer.url)
    let expectation = self.expectation(description: "Send succeeded")
    expectation.isInverted = true
    let cancellable = transport.send(operation: MockQuery.mock()) { _ in
      XCTFail("This should not have gone through")
      expectation.fulfill()
    }
    
    cancellable.cancel()
    XCTAssertTrue(provider.cancellationInterceptor.hasBeenCancelled)
    XCTAssertFalse(provider.retryInterceptor.hasBeenCancelled)
    self.wait(for: [expectation], timeout: 2)
  }
  
  func testErrorInterceptorGetsCalledAfterAnErrorIsReceived() {
    class ErrorInterceptor: ApolloErrorInterceptor {
      var error: Error? = nil
      
      func handleErrorAsync<Operation: GraphQLOperation>(
          error: Error,
          chain: RequestChain,
          request: HTTPRequest<Operation>,
          response: HTTPResponse<Operation>?,
          completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
      
        self.error = error
        completion(.failure(error))
      }
    }
    
    class TestProvider: InterceptorProvider {
      let errorInterceptor = ErrorInterceptor()
      func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        return [
          // An interceptor which will error without a response
          AutomaticPersistedQueryInterceptor()
        ]
      }
      
      func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor? {
        return self.errorInterceptor
      }
    }

    let provider = TestProvider()
    let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                 endpointURL: TestURL.mockServer.url,
                                                 autoPersistQueries: true)
    
    let expectation = self.expectation(description: "Hero name query complete")
    _ = transport.send(operation: MockQuery.mock()) { result in
      defer {
        expectation.fulfill()
      }
      switch result {
      case .success:
        XCTFail("This should not have succeeded")
      case .failure(let error):
        switch error {
        case AutomaticPersistedQueryInterceptor.APQError.noParsedResponse:
          // This is what we want.
          break
        default:
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
    
    self.wait(for: [expectation], timeout: 1)
    
    switch provider.errorInterceptor.error {
    case .some(let error):
      switch error {
      case AutomaticPersistedQueryInterceptor.APQError.noParsedResponse:
        // Again, this is what we expect.
        break
      default:
        XCTFail("Unexpected error on the interceptor: \(error)")
      }
    case .none:
      XCTFail("Error interceptor did not receive an error!")
    }
  }
  
  func testErrorInterceptorGetsCalledInDefaultInterceptorProviderSubclass() {
    class ErrorInterceptor: ApolloErrorInterceptor {
      var error: Error? = nil
      
      func handleErrorAsync<Operation: GraphQLOperation>(
        error: Error,
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
        
        self.error = error
        completion(.failure(error))
      }
    }
    
    class TestProvider: DefaultInterceptorProvider {
      let errorInterceptor = ErrorInterceptor()
      
      override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        return [
          // An interceptor which will error without a response
          AutomaticPersistedQueryInterceptor()
        ]
      }
      
      override func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor? {
        return self.errorInterceptor
      }
    }

    let provider = TestProvider(store: ApolloStore())
    let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                 endpointURL: TestURL.mockServer.url,
                                                 autoPersistQueries: true)
    
    let expectation = self.expectation(description: "Hero name query complete")
    _ = transport.send(operation: MockQuery.mock()) { result in
      defer {
        expectation.fulfill()
      }
      switch result {
      case .success:
        XCTFail("This should not have succeeded")
      case .failure(let error):
        switch error {
        case AutomaticPersistedQueryInterceptor.APQError.noParsedResponse:
          // This is what we want.
          break
        default:
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
    
    self.wait(for: [expectation], timeout: 1)
    
    switch provider.errorInterceptor.error {
    case .some(let error):
      switch error {
      case AutomaticPersistedQueryInterceptor.APQError.noParsedResponse:
        // Again, this is what we expect.
        break
      default:
        XCTFail("Unexpected error on the interceptor: \(error)")
      }
    case .none:
      XCTFail("Error interceptor did not receive an error!")
    }
  }

  // MARK: Multipart subscription tests
  
  struct CallbackInterceptor: ApolloInterceptor {
    let callback: (URLRequest) -> (Void)

    init(_ callback: @escaping (URLRequest) -> (Void)) {
      self.callback = callback
    }

    func interceptAsync<Operation>(
      chain: RequestChain,
      request: HTTPRequest<Operation>,
      response: HTTPResponse<Operation>?,
      completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>
    ) -> Void) {
      callback(try! request.toURLRequest())
    }
  }

  struct MockInterceptorProvider: InterceptorProvider {
    let interceptors: [ApolloInterceptor]

    init(_ interceptors: [ApolloInterceptor]) {
      self.interceptors = interceptors
    }

    func interceptors<Operation>(for operation: Operation) -> [ApolloInterceptor] {
      self.interceptors
    }
  }

  func test__request__givenSubscription_shouldAddMultipartAcceptHeader() {
    let expectation = self.expectation(description: "Request header verified")

    let interceptor = CallbackInterceptor { request in
      guard let header = request.allHTTPHeaderFields?["Accept"] else {
        XCTFail()
        return
      }

      XCTAssertEqual(header, "multipart/mixed; boundary=\"graphql\"; subscriptionSpec=1.0, application/json")
      expectation.fulfill()
    }

    let transport = RequestChainNetworkTransport(
      interceptorProvider: MockInterceptorProvider([interceptor]),
      endpointURL: URL(string: "https://apollographql.com")!
    )

    _ = transport.send(operation: MockSubscription.mock()) { result in
      // noop
    }

    wait(for: [expectation], timeout: 1)
  }

  func test__request__givenQuery_shouldNotAddMultipartAcceptHeader() {
    let expectation = self.expectation(description: "Request header verified")

    let interceptor = CallbackInterceptor { request in
      if let header = request.allHTTPHeaderFields?["Accept"] {
        XCTAssertFalse(header.contains("multipart/mixed"))
      }

      expectation.fulfill()
    }

    let transport = RequestChainNetworkTransport(
      interceptorProvider: MockInterceptorProvider([interceptor]),
      endpointURL: URL(string: "https://apollographql.com")!
    )

    _ = transport.send(operation: MockQuery.mock()) { result in
      // noop
    }

    wait(for: [expectation], timeout: 1)
  }

  func test__request__givenMutation_shouldNotAddMultipartAcceptHeader() {
    let expectation = self.expectation(description: "Request header verified")

    let interceptor = CallbackInterceptor { request in
      if let header = request.allHTTPHeaderFields?["Accept"] {
        XCTAssertFalse(header.contains("multipart/mixed"))
      }

      expectation.fulfill()
    }

    let transport = RequestChainNetworkTransport(
      interceptorProvider: MockInterceptorProvider([interceptor]),
      endpointURL: URL(string: "https://apollographql.com")!
    )

    _ = transport.send(operation: MockMutation.mock()) { result in
      // noop
    }

    wait(for: [expectation], timeout: 1)
  }
}

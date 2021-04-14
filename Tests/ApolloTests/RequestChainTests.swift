//
//  RequestChainTests.swift
//  Apollo
//
//  Created by Ellen Shapiro on 7/14/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import XCTest
import Apollo
import ApolloTestSupport
import StarWarsAPI

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
    _ = transport.send(operation: HeroNameQuery()) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success:
        XCTFail("This should not have succeeded")
      case .failure(let error):
        switch error {
        case RequestChain.ChainError.noInterceptors:
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
    let cancellable = transport.send(operation: HeroNameQuery()) { _ in
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
    _ = transport.send(operation: HeroNameQuery()) { result in
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
  
  func testErrorInterceptorGetsCalledInLegacyInterceptorProviderSubclass() {
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
    
    class TestProvider: LegacyInterceptorProvider {
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
    _ = transport.send(operation: HeroNameQuery()) { result in
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
}

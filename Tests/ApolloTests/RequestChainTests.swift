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
  
  lazy var legacyClient: ApolloClient = {
    let url = TestURL.starWarsServer.url
    
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let provider = LegacyInterceptorProvider(store: store)
    let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                 endpointURL: url)
    
    return ApolloClient(networkTransport: transport)
  }()
  
  func testLoading() {
    let expectation = self.expectation(description: "loaded With legacy client")
    legacyClient.fetch(query: HeroNameQuery()) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
        
      }
      expectation.fulfill()
    }
    
    self.wait(for: [expectation], timeout: 10)
  }
  
  func testInitialLoadFromNetworkAndSecondaryLoadFromCache() {
    let initialLoadExpectation = self.expectation(description: "loaded With legacy client")
    legacyClient.fetch(query: HeroNameQuery()) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
        
      }
      initialLoadExpectation.fulfill()
    }
    
    self.wait(for: [initialLoadExpectation], timeout: 10)
    
    let secondLoadExpectation = self.expectation(description: "loaded With legacy client")
    legacyClient.fetch(query: HeroNameQuery()) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
        
      }
      secondLoadExpectation.fulfill()
    }
    
    self.wait(for: [secondLoadExpectation], timeout: 10)
  }
  
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
}

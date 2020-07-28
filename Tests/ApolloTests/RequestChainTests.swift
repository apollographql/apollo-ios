//
//  RequestChainTests.swift
//  Apollo
//
//  Created by Ellen Shapiro on 7/14/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import XCTest
import Apollo
import StarWarsAPI

class RequestChainTests: XCTestCase {
  
  lazy var legacyClient: ApolloClient = {
    let url = URL(string: "http://localhost:8080/graphql")!
    
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let transport = RequestChainNetworkTransport(interceptorProvider: LegacyInterceptorProvider(store: store), endpointURL: url)
    
    return ApolloClient(networkTransport: transport)
  }()
  
  func testLoading() {
    let expectation = self.expectation(description: "loaded With legacy client")
    legacyClient.fetchForResult(query: HeroNameQuery()) { result in
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
    legacyClient.fetchForResult(query: HeroNameQuery()) { result in
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
    legacyClient.fetchForResult(query: HeroNameQuery()) { result in
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
}

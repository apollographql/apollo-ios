//
//  HTTPTransportTests.swift
//  ApolloTests
//
//  Created by Ellen Shapiro on 7/1/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import Apollo
import StarWarsAPI

class HTTPTransportTests: XCTestCase {
  
  private var updatedHeaders: [String: String]?
  private var shouldSend = true

  private lazy var url = URL(string: "http://localhost:8080/")!
  private lazy var networkTransport = HTTPNetworkTransport(url: self.url,
                                                           delegate: self)
  
  func testDelegateTellingRequestNotToSend() {
    self.shouldSend = false
    
    let expectation = self.expectation(description: "Send operation completed")
    let cancellable = self.networkTransport.send(operation: HeroNameQuery()) { response, error in
      
      defer {
        expectation.fulfill()
      }
      
      guard let error = error else {
        XCTFail("Expected error not received when telling delegate not to send!")
        return
      }
      
      switch error {
      case GraphQLHTTPRequestError.cancelledByDeveloper:
        // Correct!
        break
      default:
        XCTFail("Expected `cancelledByDeveloper`, got \(error)")
      }
    }
    
    guard (cancellable as? ErrorCancellable) != nil else {
      XCTFail("Wrong cancellable type returned!")
      cancellable.cancel()
      expectation.fulfill()
      return
    }
    
    // This should fail without hitting the network.
    self.wait(for: [expectation], timeout: 1)
  }
  
  func testDelgateModifyingRequest() {
    self.updatedHeaders = ["Authorization": "Bearer HelloApollo"]

    let expectation = self.expectation(description: "Send operation completed")
    let cancellable = self.networkTransport.send(operation: HeroNameQuery()) { (response, error) in
      
      defer {
        expectation.fulfill()
      }
      
      if let responseError = error as? GraphQLHTTPResponseError {
        print(responseError.bodyDescription)
        XCTFail("Error!")
        return
      }
      
      guard let queryResponse = response else {
        XCTFail("No response!")
        return
      }
      
      guard
        let dictionary = queryResponse.body as? [String: AnyHashable],
        let dataDict = dictionary["data"] as? [String: AnyHashable],
        let heroDict = dataDict["hero"] as? [String: AnyHashable],
        let name = heroDict["name"] as? String else {
          XCTFail("No hero for you!")
          return
      }
      
      XCTAssertEqual(name, "R2-D2")
    }
    
    guard
      let task = cancellable as? URLSessionTask,
      let url = task.currentRequest?.url,
      let headers = task.currentRequest?.allHTTPHeaderFields else {
        cancellable.cancel()
        expectation.fulfill()
        return
    }
    
    XCTAssertEqual(url.absoluteString, "http://localhost:8080/graphql")
    XCTAssertEqual(headers["Authorization"], "Bearer HelloApollo")
    
    // This will come through after hitting the network.
    self.wait(for: [expectation], timeout: 10)
  }
}

extension HTTPTransportTests: HTTPNetworkTransportDelegate {
  func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool {
    return self.shouldSend
  }
  
  func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest) {
    guard let headers = self.updatedHeaders else {
      // Don't modify anything
      return
    }
    
    request.url = URL(string: "http://localhost:8080/graphql")!
    headers.forEach { tuple in
      let (key, value) = tuple
      var headers = request.allHTTPHeaderFields ?? [String: String]()
      headers[key] = value
      request.allHTTPHeaderFields = headers
    }
  }
}

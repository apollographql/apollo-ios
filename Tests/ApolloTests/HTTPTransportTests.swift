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
  
  private var completedRequest: URLRequest?
  private var completedData: Data?
  private var completedResponse: URLResponse?
  private var completedError: Error?
  
  private var shouldModifyURLInWillSend = false
  private var retryCount = 0

  private lazy var url = URL(string: "http://localhost:8080/graphql")!
  private lazy var networkTransport = HTTPNetworkTransport(url: self.url,
                                                           useGETForQueries: true,
                                                           delegate: self)
  
  private func validateHeroNameQueryResponse<Operation: GraphQLOperation>(result: Result<GraphQLResponse<Operation>, Error>,
                                                                          expectation: XCTestExpectation,
                                                                          file: StaticString = #file,
                                                                          line: UInt = #line) {
    defer {
      expectation.fulfill()
    }
    
    switch result {
    case .success(let graphQLResponse):
      guard
        let dictionary = graphQLResponse.body as? [String: AnyHashable],
        let dataDict = dictionary["data"] as? [String: AnyHashable],
        let heroDict = dataDict["hero"] as? [String: AnyHashable],
        let name = heroDict["name"] as? String else {
          XCTFail("No hero for you!",
                  file: file,
                  line: line)
          return
      }
      
      XCTAssertEqual(name,
                     "R2-D2",
                     file: file,
                     line: line)
    case .failure(let error):
      XCTFail("Unexpected response error: \(error)",
        file: file,
        line: line)
    }
  }
  
  func testPreflightDelegateTellingRequestNotToSend() {
    self.shouldSend = false
    
    let expectation = self.expectation(description: "Send operation completed")
    let cancellable = self.networkTransport.send(operation: HeroNameQuery(episode: .empire)) { result in
      
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success:
        XCTFail("Expected error not received when telling delegate not to send!")
      case .failure(let error):
        switch error {
        case GraphQLHTTPRequestError.cancelledByDelegate:
          // Correct!
          break
        default:
          XCTFail("Expected `cancelledByDelegate`, got \(error)")
        }
      }
    }
    
    guard (cancellable as? EmptyCancellable) != nil else {
      XCTFail("Wrong cancellable type returned!")
      cancellable.cancel()
      expectation.fulfill()
      return
    }
    
    // This should fail without hitting the network.
    self.wait(for: [expectation], timeout: 1)
    
    // The request shouldn't have fired, so all these objects should be nil
    XCTAssertNil(self.completedRequest)
    XCTAssertNil(self.completedData)
    XCTAssertNil(self.completedResponse)
    XCTAssertNil(self.completedError)
    XCTAssertEqual(self.retryCount, 0)
  }
  
  func testPreflightDelgateModifyingRequest() {
    self.updatedHeaders = ["Authorization": "Bearer HelloApollo"]

    let expectation = self.expectation(description: "Send operation completed")
    let cancellable = self.networkTransport.send(operation: HeroNameQuery()) { result in
      self.validateHeroNameQueryResponse(result: result, expectation: expectation)
    }
    
    guard
      let task = cancellable as? URLSessionTask,
      let headers = task.currentRequest?.allHTTPHeaderFields else {
        cancellable.cancel()
        expectation.fulfill()
        return
    }
    
    XCTAssertEqual(headers["Authorization"], "Bearer HelloApollo")
    
    // This will come through after hitting the network.
    self.wait(for: [expectation], timeout: 10)
    
    // We should have everything except an error since the request should have proceeded
    XCTAssertNotNil(self.completedRequest)
    XCTAssertNotNil(self.completedData)
    XCTAssertNotNil(self.completedResponse)
    XCTAssertNil(self.completedError)
    XCTAssertEqual(self.retryCount, 0)
  }
  
  func testPreflightDelegateNeitherModifyingOrStoppingRequest() {
    let expectation = self.expectation(description: "Send operation completed")
    let cancellable = self.networkTransport.send(operation: HeroNameQuery()) { result in
      self.validateHeroNameQueryResponse(result: result, expectation: expectation)
    }
    
    guard
      let task = cancellable as? URLSessionTask,
      let headers = task.currentRequest?.allHTTPHeaderFields else {
        XCTFail("Couldn't access header fields!")
        cancellable.cancel()
        expectation.fulfill()
        return
    }
    
    XCTAssertNil(headers["Authorization"])
    
    // This will come through after hitting the network.
    self.wait(for: [expectation], timeout: 10)
    
    // We should have everything except an error since the request should have proceeded
    XCTAssertNotNil(self.completedRequest)
    XCTAssertNotNil(self.completedData)
    XCTAssertNotNil(self.completedResponse)
    XCTAssertNil(self.completedError)
    XCTAssertEqual(self.retryCount, 0)
  }
  
  func testRetryDelegateRetriesAfterUnsuccessfulAttempts() {
    self.shouldModifyURLInWillSend = true
    let expectation = self.expectation(description: "Send operation completed")

    let cancellable = self.networkTransport.send(operation: HeroNameQuery()) { result in
      // This should have retried twice - the first time `shouldModifyURLInWillSend` shoud remain the same and it'll fail again.
      XCTAssertEqual(self.retryCount, 2)
      self.validateHeroNameQueryResponse(result: result, expectation: expectation)
    }
    
    guard
      let task = cancellable as? URLSessionTask,
      let url = task.currentRequest?.url else {
        XCTFail("Couldn't get url!")
        cancellable.cancel()
        expectation.fulfill()
        return
    }
    
    XCTAssertEqual(url, self.url)
    
    self.wait(for: [expectation], timeout: 10)
  }
}

// MARK: - HTTPNetworkTransportPreflightDelegate

extension HTTPTransportTests: HTTPNetworkTransportPreflightDelegate {
  func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool {
    return self.shouldSend
  }
  
  func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest) {
    if self.shouldModifyURLInWillSend {
      // This undoes any changes to the URL done by the GET request, which will cause the request to fail.
      request.url = self.url
    }
    
    guard let headers = self.updatedHeaders else {
      return
    }
    
    headers.forEach { tuple in
      let (key, value) = tuple
      var headers = request.allHTTPHeaderFields ?? [String: String]()
      headers[key] = value
      request.allHTTPHeaderFields = headers
    }
  }
}

// MARK: - HTTPNetworkTransportTaskCompletedDelegate

extension HTTPTransportTests: HTTPNetworkTransportTaskCompletedDelegate {
  
  func networkTransport(_ networkTransport: HTTPNetworkTransport,
                        didCompleteRawTaskForRequest request: URLRequest,
                        withData data: Data?,
                        response: URLResponse?,
                        error: Error?) {
    self.completedRequest = request
    self.completedData = data
    self.completedResponse = response
    self.completedError = error
  }
}

// MARK: - HTTPNetworkTransportRetryDelegate

extension HTTPTransportTests: HTTPNetworkTransportRetryDelegate {
  
  func networkTransport(_ networkTransport: HTTPNetworkTransport,
                        receivedError error: Error,
                        for request: URLRequest,
                        response: URLResponse?,
                        retryHandler: @escaping (Bool) -> Void) {
    guard let graphQLError = error as? GraphQLHTTPResponseError else {
      retryHandler(false)
      return
    }
    
    switch graphQLError.kind {
    case .errorResponse:
      self.retryCount += 1
      if retryCount > 1 {
        self.shouldModifyURLInWillSend = false
      }
      retryHandler(true)
    case .invalidResponse:
      retryHandler(false)
    }
  }
}

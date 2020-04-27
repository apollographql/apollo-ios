//
//  MockURLSession.swift
//  ApolloTestSupport
//
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation
import Apollo

public final class MockURLSessionClient: URLSessionClient {

  public private (set) var lastRequest: URLRequest?

  public var data: Data?
  public var response: HTTPURLResponse?
  public var error: Error?

  public override func sendRequest(_ request: URLRequest,
                                   rawTaskCompletionHandler: URLSessionClient.RawCompletion? = nil,
                                   completion: @escaping URLSessionClient.Completion) -> URLSessionTask {
    self.lastRequest = request
    rawTaskCompletionHandler?(self.data, self.response, self.error)
    
  
    let mockTask = URLSessionDataTaskMock()
    
    if let error = error {
      completion(.failure(error))
    } else {
      guard let data = self.data else {
        completion(.failure(URLSessionClientError.dataForRequestNotFound(request: request)))
        return mockTask
      }
      
      guard let response = self.response else {
        completion(.failure(URLSessionClientError.noHTTPResponse(request: request)))
        return mockTask
      }
      
      completion(.success((data, response)))
    }
    
    return mockTask
  }
}

private final class URLSessionDataTaskMock: URLSessionDataTask {
  override func resume() {

  }
}

//
//  RetryToCountThenSucceedInterceptor.swift
//  ApolloTests
//
//  Created by Ellen Shapiro on 8/19/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
import Apollo
import ApolloAPI

class RetryToCountThenSucceedInterceptor: ApolloInterceptor {
  let timesToCallRetry: Int
  var timesRetryHasBeenCalled = 0

  public var id: String = UUID().uuidString
  
  init(timesToCallRetry: Int) {
    self.timesToCallRetry = timesToCallRetry
  }
  
  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    if self.timesRetryHasBeenCalled < self.timesToCallRetry {
      self.timesRetryHasBeenCalled += 1
      chain.retry(request: request,
                  completion: completion)
    } else {
      chain.proceedAsync(
        request: request,
        response: response,
        interceptor: self,
        completion: completion
      )
    }
  }
}

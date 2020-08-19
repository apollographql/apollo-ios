//
//  RetryToCountThenSucceedInterceptor.swift
//  ApolloTests
//
//  Created by Ellen Shapiro on 8/19/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
import Apollo

class RetryToCountThenSucceedInterceptor: ApolloInterceptor {
  let timesToCallRetry: Int
  var timesRetryHasBeenCalled = 0
  
  init(timesToCallRetry: Int) {
    self.timesToCallRetry = timesToCallRetry
  }
  
  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    if request.retryCount < self.timesToCallRetry {
      self.timesRetryHasBeenCalled += 1
      chain.retry(request: request,
                  completion: completion)
    } else {
      chain.proceedAsync(request: request,
                         response: response,
                         completion: completion)
    }
  }
}

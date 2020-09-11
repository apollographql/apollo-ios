//
//  BlindRetryingTestInterceptor.swift
//  ApolloTests
//
//  Created by Ellen Shapiro on 8/19/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
import Apollo

// An interceptor which blindly retries every time it receives a request. 
class BlindRetryingTestInterceptor: ApolloInterceptor {
  var hitCount = 0
  
  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    self.hitCount += 1
    chain.retry(request: request,
                completion: completion)
  }
}

//
//  CancellationHandlingInterceptor.swift
//  ApolloTests
//
//  Created by Ellen Shapiro on 9/17/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
import Apollo
import ApolloAPI

class CancellationHandlingInterceptor: ApolloInterceptor, Cancellable {
  private(set) var hasBeenCancelled = false

  public var id: String = UUID().uuidString
  
  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    guard !self.hasBeenCancelled else {
      return
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      chain.proceedAsync(
        request: request,
        response: response,
        interceptor: self,
        completion: completion
      )
    }
  }
  
  func cancel() {
    self.hasBeenCancelled = true
  }
}

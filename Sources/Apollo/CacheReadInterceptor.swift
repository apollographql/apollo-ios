//
//  CacheReadInterceptor.swift
//  Apollo
//
//  Created by Ellen Shapiro on 7/14/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation

public class LegacyCacheReadInterceptor: ApolloInterceptor {
  
  public enum CacheReadError: Error {
    case cacheMiss(underlying: Error)
  }
  
  private let store: ApolloStore
  
  public init(store: ApolloStore) {
    self.store = store
  }
  
  public func interceptAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<ParsedValue>,
    completion: @escaping (Result<ParsedValue, Error>) -> Void) {
    
    switch request.cachePolicy {
    case .fetchIgnoringCacheCompletely,
         .fetchIgnoringCacheData:
      // Don't bother with the cache, just keep going
      chain.proceedAsync(request: request,
                         response: response,
                         completion: completion)
    case .returnCacheDataAndFetch:
      self.fetchFromCache(for: request) { cacheFetchResult in
        switch cacheFetchResult {
        case .failure(let error):
          // TODO: Does this need to return an error? What are we doing now
          completion(.failure(CacheReadError.cacheMiss(underlying: error)))
        case .success(let graphQLResult):
          completion(.success(graphQLResult as! ParsedValue))
        }
        
        // In either case, keep going asynchronously
        chain.proceedAsync(request: request,
                           response: response,
                           completion: completion)
      }
    case .returnCacheDataElseFetch:
      self.fetchFromCache(for: request) { cacheFetchResult in
        switch cacheFetchResult {
        case .failure:
          // Cache miss, proceed to network without calling completion
          chain.proceedAsync(request: request,
                             response: response,
                             completion: completion)
        case .success(let graphQLResult):
          // Cache hit! We're done.
          completion(.success(graphQLResult as! ParsedValue))
        }
      }
    case .returnCacheDataDontFetch:
      self.fetchFromCache(for: request) { cacheFetchResult in }
    }
  }
  
  private func fetchFromCache<Operation: GraphQLOperation>(for request: HTTPRequest<Operation>, completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    self.store.load(query: request.operation, resultHandler: <#T##(Result<GraphQLResult<GraphQLSelectionSet>, Error>) -> Void#>)
  }
  
}

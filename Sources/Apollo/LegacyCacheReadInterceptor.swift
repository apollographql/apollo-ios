import Foundation

/// An interceptor that reads data from the legacy cache for queries, following the `HTTPRequest`'s `cachePolicy`.
public class LegacyCacheReadInterceptor: ApolloInterceptor {
    
  public enum CacheReadError: Error {
    case cacheMiss(underlying: Error)
  }
  
  private let store: ApolloStore
  
  /// Designated initializer
  ///
  /// - Parameter store: The store to use when reading from the cache.
  public init(store: ApolloStore) {
    self.store = store
  }
  
  public func interceptAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<ParsedValue>,
    completion: @escaping (Result<ParsedValue, Error>) -> Void) {
    
    switch request.operation.operationType {
    case .mutation,
         .subscription:
      // Mutations and subscriptions don't need to hit the cache.
      chain.proceedAsync(request: request,
                         response: response,
                         completion: completion)
    case .query:
      switch request.cachePolicy {
      case .fetchIgnoringCacheCompletely,
           .fetchIgnoringCacheData:
        // Don't bother with the cache, just keep going
        chain.proceedAsync(request: request,
                           response: response,
                           completion: completion)
      case .returnCacheDataAndFetch:
        self.fetchFromCache(for: request, chain: chain) { cacheFetchResult in
          switch cacheFetchResult {
          case .failure(let error):
            // TODO: Does this need to return an error? What are we doing now
            chain.handleErrorAsync(CacheReadError.cacheMiss(underlying: error),
                                   request: request,
                                   response: response,
                                   completion: completion)
          case .success(let graphQLResult):
            completion(.success(graphQLResult as! ParsedValue))
          }
          
          // In either case, keep going asynchronously
          chain.proceedAsync(request: request,
                             response: response,
                             completion: completion)
        }
      case .returnCacheDataElseFetch:
        self.fetchFromCache(for: request, chain: chain) { cacheFetchResult in
          switch cacheFetchResult {
          case .failure:
            // Cache miss, proceed to network without returning error
            chain.proceedAsync(request: request,
                               response: response,
                               completion: completion)
          case .success(let graphQLResult):
            // Cache hit! We're done.
            completion(.success(graphQLResult as! ParsedValue))
          }
        }
      case .returnCacheDataDontFetch:
        self.fetchFromCache(for: request, chain: chain) { cacheFetchResult in
          switch cacheFetchResult {
          case .failure(let error):
            // Cache miss - don't hit the network, just return the error.
            chain.handleErrorAsync(error,
                                   request: request,
                                   response: response,
                                   completion: completion)
          case .success(let result):
            completion(.success(result as! ParsedValue))
          }
        }
      }
    }
  }
  
  private func fetchFromCache<Operation: GraphQLOperation>(
    for request: HTTPRequest<Operation>,
    chain: RequestChain,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    self.store.load(query: request.operation) { loadResult in
      guard chain.isNotCancelled else {
        return
      }
      
      completion(loadResult)
    }
  }
}

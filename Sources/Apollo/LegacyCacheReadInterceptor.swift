import Foundation

public class LegacyCacheReadInterceptor: ApolloInterceptor {
  
  public var isCancelled: Bool = false
  
  public enum CacheReadError: Error {
    case cacheMiss(underlying: Error)
    case notAQuery
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
    
    guard self.isNotCancelled else {
      return
    }
    
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
        self.fetchFromCache(for: request) { cacheFetchResult in
          switch cacheFetchResult {
          case .failure(let error):
            // Cache miss - don't hit the network, just return the error.
            completion(.failure(error))
          case .success(let result):
            completion(.success(result as! ParsedValue))
          }
        }
      }
    }
  }
  
  private func fetchFromCache<Operation: GraphQLOperation>(for request: HTTPRequest<Operation>, completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    self.store.load(query: request.operation) { loadResult in
      guard self.isNotCancelled else {
        return
      }
      
      completion(loadResult)
    }
  }
}

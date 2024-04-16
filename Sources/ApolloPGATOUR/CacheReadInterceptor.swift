import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// An interceptor that reads data from the cache for queries, following the `HTTPRequest`'s `cachePolicy`.
public struct CacheReadInterceptor: ApolloInterceptor {

  private let store: ApolloStore

  public var id: String = UUID().uuidString
  
  /// Designated initializer
  ///
  /// - Parameter store: The store to use when reading from the cache.
  public init(store: ApolloStore) {
    self.store = store
  }
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

      switch Operation.operationType {
      case .mutation,
          .subscription:
        // Mutations and subscriptions don't need to hit the cache.
        chain.proceedAsync(
          request: request,
          response: response,
          interceptor: self,
          completion: completion
        )

      case .query:
        switch request.cachePolicy {
        case .fetchIgnoringCacheCompletely,
            .fetchIgnoringCacheData:
          // Don't bother with the cache, just keep going
          chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
          )

        case .returnCacheDataAndFetch:
          self.fetchFromCache(for: request, chain: chain) { cacheFetchResult in
            switch cacheFetchResult {
            case .failure:
              // Don't return a cache miss error, just keep going
              break
            case .success(let graphQLResult):
              chain.returnValueAsync(
                for: request,
                value: graphQLResult,
                completion: completion
              )
            }

            // In either case, keep going asynchronously
            chain.proceedAsync(
              request: request,
              response: response,
              interceptor: self,
              completion: completion
            )
          }
        case .returnCacheDataElseFetch:
          self.fetchFromCache(for: request, chain: chain) { cacheFetchResult in
            switch cacheFetchResult {
            case .failure:
              // Cache miss, proceed to network without returning error
              chain.proceedAsync(
                request: request,
                response: response,
                interceptor: self,
                completion: completion
              )

            case .success(let graphQLResult):
              // Cache hit! We're done.
              chain.returnValueAsync(
                for: request,
                value: graphQLResult,
                completion: completion
              )
            }
          }
        case .returnCacheDataDontFetch:
          self.fetchFromCache(for: request, chain: chain) { cacheFetchResult in
            switch cacheFetchResult {
            case .failure(let error):
              // Cache miss - don't hit the network, just return the error.
              chain.handleErrorAsync(
                error,
                request: request,
                response: response,
                completion: completion
              )

            case .success(let result):
              chain.returnValueAsync(
                for: request,
                value: result,
                completion: completion
              )
            }
          }
        }
      }
    }
  
  private func fetchFromCache<Operation: GraphQLOperation>(
    for request: HTTPRequest<Operation>,
    chain: RequestChain,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

      self.store.load(request.operation) { loadResult in
        guard !chain.isCancelled else {
          return
        }

        completion(loadResult)
      }
    }
}

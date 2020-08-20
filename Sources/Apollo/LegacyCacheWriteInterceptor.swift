import Foundation

/// An interceptor which writes data to the legacy cache, following the `HTTPRequest`'s `cachePolicy`.
public class LegacyCacheWriteInterceptor: ApolloInterceptor {
  public enum LegacyCacheWriteError: Error {
    case noResponseToParse
  }
  
  public let store: ApolloStore
  
  /// Designated initializer
  ///
  /// - Parameter store: The store to use when writing to the cache.
  public init(store: ApolloStore) {
    self.store = store
  }
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    guard request.cachePolicy != .fetchIgnoringCacheCompletely else {
      // If we're ignoring the cache completely, we're not writing to it.
      chain.proceedAsync(request: request,
                         response: response,
                         completion: completion)
      return
    }
    
    guard
      let createdResponse = response,
      let legacyResponse = createdResponse.legacyResponse else {
        chain.handleErrorAsync(LegacyCacheWriteError.noResponseToParse,
                             request: request,
                             response: response,
                             completion: completion)
        return
    }

    firstly {
      try legacyResponse.parseResult(cacheKeyForObject: self.store.cacheKeyForObject)
    }.andThen { [weak self] (result, records) in
      guard let self = self else {
        return
      }
      guard chain.isNotCancelled else {
        return
      }
      
      if let records = records {
        self.store.publish(records: records)
          .catch { error in
            preconditionFailure(String(describing: error))
        }
      }
      
      chain.proceedAsync(request: request,
                         response: createdResponse,
                         completion: completion)
    }.catch { error in
      chain.handleErrorAsync(error,
                             request: request,
                             response: response,
                             completion: completion)
    }
  }
}

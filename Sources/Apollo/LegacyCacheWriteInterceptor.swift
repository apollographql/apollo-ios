import Foundation

/// An interceptor which writes data to the legacy cache, following the `HTTPRequest`'s `cachePolicy`.
public class LegacyCacheWriteInterceptor: ApolloInterceptor {
  
  public enum LegacyCacheWriteError: Error, LocalizedError {
    case noResponseToParse
    
    public var errorDescription: String? {
      switch self {
      case .noResponseToParse:
        return "The Legacy Cache Write Interceptor was called before a response was received to be parsed. Double-check the order of your interceptors."
      }
    }
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
    
    legacyResponse.parseResultWithCompletion(cacheKeyForObject: self.store.cacheKeyForObject) { [weak self] parseResult in
      switch parseResult {
      case .failure(let parseError):
        chain.handleErrorAsync(parseError,
                               request: request,
                               response: response,
                               completion: completion)
      case .success(let (_, recordSet)):
        guard let records = recordSet else {
          // Nothing to publish, move on.
          chain.proceedAsync(request: request,
                             response: response,
                             completion: completion)
          return
        }
        
        self?.store.publishWithCompletion(recordSet: records,
                                          identifier: request.contextIdentifier) { publishResult in
          switch publishResult {
          case .failure(let publishError):
            chain.handleErrorAsync(publishError,
                                   request: request,
                                   response: response,
                                   completion: completion)
          case .success:
            chain.proceedAsync(request: request,
                               response: createdResponse,
                               completion: completion)
          }
        }
      }
    }
  }
}

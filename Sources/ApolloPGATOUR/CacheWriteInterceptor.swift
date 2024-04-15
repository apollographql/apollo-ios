import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// An interceptor which writes data to the cache, following the `HTTPRequest`'s `cachePolicy`.
public struct CacheWriteInterceptor: ApolloInterceptor {
  
  public enum CacheWriteError: Error, LocalizedError {
    case noResponseToParse
    
    public var errorDescription: String? {
      switch self {
      case .noResponseToParse:
        return "The Cache Write Interceptor was called before a response was received to be parsed. Double-check the order of your interceptors."
      }
    }
  }
  
  public let store: ApolloStore
  public var id: String = UUID().uuidString
  
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
      chain.proceedAsync(
        request: request,
        response: response,
        interceptor: self,
        completion: completion
      )
      return
    }
    
    guard
      let createdResponse = response,
      let legacyResponse = createdResponse.legacyResponse else {
      chain.handleErrorAsync(
        CacheWriteError.noResponseToParse,
        request: request,
        response: response,
        completion: completion
      )
        return
    }
    
    do {
      let (_, records) = try legacyResponse.parseResult()
      
      guard !chain.isCancelled else {
        return
      }
      
      if let records = records {
        self.store.publish(records: records, identifier: request.contextIdentifier)
      }
      
      chain.proceedAsync(
        request: request,
        response: createdResponse,
        interceptor: self,
        completion: completion
      )

    } catch {
      chain.handleErrorAsync(
        error,
        request: request,
        response: response,
        completion: completion
      )
    }
  }
}

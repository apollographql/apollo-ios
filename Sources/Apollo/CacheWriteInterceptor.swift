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
    chain: any RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping GraphQLResultHandler<Operation.Data>
  ) {
    guard !chain.isCancelled else {
      return
    }

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

    guard let createdResponse = response else {
      chain.handleErrorAsync(
        CacheWriteError.noResponseToParse,
        request: request,
        response: response,
        completion: completion
      )
      return
    }

    if let cacheRecords = createdResponse.cacheRecords {
      self.store.publish(records: cacheRecords, identifier: request.contextIdentifier)
    }

    chain.proceedAsync(
      request: request,
      response: createdResponse,
      interceptor: self,
      completion: completion
    )
  }
}

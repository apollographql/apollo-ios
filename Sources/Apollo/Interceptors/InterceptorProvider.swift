#if !COCOAPODS
import ApolloAPI
#endif

// MARK: - Basic protocol

/// A protocol to allow easy creation of an array of interceptors for a given operation.
public protocol InterceptorProvider: Sendable {

  /// Creates a new array of interceptors when called
  ///
  /// - Parameter operation: The operation to provide interceptors for
  func graphQLInterceptors<Request: GraphQLRequest>(for request: Request) -> [any ApolloInterceptor]

  func cacheInterceptor<Request: GraphQLRequest>(for request: Request) -> any CacheInterceptor

  func httpInterceptors<Request: GraphQLRequest>(for request: Request) -> [any HTTPInterceptor]

  func responseParser<Request: GraphQLRequest>(for request: Request) -> any ResponseParsingInterceptor

  /// Provides an additional error interceptor for any additional handling of errors
  /// before returning to the UI, such as logging.
  /// - Parameter operation: The operation to provide an additional error interceptor for
  func errorInterceptor<Request: GraphQLRequest>(for request: Request) -> (any ApolloErrorInterceptor)?
}

// MARK: - Default Implementation

extension InterceptorProvider {

  /// The default interceptor provider.
  static var `default`: some InterceptorProvider {
    DefaultInterceptorProvider()
  }

  public func graphQLInterceptors<Request: GraphQLRequest>(for request: Request) -> [any ApolloInterceptor] {
    return [
      MaxRetryInterceptor(),
      AutomaticPersistedQueryInterceptor(),
    ]
  }

  public func httpInterceptors<Request: GraphQLRequest>(for request: Request) -> [any HTTPInterceptor] {
    return [
      ResponseCodeInterceptor()
    ]
  }

  public func cacheInterceptor<Request: GraphQLRequest>(for request: Request) -> any CacheInterceptor {
    DefaultCacheInterceptor()
  }

  public func responseParser<Request: GraphQLRequest>(for request: Request) -> any ResponseParsingInterceptor {
    JSONResponseParsingInterceptor()
  }

  public func errorInterceptor<Request: GraphQLRequest>(for request: Request) -> (any ApolloErrorInterceptor)? {
    return nil
  }
}

final class DefaultInterceptorProvider: InterceptorProvider {
  init() {}
}

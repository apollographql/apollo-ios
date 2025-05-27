#if !COCOAPODS
import ApolloAPI
#endif

// MARK: - Basic protocol

/// A protocol to allow easy creation of an array of interceptors for a given operation.
public protocol InterceptorProvider: Sendable {
  
  func urlSession<Operation: GraphQLOperation>(for operation: Operation) -> any ApolloURLSession

  /// Creates a new array of interceptors when called
  ///
  /// - Parameter operation: The operation to provide interceptors for
  func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any ApolloInterceptor]

  func cacheInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> any CacheInterceptor

  /// Provides an additional error interceptor for any additional handling of errors
  /// before returning to the UI, such as logging.
  /// - Parameter operation: The operation to provide an additional error interceptor for
  func errorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> (any ApolloErrorInterceptor)?
}

/// MARK: - Default Implementation

public extension InterceptorProvider {
  
  func errorInterceptor<Operation: GraphQLOperation>(
    for operation: Operation
  ) -> (any ApolloErrorInterceptor)? {
    return nil
  }
}

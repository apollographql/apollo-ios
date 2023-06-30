#if !COCOAPODS
import ApolloAPI
#endif

// MARK: - Basic protocol

/// A protocol to allow easy creation of an array of interceptors for a given operation.
public protocol InterceptorProvider {
  
  /// Creates a new array of interceptors when called
  ///
  /// - Parameter operation: The operation to provide interceptors for
  func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any ApolloInterceptor]
  
  /// Provides an additional error interceptor for any additional handling of errors
  /// before returning to the UI, such as logging.
  /// - Parameter operation: The operation to provide an additional error interceptor for
  func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor?
}

/// MARK: - Default Implementation

public extension InterceptorProvider {
  
  func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor? {
    return nil
  }
}

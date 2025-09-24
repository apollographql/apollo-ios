import ApolloAPI

// MARK: - Basic protocol

/// A protocol for a type that provides the interceptors required by a ``RequestChain`` for a given `GraphQLOperation`
///
/// - Note: Typically, new interceptors should be created each time the functions of the ``InterceptorProvider`` are
/// called. Interceptors commonly maintain state that is only relevant for the lifetime of a specific operation.
/// Re-using these interceptors can cause unintended behaviors.
public protocol InterceptorProvider: Sendable {

  /// Provides a new array of ``GraphQLInterceptor``s for the given operation.
  ///
  /// The default implementation provides a ``MaxRetryInterceptor`` and ``AutomaticPersistedQueryInterceptor``.
  ///
  /// - Parameter operation: The `GraphQLOperation` to provide GraphQL interceptors for
  /// - Returns: An array of ``GraphQLInterceptor``s
  func graphQLInterceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any GraphQLInterceptor]

  /// Provides a ``CacheInterceptor``s for the given operation.
  ///
  /// The default implementation provides a ``DefaultCacheInterceptor``.
  ///
  /// - Parameter operation: The `GraphQLOperation` to provide the cache interceptor for
  /// - Returns: A ``CacheInterceptor`
  func cacheInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> any CacheInterceptor

  /// Provides a new array of ``HTTPInterceptor``s for the given operation.
  ///
  /// The default implementation provides a ``ResponseCodeInterceptor``.
  ///
  /// - Parameter operation: The `GraphQLOperation` to provide HTTP interceptors for
  /// - Returns: An array of ``HTTPInterceptor``s
  func httpInterceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any HTTPInterceptor]

  /// Provides a ``ResponseParsingInterceptor``s for the given operation.
  ///
  /// The default implementation provides a ``JSONResponseParsingInterceptor``.
  ///
  /// - Parameter operation: The `GraphQLOperation` to provide the parsing interceptor for
  /// - Returns: A ``ResponseParsingInterceptor`
  func responseParser<Operation: GraphQLOperation>(for operation: Operation) -> any ResponseParsingInterceptor
}

/// A data structure containing all of the interceptors required by a ``RequestChain``.
///
/// This data structure is created by calling ``InterceptorProvider/interceptors(for:)`` on an ``InterceptorProvider``.
public struct Interceptors: Sendable {
  let graphQL: [any GraphQLInterceptor]
  let cache: any CacheInterceptor
  let http: [any HTTPInterceptor]
  let parser: any ResponseParsingInterceptor

  init(provider: some InterceptorProvider, operation: some GraphQLOperation) {
    self.graphQL = provider.graphQLInterceptors(for: operation)
    self.cache = provider.cacheInterceptor(for: operation)
    self.http = provider.httpInterceptors(for: operation)
    self.parser = provider.responseParser(for: operation)
  }
}

// MARK: - Default Implementation

extension InterceptorProvider {
  
  /// Creates all of the interceptors for a given `GraphQLOperation`
  /// - Parameter operation: The `GraphQLOperation` to provide the interceptors for
  /// - Returns: An `Interceptors` struct containing the interceptors for the operation.
  public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> Interceptors {
    Interceptors(provider: self, operation: operation)
  }

  public func graphQLInterceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any GraphQLInterceptor] {
    return [
      MaxRetryInterceptor(),
      AutomaticPersistedQueryInterceptor()
    ]
  }

  public func cacheInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> any CacheInterceptor {
    DefaultCacheInterceptor()
  }

  public func httpInterceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any HTTPInterceptor] {
    return [
      ResponseCodeInterceptor()
    ]
  }

  public func responseParser<Operation: GraphQLOperation>(for operation: Operation) -> any ResponseParsingInterceptor {
    JSONResponseParsingInterceptor()
  }  
}

/// The default interceptor provider. Provides default interceptors for executing a `GraphQLOperation` using a
/// ``RequestChain``.
public final class DefaultInterceptorProvider: InterceptorProvider {

  /// A shared ``DefaultInterceptorProvider`` for convenience.
  public static let shared = DefaultInterceptorProvider()
}

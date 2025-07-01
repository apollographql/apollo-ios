#if !COCOAPODS
import ApolloAPI
#endif

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

// MARK: - Basic protocol

/// A protocol to allow easy creation of an array of interceptors for a given operation.
public protocol InterceptorProvider: Sendable {

  /// Creates a new array of interceptors when called
  ///
  /// - Parameter operation: The operation to provide interceptors for
  func graphQLInterceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any GraphQLInterceptor]

  func cacheInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> any CacheInterceptor

  func httpInterceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any HTTPInterceptor]

  func responseParser<Operation: GraphQLOperation>(for operation: Operation) -> any ResponseParsingInterceptor
}

// MARK: - Default Implementation

extension InterceptorProvider {

  public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> Interceptors {
    .init(provider: self, operation: operation)
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

/// The default interceptor provider.
public final class DefaultInterceptorProvider: InterceptorProvider {
  public static let shared = DefaultInterceptorProvider()
}

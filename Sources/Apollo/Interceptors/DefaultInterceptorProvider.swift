import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// The default interceptor provider for typescript-generated code
public final class DefaultInterceptorProvider: InterceptorProvider {

  private let session: any ApolloURLSession
  private let store: ApolloStore
  private let shouldInvalidateClientOnDeinit: Bool

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - session: The `ApolloURLSession` to use. Defaults to a URLSession with a default configuration.
  ///   - shouldInvalidateSessionOnDeinit: If the passed-in session should be invalidated when this interceptor provider is deinitialized. If you are re-creating the `ApolloURLSession` every time you create a new provider, you should do this to prevent memory leaks. Defaults to true, since by default we provide a new `URLSession` to each new instance.
  ///   - store: The `ApolloStore` to use when reading from or writing to the cache. Make sure you pass the same store to the `ApolloClient` instance you're planning to use.
  public init(
    session: some ApolloURLSession = URLSession(configuration: .default),
    store: ApolloStore,
    shouldInvalidateSessionOnDeinit: Bool = true
  ) {
    self.session = session
    self.shouldInvalidateClientOnDeinit = shouldInvalidateSessionOnDeinit
    self.store = store
  }

  deinit {
    if self.shouldInvalidateClientOnDeinit {
      self.session.invalidateAndCancel()
    }
  }

  public func urlSession<Operation: GraphQLOperation>(
    for operation: Operation
  ) -> any ApolloURLSession {
    session
  }

  public func interceptors<Operation: GraphQLOperation>(
    for operation: Operation
  ) -> [any ApolloInterceptor] {
      return [
        MaxRetryInterceptor(),        
        AutomaticPersistedQueryInterceptor(),
        JSONResponseParsingInterceptor(),
        ResponseCodeInterceptor()
    ]
  }

  public func cacheInterceptor<Operation: GraphQLOperation>(
    for operation: Operation
  ) -> any CacheInterceptor {
    DefaultCacheInterceptor(store: self.store)
  }

  public func errorInterceptor<Operation: GraphQLOperation>(
    for operation: Operation
  ) -> (any ApolloErrorInterceptor)? {
    return nil
  }
}

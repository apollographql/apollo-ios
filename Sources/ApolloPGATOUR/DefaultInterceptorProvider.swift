#if !COCOAPODS
import ApolloAPI
#endif

/// The default interceptor provider for typescript-generated code
open class DefaultInterceptorProvider: InterceptorProvider {

  private let client: URLSessionClient
  private let store: ApolloStore
  private let shouldInvalidateClientOnDeinit: Bool

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - client: The `URLSessionClient` to use. Defaults to the default setup.
  ///   - shouldInvalidateClientOnDeinit: If the passed-in client should be invalidated when this interceptor provider is deinitialized. If you are recreating the `URLSessionClient` every time you create a new provider, you should do this to prevent memory leaks. Defaults to true, since by default we provide a `URLSessionClient` to new instances.
  ///   - store: The `ApolloStore` to use when reading from or writing to the cache. Make sure you pass the same store to the `ApolloClient` instance you're planning to use.
  public init(client: URLSessionClient = URLSessionClient(),
              shouldInvalidateClientOnDeinit: Bool = true,
              store: ApolloStore) {
    self.client = client
    self.shouldInvalidateClientOnDeinit = shouldInvalidateClientOnDeinit
    self.store = store
  }

  deinit {
    if self.shouldInvalidateClientOnDeinit {
      self.client.invalidate()
    }
  }

  open func interceptors<Operation: GraphQLOperation>(
    for operation: Operation
  ) -> [any ApolloInterceptor] {
      return [
        MaxRetryInterceptor(),
        CacheReadInterceptor(store: self.store),
        NetworkFetchInterceptor(client: self.client),
        ResponseCodeInterceptor(),
        MultipartResponseParsingInterceptor(),
        JSONResponseParsingInterceptor(),
        AutomaticPersistedQueryInterceptor(),
        CacheWriteInterceptor(store: self.store),
    ]
  }

  open func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor? {
    return nil
  }
}

import Foundation

// MARK: - Basic protocol

/// A protocol to allow easy creation of an array of interceptors for a given operation.
public protocol InterceptorProvider {
  
  /// Creates a new array of interceptors when called
  ///
  /// - Parameter operation: The operation to provide interceptors for
  func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor]
  
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

// MARK: - Default implementation for typescript codegen

/// The default interceptor provider for typescript-generated code
open class LegacyInterceptorProvider: InterceptorProvider {
  
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
  
  open func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
      return [
        MaxRetryInterceptor(),
        LegacyCacheReadInterceptor(store: self.store),
        NetworkFetchInterceptor(client: self.client),
        ResponseCodeInterceptor(),
        LegacyParsingInterceptor(cacheKeyForObject: self.store.cacheKeyForObject),
        AutomaticPersistedQueryInterceptor(),
        LegacyCacheWriteInterceptor(store: self.store),
    ]
  }
  
  open func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor? {
    return nil
  }
}

// MARK: - Default implementation for swift codegen


/// The default interceptor provider for code generated with Swift Codegen™
open class CodableInterceptorProvider<FlexDecoder: FlexibleDecoder>: InterceptorProvider {
  
  private let client: URLSessionClient
  private let shouldInvalidateClientOnDeinit: Bool
  private let decoder: FlexDecoder
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - client: The URLSessionClient to use. Defaults to the default setup.
  ///   - shouldInvalidateClientOnDeinit: If the passed-in client should be invalidated when this interceptor provider is deinitialized. If you are recreating the `URLSessionClient` every time you create a new provider, you should do this to prevent memory leaks. Defaults to true, since by default we provide a `URLSessionClient` to new instances.
  ///   - decoder: A `FlexibleDecoder` which can decode `Codable` objects.
  public init(client: URLSessionClient = URLSessionClient(),
              shouldInvalidateClientOnDeinit: Bool = true,
              decoder: FlexDecoder) {
    self.client = client
    self.shouldInvalidateClientOnDeinit = shouldInvalidateClientOnDeinit
    self.decoder = decoder
  }
  
  deinit {
    if self.shouldInvalidateClientOnDeinit {
      self.client.invalidate()
    }
  }

  open func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
       return [
         MaxRetryInterceptor(),
         // Swift Codegen Phase 2: Add Cache Read interceptor
         NetworkFetchInterceptor(client: self.client),
         ResponseCodeInterceptor(),
         AutomaticPersistedQueryInterceptor(),
         CodableParsingInterceptor(decoder: self.decoder),
         // Swift codegen Phase 2: Add Cache Write interceptor
     ]
   }
  
  open func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor? {
    return nil
  }
}

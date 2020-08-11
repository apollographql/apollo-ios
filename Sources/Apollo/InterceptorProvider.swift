import Foundation

// MARK: - Basic protocol

/// A protocol to allow easy creation of an array of interceptors for a given operation.
public protocol InterceptorProvider {
  
  /// Creates a new array of interceptors when called
  ///
  /// - Parameter operation: The operation to provide interceptors for
  func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor]
}

// MARK: - Default implementation for typescript codegen

/// The default interceptor provider for typescript-generated code
public class LegacyInterceptorProvider: InterceptorProvider {
  
  private let client: URLSessionClient
  private let store: ApolloStore
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - client: The `URLSessionClient` to use. Defaults to the default setup.
  ///   - store: The `ApolloStore` to use when reading from or writing to the cache.
  public init(client: URLSessionClient = URLSessionClient(),
              store: ApolloStore) {
    self.client = client
    self.store = store
  }

  public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
      return [
        LegacyCacheReadInterceptor(store: self.store),
        NetworkFetchInterceptor(client: self.client),
        ResponseCodeInterceptor(),
        AutomaticPersistedQueryInterceptor(),
        LegacyParsingInterceptor(),
        LegacyCacheWriteInterceptor(store: self.store),
        FinalizingInterceptor(),
    ]
  }
}

// MARK: - Default implementation for swift codegen


/// The default interceptor proider for code generated with Swift Codegen™
public class CodableInterceptorProvider<FlexDecoder: FlexibleDecoder>: InterceptorProvider {
  
  private let client: URLSessionClient
  private let store: ApolloStore
  
  private let decoder: FlexDecoder
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - client: The URLSessionClient to use. Defaults to the default setup.
  ///   - decoder: A `FlexibleDecoder` which can decode `Codable` objects.
  public init(client: URLSessionClient = URLSessionClient(),
              store: ApolloStore,
              decoder: FlexDecoder) {
    self.client = client
    self.store = store
    self.decoder = decoder
  }

  public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
       return [
         // Swift Codegen Phase 2: Add Cache Read interceptor
         NetworkFetchInterceptor(client: self.client),
         ResponseCodeInterceptor(),
         CodableParsingInterceptor(decoder: self.decoder),
         // Swift codegen Phase 2: Add Cache Write interceptor
         FinalizingInterceptor(),
     ]
   }
}

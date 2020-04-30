import Foundation

// MARK: - Basic protocol

public protocol InterceptorProvider {
  
  /// Creates a new array of interceptors when called
  ///
  /// - Parameter operation: The operation to provide interceptors for
  func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor]
}

// MARK: - Default implementation for typescript codegen

public class LegacyInterceptorProvider: InterceptorProvider {
  
  private let client: URLSessionClient
  
  /// Designated initializer
  ///
  /// - Parameter client: The URLSession client to use. Defaults to the default setup.
  public init(client: URLSessionClient = URLSessionClient()) {
    self.client = client
  }

  public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
      return [
        NetworkFetchInterceptor(client: self.client),
        ResponseCodeInterceptor(),
        ParsingInterceptor<JSONDecoder>(),
        FinalizingInterceptor(),
    ]
  }
}

// MARK: - Default implementation for swift codegen

public class CodableInterceptorProvider<FlexDecoder: FlexibleDecoder>: InterceptorProvider {
  
  private let client: URLSessionClient
  
  private let decoder: FlexDecoder
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - client: The URLSessionClient to use. Defaults to the default setup.
  ///   - decoder: A `FlexibleDecoder` which can decode `Codable` objects.
  public init(client: URLSessionClient = URLSessionClient(),
              decoder: FlexDecoder) {
    self.client = client
    self.decoder = decoder
  }

  public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
       return [
         NetworkFetchInterceptor(client: self.client),
         ResponseCodeInterceptor(),
         ParsingInterceptor(decoder: self.decoder),
         FinalizingInterceptor(),
     ]
   }
}

import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

/// An implementation of `NetworkTransport` which creates a `RequestChain` object
/// for each item sent through it.
public final class RequestChainNetworkTransport: NetworkTransport, Sendable {

  /// The interceptor provider to use when constructing a request chain
  let interceptorProvider: any InterceptorProvider

  /// The GraphQL endpoint URL to use.
  public let endpointURL: URL

  /// If a header should only be added to _certain_ requests, or if its value might differ between
  /// requests, you should add that header in an interceptor instead.
  ///
  /// Defaults to an empty dictionary.
  public let additionalHeaders: [String: String]

  /// A configuration struct used by a `GraphQLRequest` to configure the usage of
  /// [Automatic Persisted Queries (APQs).](https://www.apollographql.com/docs/apollo-server/performance/apq)
  /// By default, APQs are disabled.
  public let apqConfig: AutoPersistedQueryConfiguration

  /// Set to  `true` if you want to use `GET` instead of `POST` for queries.
  ///
  /// This can improve performance if your GraphQL server uses a CDN (Content Delivery Network)
  /// to cache the results of queries that rarely change.
  ///
  /// Mutation operations always use POST, even when this is `false`
  ///
  /// Defaults to `false`.
  public let useGETForQueries: Bool

  /// The `JSONRequestBodyCreator` object used to build your `URLRequest`'s JSON body.
  ///
  /// Defaults to a ``DefaultRequestBodyCreator`` initialized with the default configuration.
  public let requestBodyCreator: any JSONRequestBodyCreator

  /// Any additional HTTP headers that should be added to **every** request, such as an API key or a language setting.
  ////// The telemetry metadata about the client. This is used by GraphOS Studio's
  /// [client awareness](https://www.apollographql.com/docs/graphos/platform/insights/client-segmentation)
  /// feature.
  public let clientAwarenessMetadata: ClientAwarenessMetadata

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - interceptorProvider: The interceptor provider to use when constructing a request chain
  ///   - endpointURL: The GraphQL endpoint URL to use
  ///   - additionalHeaders: Any additional headers that should be automatically added to every request. Defaults to an empty dictionary.
  ///   - apqConfig: A configuration struct used by a `GraphQLRequest` to configure the usage of
  ///   [Automatic Persisted Queries (APQs).](https://www.apollographql.com/docs/apollo-server/performance/apq) By default, APQs
  ///   are disabled.
  ///   - requestBodyCreator: The `RequestBodyCreator` object to use to build your `URLRequest`. Defaults to the provided `ApolloRequestBodyCreator` implementation.
  ///   - useGETForQueries: Pass `true` if you want to use `GET` instead of `POST` for queries, for example to take advantage of a CDN. Defaults to `false`.
  ///   - sendEnhancedClientAwareness: Specifies whether client library metadata is sent in each request `extensions`
  ///   key. Client library metadata is the Apollo iOS library name and version. Defaults to `true`.
  public init(
    interceptorProvider: any InterceptorProvider,
    endpointURL: URL,
    additionalHeaders: [String: String] = [:],
    apqConfig: AutoPersistedQueryConfiguration = .init(),
    requestBodyCreator: any JSONRequestBodyCreator = DefaultRequestBodyCreator(),
    useGETForQueries: Bool = false,
    clientAwarenessMetadata: ClientAwarenessMetadata = ClientAwarenessMetadata()
  ) {
    self.interceptorProvider = interceptorProvider
    self.endpointURL = endpointURL

    self.additionalHeaders = additionalHeaders
    self.apqConfig = apqConfig
    self.requestBodyCreator = requestBodyCreator
    self.useGETForQueries = useGETForQueries
    self.clientAwarenessMetadata = clientAwarenessMetadata
  }

  /// Constructs a GraphQL request for the given operation.
  ///
  /// Override this method if you need to use a custom subclass of `HTTPRequest`.
  ///
  /// - Parameters:
  ///   - operation: The operation to create the request for
  ///   - cachePolicy: The `CachePolicy` to use when creating the request  
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  /// - Returns: The constructed request.
  public func constructRequest<Operation: GraphQLOperation>(
    for operation: Operation,
    cachePolicy: CachePolicy
  ) -> JSONRequest<Operation> {
    var request = JSONRequest(
      operation: operation,
      graphQLEndpoint: self.endpointURL,
      cachePolicy: cachePolicy,
      apqConfig: self.apqConfig,
      useGETForQueries: self.useGETForQueries,
      requestBodyCreator: self.requestBodyCreator,
      clientAwarenessMetadata: self.clientAwarenessMetadata
    )
    request.addHeaders(self.additionalHeaders)
    return request
  }

  // MARK: - NetworkTransport Conformance

  public func send<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy
  ) throws -> AsyncThrowingStream<GraphQLResult<Query.Data>, any Error> {
    let request = self.constructRequest(
      for: query,
      cachePolicy: cachePolicy,
    )

    let chain = makeChain(for: request)

    return chain.kickoff(request: request)
  }

  public func send<Mutation: GraphQLMutation>(
    mutation: Mutation,
    cachePolicy: CachePolicy
  ) throws -> AsyncThrowingStream<GraphQLResult<Mutation.Data>, any Error> {
    let request = self.constructRequest(
      for: mutation,
      cachePolicy: cachePolicy
    )

    let chain = makeChain(for: request)

    return chain.kickoff(request: request)
  }

  private func makeChain<Request: GraphQLRequest>(
    for request: Request
  ) -> RequestChain<Request> {
    let operation = request.operation
    let chain = RequestChain<Request>(
      urlSession: interceptorProvider.urlSession(for: operation),
      interceptors: interceptorProvider.interceptors(for: operation),
      cacheInterceptor: interceptorProvider.cacheInterceptor(for: operation),
      errorInterceptor: interceptorProvider.errorInterceptor(for: operation)
    )
    return chain
  }

}

extension RequestChainNetworkTransport: UploadingNetworkTransport {

  /// Constructs an uploading (ie, multipart) GraphQL request
  ///
  /// Override this method if you need to use a custom subclass of `HTTPRequest`.
  ///
  /// - Parameters:
  ///   - operation: The operation to create a request for
  ///   - files: The files you wish to upload
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  ///   - manualBoundary: [optional] A manually set boundary for your upload request. Defaults to nil.
  /// - Returns: The created request.
  public func constructUploadRequest<Operation: GraphQLOperation>(
    for operation: Operation,
    with files: [GraphQLFile]
    manualBoundary: String? = nil
  ) -> UploadRequest<Operation> {
    var request = UploadRequest(
      operation: operation,
      graphQLEndpoint: self.endpointURL,
      files: files,
      multipartBoundary: manualBoundary,
      requestBodyCreator: self.requestBodyCreator,
      clientAwarenessMetadata: self.clientAwarenessMetadata
    )
    request.addHeaders(self.additionalHeaders)
    return request
  }

  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile]
  ) throws -> AsyncThrowingStream<GraphQLResult<Operation.Data>, any Error> {
    let request = self.constructUploadRequest(for: operation, with: files)
    let chain = makeChain(for: request)
    return chain.kickoff(request: request)
  }

  // MARK: - Deprecations

  /// Set to `true` if Automatic Persisted Queries should be used to send a query hash instead of
  /// the full query body by default.
  @available(*, deprecated, message: "Use apqConfig.autoPersistQueries instead.")
  public var autoPersistQueries: Bool { apqConfig.autoPersistQueries }

  /// Set to `true` to use `GET` instead of `POST` for a retry of a persisted query.
  @available(*, deprecated, message: "Use apqConfig.useGETForPersistedQueryRetry instead.")
  public var useGETForPersistedQueryRetry: Bool { apqConfig.useGETForPersistedQueryRetry }
}

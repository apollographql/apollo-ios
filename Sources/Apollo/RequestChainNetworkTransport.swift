import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

/// An implementation of `NetworkTransport` which creates a `RequestChain` object
/// for each item sent through it.
public final class RequestChainNetworkTransport: NetworkTransport, Sendable {

  public let urlSession: any ApolloURLSession

  /// The interceptor provider to use when constructing a request chain
  public let interceptorProvider: any InterceptorProvider

  public let store: ApolloStore

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
    urlSession: any ApolloURLSession,
    interceptorProvider: any InterceptorProvider,
    store: ApolloStore,
    endpointURL: URL,
    additionalHeaders: [String: String] = [:],
    apqConfig: AutoPersistedQueryConfiguration = .init(),
    requestBodyCreator: any JSONRequestBodyCreator = DefaultRequestBodyCreator(),
    useGETForQueries: Bool = false
  ) {
    self.urlSession = urlSession
    self.interceptorProvider = interceptorProvider
    self.store = store
    self.endpointURL = endpointURL
    self.additionalHeaders = additionalHeaders
    self.apqConfig = apqConfig
    self.requestBodyCreator = requestBodyCreator
    self.useGETForQueries = useGETForQueries
  }

  /// Constructs a GraphQL request for the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to create the request for
  ///   - cachePolicy: The `CachePolicy` to use when creating the request
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  /// - Returns: The constructed request.
  public func constructRequest<Operation: GraphQLOperation>(
    for operation: Operation,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration
  ) -> JSONRequest<Operation> {
    var request = JSONRequest(
      operation: operation,
      graphQLEndpoint: self.endpointURL,
      fetchBehavior: fetchBehavior,
      writeResultsToCache: requestConfiguration.writeResultsToCache,
      requestTimeout: requestConfiguration.requestTimeout,
      apqConfig: self.apqConfig,
      useGETForQueries: self.useGETForQueries,
      requestBodyCreator: self.requestBodyCreator
    )
    request.addHeaders(self.additionalHeaders)
    return request
  }

  // MARK: - NetworkTransport Conformance

  public func send<Query: GraphQLQuery>(
    query: Query,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResponse<Query>, any Error> {
    let request = self.constructRequest(
      for: query,
      fetchBehavior: fetchBehavior,
      requestConfiguration: requestConfiguration
    )

    let chain = makeChain(for: request)

    return chain.kickoff(request: request)
  }

  public func send<Mutation: GraphQLMutation>(
    mutation: Mutation,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResponse<Mutation>, any Error> {
    let request = self.constructRequest(
      for: mutation,
      fetchBehavior: FetchBehavior.NetworkOnly,
      requestConfiguration: requestConfiguration
    )

    let chain = makeChain(for: request)
    return chain.kickoff(request: request)
  }

  private func makeChain<Request: GraphQLRequest>(
    for request: Request
  ) -> RequestChain<Request> {
    return RequestChain<Request>(
      urlSession: urlSession,
      interceptors: Interceptors(provider: interceptorProvider, operation: request.operation),
      store: store
    )
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
  ///   - requestConfiguration: A configuration used to configure per-request behaviors for this request
  /// - Returns: The created request.
  public func constructUploadRequest<Operation: GraphQLOperation>(
    for operation: Operation,
    files: [GraphQLFile],
    requestConfiguration: RequestConfiguration
  ) -> UploadRequest<Operation> {
    var request = UploadRequest(
      operation: operation,
      graphQLEndpoint: self.endpointURL,
      files: files,
      writeResultsToCache: requestConfiguration.writeResultsToCache,
      requestBodyCreator: self.requestBodyCreator
    )
    request.addHeaders(self.additionalHeaders)
    return request
  }

  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResponse<Operation>, any Error> {
    let request = self.constructUploadRequest(
      for: operation,
      files: files,
      requestConfiguration: requestConfiguration
    )
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

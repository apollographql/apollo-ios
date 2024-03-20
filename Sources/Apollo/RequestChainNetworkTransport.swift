import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// An implementation of `NetworkTransport` which creates a `RequestChain` object
/// for each item sent through it.
open class RequestChainNetworkTransport: NetworkTransport {

  /// The interceptor provider to use when constructing a request chain
  let interceptorProvider: InterceptorProvider
  
  /// The GraphQL endpoint URL to use.
  public let endpointURL: URL

  /// Any additional HTTP headers that should be added to **every** request, such as an API key or a language setting.
  ///
  /// If a header should only be added to _certain_ requests, or if its value might differ between requests,
  /// you should add that header in an interceptor instead.
  ///
  /// Defaults to an empty dictionary.
  public private(set) var additionalHeaders: [String: String]
  
  /// Set to `true` if Automatic Persisted Queries should be used to send a query hash instead of the full query body by default.
  public let autoPersistQueries: Bool
  
  /// Set to  `true` if you want to use `GET` instead of `POST` for queries.
  ///
  /// This can improve performance if your GraphQL server uses a CDN (Content Delivery Network)
  /// to cache the results of queries that rarely change.
  ///
  /// Mutation operations always use POST, even when this is `false`
  ///
  /// Defaults to `false`.
  public let useGETForQueries: Bool
  
  /// Set to `true` to use `GET` instead of `POST` for a retry of a persisted query.
  public let useGETForPersistedQueryRetry: Bool
  
  /// The `RequestBodyCreator` object used to build your `URLRequest`.
  ///
  /// Defaults to an ``ApolloRequestBodyCreator`` initialized with the default configuration.
  public var requestBodyCreator: RequestBodyCreator
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - interceptorProvider: The interceptor provider to use when constructing a request chain
  ///   - endpointURL: The GraphQL endpoint URL to use
  ///   - additionalHeaders: Any additional headers that should be automatically added to every request. Defaults to an empty dictionary.
  ///   - autoPersistQueries: Pass `true` if Automatic Persisted Queries should be used to send a query hash instead of the full query body by default. Defaults to `false`.
  ///   - requestBodyCreator: The `RequestBodyCreator` object to use to build your `URLRequest`. Defaults to the provided `ApolloRequestBodyCreator` implementation.
  ///   - useGETForQueries: Pass `true` if you want to use `GET` instead of `POST` for queries, for example to take advantage of a CDN. Defaults to `false`.
  ///   - useGETForPersistedQueryRetry: Pass `true` to use `GET` instead of `POST` for a retry of a persisted query. Defaults to `false`. 
  public init(interceptorProvider: InterceptorProvider,
              endpointURL: URL,
              additionalHeaders: [String: String] = [:],
              autoPersistQueries: Bool = false,
              requestBodyCreator: RequestBodyCreator = ApolloRequestBodyCreator(),
              useGETForQueries: Bool = false,
              useGETForPersistedQueryRetry: Bool = false) {
    self.interceptorProvider = interceptorProvider
    self.endpointURL = endpointURL

    self.additionalHeaders = additionalHeaders
    self.autoPersistQueries = autoPersistQueries
    self.requestBodyCreator = requestBodyCreator
    self.useGETForQueries = useGETForQueries
    self.useGETForPersistedQueryRetry = useGETForPersistedQueryRetry
  }
  
  /// Constructs a GraphQL request for the given operation.
  ///
  /// Override this method if you need to use a custom subclass of `HTTPRequest`.
  ///
  /// - Parameters:
  ///   - operation: The operation to create the request for
  ///   - cachePolicy: The `CachePolicy` to use when creating the request
  ///   - contextIdentifier: [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Should default to `nil`.
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  /// - Returns: The constructed request.
  open func constructRequest<Operation: GraphQLOperation>(
    for operation: Operation,
    cachePolicy: CachePolicy,
    contextIdentifier: UUID? = nil,
    context: RequestContext? = nil
  ) -> HTTPRequest<Operation> {
    let request = JSONRequest(
      operation: operation,
      graphQLEndpoint: self.endpointURL,
      contextIdentifier: contextIdentifier,
      clientName: self.clientName,
      clientVersion: self.clientVersion,
      additionalHeaders: self.additionalHeaders,
      cachePolicy: cachePolicy,
      context: context,
      autoPersistQueries: self.autoPersistQueries,
      useGETForQueries: self.useGETForQueries,
      useGETForPersistedQueryRetry: self.useGETForPersistedQueryRetry,
      requestBodyCreator: self.requestBodyCreator
    )

    if Operation.operationType == .subscription {
      request.addHeader(
        name: "Accept",
        value: "multipart/mixed;\(MultipartResponseSubscriptionParser.protocolSpec),application/json"
      )

    } else {
      request.addHeader(
        name: "Accept",
        value: "multipart/mixed;\(MultipartResponseDeferParser.protocolSpec),application/json"
      )
    }

    return request
  }
  
  // MARK: - NetworkTransport Conformance
  
  public var clientName = RequestChainNetworkTransport.defaultClientName
  public var clientVersion = RequestChainNetworkTransport.defaultClientVersion
  
  public func send<Operation: GraphQLOperation>(
    operation: Operation,
    cachePolicy: CachePolicy = .default,
    contextIdentifier: UUID? = nil,
    context: RequestContext? = nil,
    callbackQueue: DispatchQueue = .main,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable {
    
    let chain = makeChain(operation: operation, callbackQueue: callbackQueue)
    let request = self.constructRequest(
      for: operation,
      cachePolicy: cachePolicy,
      contextIdentifier: contextIdentifier,
      context: context)
    
    chain.kickoff(request: request, completion: completionHandler)
    return chain
  }

  private func makeChain<Operation: GraphQLOperation>(
    operation: Operation,
    callbackQueue: DispatchQueue = .main
  ) -> RequestChain {
    let interceptors = self.interceptorProvider.interceptors(for: operation)
    let chain = InterceptorRequestChain(interceptors: interceptors, callbackQueue: callbackQueue)
    chain.additionalErrorHandler = self.interceptorProvider.additionalErrorInterceptor(for: operation)
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
    with files: [GraphQLFile],
    context: RequestContext? = nil,
    manualBoundary: String? = nil) -> HTTPRequest<Operation> {
    
    UploadRequest(graphQLEndpoint: self.endpointURL,
                  operation: operation,
                  clientName: self.clientName,
                  clientVersion: self.clientVersion,
                  additionalHeaders: self.additionalHeaders,
                  files: files,
                  manualBoundary: manualBoundary,
                  context: context,
                  requestBodyCreator: self.requestBodyCreator)
  }
  
  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    context: RequestContext?,
    callbackQueue: DispatchQueue = .main,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable {
    
    let request = self.constructUploadRequest(for: operation, with: files, context: context)
    let chain = makeChain(operation: operation, callbackQueue: callbackQueue)
    chain.kickoff(request: request, completion: completionHandler)
    return chain
  }
}

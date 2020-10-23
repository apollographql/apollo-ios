import Foundation

/// An implementation of `NetworkTransport` which creates a `RequestChain` object
/// for each item sent through it.
open class RequestChainNetworkTransport: NetworkTransport {
  
  let interceptorProvider: InterceptorProvider
  
  /// The GraphQL endpoint URL to use.
  public let endpointURL: URL
  
  /// Any additional headers that should be automatically added to every request.
  public private(set) var additionalHeaders: [String: String]
  
  /// Set to `true` if Automatic Persisted Queries should be used to send a query hash instead of the full query body by default.
  public let autoPersistQueries: Bool
  
  /// Set to  `true` if you want to use `GET` instead of `POST` for queries, for example to take advantage of a CDN.
  public let useGETForQueries: Bool
  
  /// Set to `true` to use `GET` instead of `POST` for a retry of a persisted query.
  public let useGETForPersistedQueryRetry: Bool
  
  /// The `RequestBodyCreator` object to use to build your `URLRequest`.
  public var requestBodyCreator: RequestBodyCreator
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - interceptorProvider: The interceptor provider to use when constructing chains for a request
  ///   - endpointURL: The GraphQL endpoint URL to use.
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
  
  /// Constructs a default (ie, non-multipart) GraphQL request.
  ///
  /// Override this method if you need to use a custom subclass of `HTTPRequest`.
  ///
  /// - Parameters:
  ///   - operation: The operation to create the request for
  ///   - cachePolicy: The `CachePolicy` to use when creating the request
  ///   - contextIdentifier: [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Should default to `nil`.
  /// - Returns: The constructed request.
  open func constructRequest<Operation: GraphQLOperation>(
    for operation: Operation,
    cachePolicy: CachePolicy,
    contextIdentifier: UUID? = nil) -> HTTPRequest<Operation> {
    JSONRequest(operation: operation,
                graphQLEndpoint: self.endpointURL,
                contextIdentifier: contextIdentifier,
                clientName: self.clientName,
                clientVersion: self.clientVersion,
                additionalHeaders: additionalHeaders,
                cachePolicy: cachePolicy,
                autoPersistQueries: self.autoPersistQueries,
                useGETForQueries: self.useGETForQueries,
                useGETForPersistedQueryRetry: self.useGETForPersistedQueryRetry,
                requestBodyCreator: self.requestBodyCreator)
  }
  
  // MARK: - NetworkTransport Conformance
  
  public var clientName = RequestChainNetworkTransport.defaultClientName
  public var clientVersion = RequestChainNetworkTransport.defaultClientVersion
  
  public func send<Operation: GraphQLOperation>(
    operation: Operation,
    cachePolicy: CachePolicy = .default,
    contextIdentifier: UUID? = nil,
    callbackQueue: DispatchQueue = .main,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable {
    
    let interceptors = self.interceptorProvider.interceptors(for: operation)
    let chain = RequestChain(interceptors: interceptors, callbackQueue: callbackQueue)
    chain.additionalErrorHandler = self.interceptorProvider.additionalErrorInterceptor(for: operation)
    let request = self.constructRequest(for: operation,
                                        cachePolicy: cachePolicy,
                                        contextIdentifier: contextIdentifier)
    
    chain.kickoff(request: request, completion: completionHandler)
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
  /// - Returns: The created request.
  open func constructUploadRequest<Operation: GraphQLOperation>(
    for operation: Operation,
    with files: [GraphQLFile]) -> HTTPRequest<Operation> {
    
    UploadRequest(graphQLEndpoint: self.endpointURL,
                  operation: operation,
                  clientName: self.clientName,
                  clientVersion: self.clientVersion,
                  files: files,
                  requestBodyCreator: self.requestBodyCreator)
  }
  
  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    callbackQueue: DispatchQueue = .main,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable {
    
    let request = self.constructUploadRequest(for: operation, with: files)
    let interceptors = self.interceptorProvider.interceptors(for: operation)
    let chain = RequestChain(interceptors: interceptors, callbackQueue: callbackQueue)
    
    chain.kickoff(request: request, completion: completionHandler)
    return chain
  }
}

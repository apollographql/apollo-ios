import Foundation

/// An implementation of `NetworkTransport` which creates a `RequestChain` object
/// for each item sent through it.
public class RequestChainNetworkTransport: NetworkTransport {
  
  let interceptorProvider: InterceptorProvider
  let endpointURL: URL
  
  var additionalHeaders: [String: String]
  let autoPersistQueries: Bool
  let useGETForQueries: Bool
  let useGETForPersistedQueryRetry: Bool
  
  var requestCreator: RequestCreator
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - interceptorProvider: The interceptor provider to use when constructing chains for a request
  ///   - endpointURL: The GraphQL endpoint URL to use.
  ///   - additionalHeaders: Any additional headers that should be automatically added to every request. Defaults to an empty dictionary.
  ///   - autoPersistQueries: Pass `true` if Automatic Persisted Queries should be used to send a query hash instead of the full query body by default. Defaults to `false`.
  ///   - requestCreator: The `RequestCreator` object to use to build your `URLRequest`. Defaults to the providedd `ApolloRequestCreator` implementation.
  ///   - useGETForQueries: Pass `true` if you want to use `GET` instead of `POST` for queries, for example to take advantage of a CDN. Defaults to `false`.
  ///   - useGETForPersistedQueryRetry: Pass `true` to use `GET` instead of `POST` for a retry of a persisted query. Defaults to `false`. 
  public init(interceptorProvider: InterceptorProvider,
              endpointURL: URL,
              additionalHeaders: [String: String] = [:],
              autoPersistQueries: Bool = false,
              requestCreator: RequestCreator = ApolloRequestCreator(),
              useGETForQueries: Bool = false,
              useGETForPersistedQueryRetry: Bool = false) {
    self.interceptorProvider = interceptorProvider
    self.endpointURL = endpointURL

    self.additionalHeaders = additionalHeaders
    self.autoPersistQueries = autoPersistQueries
    self.requestCreator = requestCreator
    self.useGETForQueries = useGETForQueries
    self.useGETForPersistedQueryRetry = useGETForPersistedQueryRetry
  }
  
  private func constructJSONRequest<Operation: GraphQLOperation>(
    for operation: Operation,
    cachePolicy: CachePolicy,
    contextIdentifier: UUID?) -> JSONRequest<Operation> {
    
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
                requestCreator: self.requestCreator)
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
    let request = self.constructJSONRequest(for: operation,
                                            cachePolicy: cachePolicy,
                                            contextIdentifier: contextIdentifier)
    
    chain.kickoff(request: request, completion: completionHandler)
    return chain
  }
}

extension RequestChainNetworkTransport: UploadingNetworkTransport {
  
  private func createUploadRequest<Operation: GraphQLOperation>(
    for operation: Operation,
    with files: [GraphQLFile]) -> UploadRequest<Operation> {
    
    UploadRequest(graphQLEndpoint: self.endpointURL,
                  operation: operation,
                  clientName: self.clientName,
                  clientVersion: self.clientVersion,
                  files: files,
                  requestCreator: self.requestCreator)
  }
  
  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    callbackQueue: DispatchQueue = .main,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable {
    
    let request = self.createUploadRequest(for: operation, with: files)
    let interceptors = self.interceptorProvider.interceptors(for: operation)
    let chain = RequestChain(interceptors: interceptors, callbackQueue: callbackQueue)
    
    chain.kickoff(request: request, completion: completionHandler)
    return chain
  }
}

import Foundation

public class RequestChainNetworkTransport: NetworkTransport {
  
  let interceptorProvider: InterceptorProvider
  let endpointURL: URL
  
  var additionalHeaders: [String: String]
  var cachePolicy: CachePolicy
  let autoPersistQueries: Bool
  let useGETForQueries: Bool
  let useGETForPersistedQueryRetry: Bool
  
  var requestCreator: RequestCreator
  
  public var clientName = RequestChainNetworkTransport.defaultClientName
  public var clientVersion = RequestChainNetworkTransport.defaultClientVersion
  
  public init(interceptorProvider: InterceptorProvider,
              endpointURL: URL,
              additionalHeaders: [String: String] = [:],
              autoPersistQueries: Bool = false,
              cachePolicy: CachePolicy = .default,
              requestCreator: RequestCreator = ApolloRequestCreator(),
              useGETForQueries: Bool = false,
              useGETForPersistedQueryRetry: Bool = false) {
    self.interceptorProvider = interceptorProvider
    self.endpointURL = endpointURL

    self.additionalHeaders = additionalHeaders
    self.autoPersistQueries = autoPersistQueries
    self.cachePolicy = cachePolicy
    self.requestCreator = requestCreator
    self.useGETForQueries = useGETForQueries
    self.useGETForPersistedQueryRetry = useGETForPersistedQueryRetry
  }
  
  private func constructJSONRequest<Operation: GraphQLOperation>(for operation: Operation) -> JSONRequest<Operation> {
    JSONRequest(operation: operation,
                graphQLEndpoint: self.endpointURL,
                additionalHeaders: additionalHeaders,
                cachePolicy: self.cachePolicy,
                autoPersistQueries: self.autoPersistQueries,
                useGETForQueries: self.useGETForQueries,
                useGETForPersistedQueryRetry: self.useGETForPersistedQueryRetry,
                requestCreator: self.requestCreator)
  }
  
  public func send<Operation: GraphQLOperation>(operation: Operation,
                                                completionHandler: @escaping (Result<GraphQLResponse<Operation.Data>, Error>) -> Void) -> Cancellable {
    fatalError("Unsupported ye olde method")
  }
  
  public func sendForResult<Operation: GraphQLOperation>(
    operation: Operation,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable {
    
    let chain = RequestChain(interceptors: interceptorProvider.interceptors(for: operation))
        
    let request = self.constructJSONRequest(for: operation)
    
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
                  files: files,
                  requestCreator: self.requestCreator)
  }
  
  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    completionHandler: @escaping (Result<GraphQLResponse<Operation.Data>, Error>) -> Void) -> Cancellable {
    
    fatalError("Unsupported ye olde method")
  }
  
  public func uploadForResult<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable {
    
    let request = self.createUploadRequest(for: operation, with: files)
    
    let chain = RequestChain(interceptors: interceptorProvider.interceptors(for: operation))
    
    chain.kickoff(request: request, completion: completionHandler)
    return chain
  }
}

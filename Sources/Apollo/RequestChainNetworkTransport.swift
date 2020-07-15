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
  
  public func send<Operation: GraphQLOperation>(operation: Operation,
                                                completionHandler: @escaping (Result<GraphQLResponse<Operation.Data>, Error>) -> Void) -> Cancellable {
    let chain = RequestChain(interceptors: interceptorProvider.interceptors(for: operation))
        
    let request: JSONRequest<Operation> = JSONRequest(operation: operation,
                                                      graphQLEndpoint: self.endpointURL,
                                                      additionalHeaders: additionalHeaders,
                                                      cachePolicy: self.cachePolicy,
                                                      autoPersistQueries: self.autoPersistQueries,
                                                      useGETForQueries: self.useGETForQueries,
                                                      useGETForPersistedQueryRetry: self.useGETForPersistedQueryRetry,
                                                      requestCreator: self.requestCreator)
    
    chain.kickoff(request: request, completion: completionHandler)
    return chain
  }
  
  public func sendForResult<Operation>(operation: Operation, completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable where Operation : GraphQLOperation {
    let chain = RequestChain(interceptors: interceptorProvider.interceptors(for: operation))
        
    let request: JSONRequest<Operation> = JSONRequest(operation: operation,
                                                      graphQLEndpoint: self.endpointURL,
                                                      additionalHeaders: additionalHeaders,
                                                      cachePolicy: self.cachePolicy,
                                                      autoPersistQueries: self.autoPersistQueries,
                                                      useGETForQueries: self.useGETForQueries,
                                                      useGETForPersistedQueryRetry: self.useGETForPersistedQueryRetry,
                                                      requestCreator: self.requestCreator)
    
    chain.kickoff(request: request, completion: completionHandler)
    return chain
  }
}

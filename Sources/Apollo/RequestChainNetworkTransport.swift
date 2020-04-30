import Foundation

class RequestChainNetworkTransport: NetworkTransport {
  
  let interceptorProvider: InterceptorProvider
  let endpointURL: URL
  
  init(interceptorProvider: InterceptorProvider = LegacyInterceptorProvider(),
       endpointURL: URL) {
    self.interceptorProvider = interceptorProvider
    self.endpointURL = endpointURL
  }
  
  func send<Operation: GraphQLOperation>(operation: Operation,
                                         completionHandler: @escaping (Result<GraphQLResponse<Operation.Data>, Error>) -> Void) -> Cancellable {
    let chain = RequestChain(interceptors: interceptorProvider.interceptors(for: operation))
    let request: JSONRequest<Operation> = JSONRequest(operation: operation, graphQLEndpoint: self.endpointURL)
    
    chain.kickoff(request: request, completion: completionHandler)
    return chain
  }
}

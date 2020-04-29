import Foundation

class RequestChainNetworkTransport: NetworkTransport {
  
  let client: URLSessionClient
  let endpointURL: URL
  let decoder: JSONDecoder
  
  init(client: URLSessionClient = URLSessionClient(),
       decoder: JSONDecoder = JSONDecoder(),
       endpointURL: URL) {
    self.client = client
    self.decoder = decoder
    self.endpointURL = endpointURL
  }
  
  func generateChain<Operation: GraphQLOperation>(for operation: Operation) -> RequestChain<Operation.Data, Operation> {
    let interceptors: [ApolloInterceptor] = [
      NetworkFetchInterceptor(client: self.client),
      ResponseCodeInterceptor(),
      ParsingInterceptor(decoder: self.decoder),
      FinalizingInterceptor(),
    ]
    
    return RequestChain(interceptors: interceptors)
  }
  
  func send<Operation: GraphQLOperation>(operation: Operation,
                                         completionHandler: @escaping (Result<GraphQLResponse<Operation.Data>, Error>) -> Void) -> Cancellable {
    let chain: RequestChain<Operation.Data, Operation> = self.generateChain(for: operation)
    let request: JSONRequest<Operation> = JSONRequest(operation: operation, graphQLEndpoint: self.endpointURL)
    
    chain.kickoff(request: request, completion: completionHandler)
    return chain
  }
  
  
  
}

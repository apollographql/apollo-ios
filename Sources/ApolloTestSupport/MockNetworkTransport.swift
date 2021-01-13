import Foundation
@testable import Apollo

public final class MockNetworkTransport: RequestChainNetworkTransport {
  public init(server: MockGraphQLServer, store: ApolloStore) {
    super.init(interceptorProvider: TestInterceptorProvider(store: store, server: server),
               endpointURL: TestURL.mockServer.url)
  }
  
  struct TestInterceptorProvider: InterceptorProvider {
    let store: ApolloStore
    let server: MockGraphQLServer
    
    func interceptors<Operation>(for operation: Operation) -> [ApolloInterceptor] where Operation: GraphQLOperation {
      return [
        MaxRetryInterceptor(),
        LegacyCacheReadInterceptor(store: self.store),
        MockGraphQLServerInterceptor(server: server),
        ResponseCodeInterceptor(),
        LegacyParsingInterceptor(cacheKeyForObject: self.store.cacheKeyForObject),
        AutomaticPersistedQueryInterceptor(),
        LegacyCacheWriteInterceptor(store: self.store),
      ]
    }
  }
}

private final class MockTask: Cancellable {
  func cancel() {
    // no-op
  }
}

private class MockGraphQLServerInterceptor: ApolloInterceptor {
  let server: MockGraphQLServer
  
  init(server: MockGraphQLServer) {
    self.server = server
  }
  
  public func interceptAsync<Operation>(chain: RequestChain, request: HTTPRequest<Operation>, response: HTTPResponse<Operation>?, completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) where Operation: GraphQLOperation {
    server.serve(request: request) { result in
      let httpResponse = HTTPURLResponse(url: TestURL.mockServer.url,
                                         statusCode: 200,
                                         httpVersion: nil,
                                         headerFields: nil)!
      
      switch result {
      case .failure(let error):
        chain.handleErrorAsync(error,
                               request: request,
                               response: response,
                               completion: completion)
      case .success(let body):
        let data = try! JSONSerializationFormat.serialize(value: body)
        let response = HTTPResponse<Operation>(response: httpResponse,
                                               rawData: data,
                                               parsedResponse: nil)
        chain.proceedAsync(request: request,
                           response: response,
                           completion: completion)
      }
    }
  }
}

import Foundation
@testable import Apollo
@testable import ApolloAPI

public final class MockNetworkTransport: RequestChainNetworkTransport {
  public init(
    server: MockGraphQLServer = MockGraphQLServer(),
    store: ApolloStore,
    clientName: String = "MockNetworkTransport_ClientName",
    clientVersion: String = "MockNetworkTransport_ClientVersion"
  ) {
    super.init(interceptorProvider: TestInterceptorProvider(store: store, server: server),
               endpointURL: TestURL.mockServer.url)
    self.clientName = clientName
    self.clientVersion = clientVersion
  }  
  
  struct TestInterceptorProvider: InterceptorProvider {
    let store: ApolloStore
    let server: MockGraphQLServer
    
    func interceptors<Operation>(
      for operation: Operation
    ) -> [any ApolloInterceptor] where Operation: GraphQLOperation {
      return [
        MaxRetryInterceptor(),
        CacheReadInterceptor(store: self.store),
        MockGraphQLServerInterceptor(server: server),
        ResponseCodeInterceptor(),
        JSONResponseParsingInterceptor(),
        AutomaticPersistedQueryInterceptor(),
        CacheWriteInterceptor(store: self.store),
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

  public var id: String = UUID().uuidString
  
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
                           interceptor: self,
                           completion: completion)
      }
    }
  }
}

public class MockWebSocketTransport: NetworkTransport {
  public var clientName, clientVersion: String

  public init(clientName: String, clientVersion: String) {
    self.clientName = clientName
    self.clientVersion = clientVersion
  }

  public func send<Operation>(
    operation: Operation,
    cachePolicy: CachePolicy,
    contextIdentifier: UUID?,
    callbackQueue: DispatchQueue,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) -> Cancellable where Operation : GraphQLOperation {
    return MockTask()
  }
}

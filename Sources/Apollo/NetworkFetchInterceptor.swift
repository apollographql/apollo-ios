import Foundation

/// An interceptor which actually fetches data from the network.
public class NetworkFetchInterceptor: ApolloInterceptor, Cancellable {
  let client: URLSessionClient
  private var currentTask: URLSessionTask?
  
  /// Designated initializer.
  ///
  /// - Parameter client: The `URLSessionClient` to use to fetch data
  public init(client: URLSessionClient) {
    self.client = client
  }
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    let urlRequest: URLRequest
    do {
      urlRequest = try request.toURLRequest()
    } catch {
      chain.handleErrorAsync(error,
                             request: request,
                             response: response,
                             completion: completion)
      return
    }
    
    self.currentTask = self.client.sendRequest(urlRequest) { result in
      defer {
        self.currentTask = nil
      }
      
      guard chain.isNotCancelled else {
        return
      }
      
      switch result {
      case .failure(let error):
        chain.handleErrorAsync(error,
                               request: request,
                               response: response,
                               completion: completion)
      case .success(let (data, httpResponse)):
        let response = HTTPResponse<Operation>(response: httpResponse,
                                               rawData: data,
                                               parsedResponse: nil)
        chain.proceedAsync(request: request,
                           response: response,
                           completion: completion)
      }
    }
  }
  
  public func cancel() {
    self.currentTask?.cancel()
  }
}

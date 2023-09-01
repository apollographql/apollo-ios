import Apollo

/// Use this interceptor tester to isolate a single `ApolloInterceptor` vs. having to create an
/// `InterceptorRequestChain` and end the interceptor list with `JSONResponseParsingInterceptor`
/// to get a parsed `GraphQLResult` for the standard request chain callback.
public class InterceptorTester {
  let interceptor: any ApolloInterceptor

  public init(interceptor: any ApolloInterceptor) {
    self.interceptor = interceptor
  }

  public func intercept<Operation>(
    request: Apollo.HTTPRequest<Operation>,
    response: Apollo.HTTPResponse<Operation>? = nil,
    completion: @escaping (Result<Data?, Error>) -> Void
  ) {
    let requestChain = ResponseCaptureRequestChain({ result in
      completion(result)
    })

    self.interceptor.interceptAsync(
      chain: requestChain,
      request: request,
      response: response) { _ in }
  }
}

fileprivate class ResponseCaptureRequestChain: RequestChain {
  var isCancelled: Bool = false
  let completion: (Result<Data?, Error>) -> Void

  init(_ completion: @escaping (Result<Data?, Error>) -> Void) {
    self.completion = completion
  }

  func kickoff<Operation>(
    request: Apollo.HTTPRequest<Operation>,
    completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
  ) {}

  func proceedAsync<Operation>(
    request: Apollo.HTTPRequest<Operation>,
    response: Apollo.HTTPResponse<Operation>?,
    completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    self.completion(.success(response?.rawData))
  }

  func proceedAsync<Operation>(
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    interceptor: any ApolloInterceptor,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    self.completion(.success(response?.rawData))
  }

  func cancel() {}

  func retry<Operation>(
    request: Apollo.HTTPRequest<Operation>,
    completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
  ) {}

  func handleErrorAsync<Operation>(
    _ error: Error,
    request: Apollo.HTTPRequest<Operation>,
    response: Apollo.HTTPResponse<Operation>?,
    completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    self.completion(.failure(error))
  }

  func returnValueAsync<Operation>(
    for request: Apollo.HTTPRequest<Operation>,
    value: Apollo.GraphQLResult<Operation.Data>,
    completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
  ) {}
}

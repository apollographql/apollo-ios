import Apollo

/// Use this mock response chain when you want to isolate a single `ApolloInterceptor` vs. having
/// to end your interceptor chain with `JSONResponseParsingInterceptor` to get a parsed `Result`
/// for the standard callback.
public class ResponseCaptureRequestChain: RequestChain {
  public var isCancelled: Bool = false
  public var error: Error? = nil
  public var data: Data? = nil

  public init() {}

  public func kickoff<Operation>(
    request: Apollo.HTTPRequest<Operation>,
    completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
  ) {}

  public func proceedAsync<Operation>(
    request: Apollo.HTTPRequest<Operation>,
    response: Apollo.HTTPResponse<Operation>?,
    completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    self.data = response?.rawData
  }

  public func cancel() {}

  public func retry<Operation>(
    request: Apollo.HTTPRequest<Operation>,
    completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
  ) {}

  public func handleErrorAsync<Operation>(
    _ error: Error,
    request: Apollo.HTTPRequest<Operation>,
    response: Apollo.HTTPResponse<Operation>?,
    completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    self.error = error
    self.data = response?.rawData
  }

  public func returnValueAsync<Operation>(
    for request: Apollo.HTTPRequest<Operation>,
    value: Apollo.GraphQLResult<Operation.Data>,
    completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
  ) {}
}

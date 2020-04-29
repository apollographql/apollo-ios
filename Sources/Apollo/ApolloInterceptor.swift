public protocol ApolloInterceptor: class {
  
  var isCancelled: Bool { get set }
  
  func interceptAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
    chain: RequestChain<ParsedValue, Operation>,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<ParsedValue>,
    completion: @escaping (Result<ParsedValue, Error>) -> Void)
}

import Foundation

public protocol ApolloErrorInterceptor {
  
  /// Asynchronously handles the receipt of an error at any point in the chain.
  ///
  /// - Parameters:
  ///   - error: The received error
  ///   - chain: The chain the error was received on
  ///   - request: The request, as far as it was constructed
  ///   - response: The response, as far as it was constructed
  ///   - completion: The completion closure to fire when the operation has completed. Note that if you call `retry` on the chain, you will not want to call the completion block in this method.
  func handleErrorAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
      error: Error,
      chain: RequestChain,
      request: HTTPRequest<Operation>,
      response: HTTPResponse<ParsedValue>,
      completion: @escaping (Result<ParsedValue, Error>) -> Void)
}

import Foundation

/// An error interceptor called to allow further examination of error data when an error occurs in the chain.
public protocol ApolloErrorInterceptor {
  
  /// Asynchronously handles the receipt of an error at any point in the chain.
  ///
  /// - Parameters:
  ///   - error: The received error
  ///   - chain: The chain the error was received on
  ///   - request: The request, as far as it was constructed
  ///   - response: [optional] The response, if one was received
  ///   - completion: The completion closure to fire when the operation has completed. Note that if you call `retry` on the chain, you will not want to call the completion block in this method.
  func handleErrorAsync<Operation: GraphQLOperation>(
      error: Error,
      chain: RequestChain,
      request: HTTPRequest<Operation>,
      response: HTTPResponse<Operation>?,
      completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void)
}

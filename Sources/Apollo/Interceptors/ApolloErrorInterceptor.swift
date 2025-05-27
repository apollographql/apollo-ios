#if !COCOAPODS
import ApolloAPI
#endif

/// An error interceptor called to allow further examination of error data when an error occurs in the chain.
#warning("TODO: Kill this, or implement it's usage in Request Chain.")
public protocol ApolloErrorInterceptor: Sendable {

  /// Asynchronously handles the receipt of an error at any point in the chain.
  ///
  /// - Parameters:
  ///   - error: The received error
  ///   - chain: The chain the error was received on
  ///   - request: The request, as far as it was constructed
  ///   - response: [optional] The response, if one was received
  ///   - completion: The completion closure to fire when the operation has completed. Note that if you call `retry` on the chain, you will not want to call the completion block in this method.
  func intercept<Request: GraphQLRequest>(
    error: any Swift.Error,
    request: Request,
    result: InterceptorResult<Request.Operation>?
  ) async throws -> GraphQLResult<Request.Operation.Data>

}

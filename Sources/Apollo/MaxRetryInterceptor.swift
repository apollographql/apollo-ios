import Foundation

/// An interceptor to enforce a maximum number of retries of any `HTTPRequest`
public class MaxRetryInterceptor: ApolloInterceptor {
  
  private let maxRetries: Int
  
  public enum RetryError: Error {
    case hitMaxRetryCount(count: Int, operationName: String)
  }
  
  /// Designated initializer.
  ///
  /// - Parameter maxRetriesAllowed: How many times a query can be retried, in addition to the initial attempt before
  public init(maxRetriesAllowed: Int = 3) {
    self.maxRetries = maxRetriesAllowed
  }
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    guard request.retryCount <= self.maxRetries else {
      let error = RetryError.hitMaxRetryCount(count: self.maxRetries,
                                              operationName: request.operation.operationName)
      chain.handleErrorAsync(error,
                             request: request,
                             response: response,
                             completion: completion)
      return
    }
    
    chain.proceedAsync(request: request,
                       response: response,
                       completion: completion)
  }
}

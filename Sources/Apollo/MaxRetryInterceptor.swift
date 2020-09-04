import Foundation

/// An interceptor to enforce a maximum number of retries of any `HTTPRequest`
public class MaxRetryInterceptor: ApolloInterceptor {
  
  private let maxRetries: Int
  private var hitCount = 0
  
  public enum RetryError: Error, LocalizedError {
    case hitMaxRetryCount(count: Int, operationName: String)
    
    public var errorDescription: String? {
      switch self {
      case .hitMaxRetryCount(let count, let operationName):
        return "The maximum number of retries (\(count)) was hit without success for operation \"\(operationName)\"."
      }
    }
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
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    guard self.hitCount <= self.maxRetries else {
      let error = RetryError.hitMaxRetryCount(count: self.maxRetries,
                                              operationName: request.operation.operationName)
      chain.handleErrorAsync(error,
                             request: request,
                             response: response,
                             completion: completion)
      return
    }
    
    self.hitCount += 1
    chain.proceedAsync(request: request,
                       response: response,
                       completion: completion)
  }
}

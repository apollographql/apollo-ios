import Foundation
import ApolloAPI

/// An interceptor to enforce a maximum number of retries of any `HTTPRequest`
public actor MaxRetryInterceptor: GraphQLInterceptor, Sendable {

  private let maxRetries: Int
  private var hitCount = 0
  
  public struct MaxRetriesError: Error, LocalizedError {
    public let count: Int
    public let operationName: String

    public var errorDescription: String? {
      return "The maximum number of retries (\(count)) was hit without success for operation \"\(operationName)\"."
    }
  }
  
  /// Designated initializer.
  ///
  /// - Parameter maxRetriesAllowed: How many times a query can be retried, in addition to the initial attempt before
  public init(maxRetriesAllowed: Int = 3) {
    self.maxRetries = maxRetriesAllowed
  }

  public func intercept<Request: GraphQLRequest>(
    request: Request,
    next: NextInterceptorFunction<Request>
  ) async throws -> InterceptorResultStream<Request> {
    guard self.hitCount <= self.maxRetries else {
      throw MaxRetriesError(
        count: self.maxRetries,
        operationName: Request.Operation.operationName
      )
    }

    self.hitCount += 1
    return await next(request)
  }
}

import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

public struct AutomaticPersistedQueryInterceptor: ApolloInterceptor {

  public enum APQError: LocalizedError, Equatable {
    case noParsedResponse
    case persistedQueryNotFoundForPersistedOnlyQuery(operationName: String)
    case persistedQueryRetryFailed(operationName: String)

    public var errorDescription: String? {
      switch self {
      case .noParsedResponse:
        return "The Automatic Persisted Query Interceptor was called before a response was received. Double-check the order of your interceptors."
      case .persistedQueryRetryFailed(let operationName):
        return "Persisted query retry failed for operation \"\(operationName)\"."

      case .persistedQueryNotFoundForPersistedOnlyQuery(let operationName):
        return "The Persisted Query for operation \"\(operationName)\" was not found. The operation is a `.persistedOnly` operation and cannot be automatically persisted if it is not recognized by the server."

      }
    }
  }

  /// Designated initializer
  public init() {}

  actor IsInitialResult {
    var value = true

    func get() -> Bool {
      defer { value = false }
      return value
    }
  }

  public func intercept<Request: GraphQLRequest>(
    request: Request,
    next: NextInterceptorFunction<Request>
  ) async throws -> InterceptorResultStream<Request.Operation> {
    guard let jsonRequest = request as? JSONRequest<Request.Operation>,
          jsonRequest.apqConfig.autoPersistQueries else {
      // Not a request that handles APQs, continue along
      return try await next(request)
    }

    let isInitialResult = IsInitialResult()

    return try await next(request).map { result in

      guard await isInitialResult.get() else {
        return result
      }

      guard let parsedResult = result.parsedResult else {
        throw APQError.noParsedResponse
      }

      guard let errors = parsedResult.result.errors else {
        // No errors were returned so no retry is necessary, continue along.
        return result
      }

      let errorMessages = errors.compactMap { $0.message }
      guard errorMessages.contains("PersistedQueryNotFound") else {
        // The errors were not APQ errors, continue along.
        return result
      }

      guard !jsonRequest.isPersistedQueryRetry else {
        // We already retried this and it didn't work.
        throw APQError.persistedQueryRetryFailed(operationName: Request.Operation.operationName)
      }

      if Request.Operation.operationDocument.definition == nil {
        throw APQError.persistedQueryNotFoundForPersistedOnlyQuery(
          operationName: Request.Operation.operationName
        )
      }

      var jsonRequest = jsonRequest
      // We need to retry this query with the full body.
      jsonRequest.isPersistedQueryRetry = true
      throw RequestChainRetry(request: jsonRequest)
    }
  }
}

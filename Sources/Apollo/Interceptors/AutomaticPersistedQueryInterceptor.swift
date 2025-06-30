import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

public struct AutomaticPersistedQueryInterceptor: ApolloInterceptor {

  public enum APQError: LocalizedError, Equatable {
    case persistedQueryNotFoundForPersistedOnlyQuery(operationName: String)
    case persistedQueryRetryFailed(operationName: String)

    public var errorDescription: String? {
      switch self {      
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
  ) async throws -> InterceptorResultStream<Request> {
    guard let jsonRequest = request as? JSONRequest<Request.Operation>,
          jsonRequest.apqConfig.autoPersistQueries else {
      // Not a request that handles APQs, continue along
      return await next(request)
    }

    let isInitialResult = IsInitialResult()

    return await next(request).map { response in
#warning("TODO: Test if cache returns result, then server returns failed result, APQ retry still occurs")
      guard response.result.source == .server,
            await isInitialResult.get() else {
        return response
      }

      guard let errors = response.result.errors else {
        // No errors were returned so no retry is necessary, continue along.
        return response
      }

      let errorMessages = errors.compactMap { $0.message }
      guard errorMessages.contains("PersistedQueryNotFound") else {
        // The errors were not APQ errors, continue along.
        return response
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
      jsonRequest.fetchBehavior = FetchBehavior.NetworkOnly

      throw RequestChain.Retry(request: jsonRequest)
    }
  }
}

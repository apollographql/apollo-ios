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

  public var id: String = UUID().uuidString
  
  /// Designated initializer
  public init() {}
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

      guard let jsonRequest = request as? JSONRequest,
            jsonRequest.autoPersistQueries else {
        // Not a request that handles APQs, continue along
        chain.proceedAsync(
          request: request,
          response: response,
          interceptor: self,
          completion: completion
        )
        return
      }

      guard let result = response?.parsedResponse else {
        // This is in the wrong order - this needs to be parsed before we can check it.
        chain.handleErrorAsync(
          APQError.noParsedResponse,
          request: request,
          response: response,
          completion: completion
        )
        return
      }

      guard let errors = result.errors else {
        // No errors were returned so no retry is necessary, continue along.
        chain.proceedAsync(
          request: request,
          response: response,
          interceptor: self,
          completion: completion
        )
        return
      }

      let errorMessages = errors.compactMap { $0.message }
      guard errorMessages.contains("PersistedQueryNotFound") else {
        // The errors were not APQ errors, continue along.
        chain.proceedAsync(
          request: request,
          response: response,
          interceptor: self,
          completion: completion
        )
        return
      }

      guard !jsonRequest.isPersistedQueryRetry else {
        // We already retried this and it didn't work.
        chain.handleErrorAsync(
          APQError.persistedQueryRetryFailed(operationName: Operation.operationName),
          request: jsonRequest,
          response: response,
          completion: completion
        )

        return
      }

      if case .persistedOperationsOnly = Operation.document {
        chain.handleErrorAsync(
          APQError.persistedQueryNotFoundForPersistedOnlyQuery(operationName: Operation.operationName),
          request: jsonRequest,
          response: response,
          completion: completion
        )

        return
      }

      // We need to retry this query with the full body.
      jsonRequest.isPersistedQueryRetry = true
      chain.retry(request: jsonRequest, completion: completion)
    }
}

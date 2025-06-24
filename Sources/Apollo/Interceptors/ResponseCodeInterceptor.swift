import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// An interceptor to check the response code returned with a request.
public struct ResponseCodeInterceptor: HTTPInterceptor {

  public var id: String = UUID().uuidString

  public struct ResponseCodeError: Error, LocalizedError {
    public let response: HTTPURLResponse
    public let responseChunk: Data

    public var errorDescription: String? {
      return "Received a \(response.statusCode) error."
    }

    public var graphQLError: GraphQLError? {
      if let jsonValue = try? (JSONSerialization.jsonObject(
          with: responseChunk,
          options: .allowFragments) as! JSONValue),
         let jsonObject = try? JSONObject(_jsonValue: jsonValue)
      {
        return GraphQLError(jsonObject)
      }
      return nil
    }
  }
  
  /// Designated initializer
  public init() {}
  
  public func intercept<Request: GraphQLRequest>(
    request: Request,
    next: NextHTTPInterceptorFunction<Request>
  ) async throws -> InterceptorResultStream<HTTPResponse> {
    return try await next(request).map { result in

      guard result.response.isSuccessful == true else {
        throw ResponseCodeError(
          response: result.response,
          responseChunk: result.rawResponseChunk
        )
      }
      return result
    }
  }
}

import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// An interceptor to check the response code returned with a request.
public struct ResponseCodeInterceptor: HTTPInterceptor {

  public var id: String = UUID().uuidString

  public struct ResponseCodeError: Error, LocalizedError {
    public let response: HTTPURLResponse
    public let chunk: Data

    public var errorDescription: String? {
      return "Received a \(response.statusCode) error."
    }

    public var graphQLError: GraphQLError? {
      if let jsonValue = try? (JSONSerialization.jsonObject(
          with: chunk,
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
  
  public func intercept(
    request: URLRequest,
    context: (any RequestContext)?,
    next: NextHTTPInterceptorFunction
  ) async throws -> HTTPResponse {
    return try await next(request).mapChunks { (response, chunk) in
      guard response.isSuccessful == true else {
        throw ResponseCodeError(
          response: response,
          chunk: chunk
        )
      }
      return chunk
    }
  }
}

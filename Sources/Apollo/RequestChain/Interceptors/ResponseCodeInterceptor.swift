import Foundation
@_spi(Internal) import ApolloAPI

/// An ``HTTPInterceptor`` that checks the response code returned with a request. If the response code indicates a
/// failure, it throws an error, failing early and preventing unnecessary additional work.
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

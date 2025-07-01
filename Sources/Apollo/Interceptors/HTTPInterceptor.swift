import Foundation

public protocol HTTPInterceptor: Sendable {

  typealias NextHTTPInterceptorFunction = @Sendable (URLRequest) async throws -> HTTPResponse

  func intercept(
    request: URLRequest,
    next: NextHTTPInterceptorFunction
  ) async throws -> HTTPResponse

}

public struct HTTPResponse: Sendable, ~Copyable {
  public let response: HTTPURLResponse

  public let chunks: NonCopyableAsyncThrowingStream<Data>

  public consuming func mapChunks(
    _ transform: @escaping @Sendable (HTTPURLResponse, Data) async throws -> (Data)
  ) async -> HTTPResponse {
    let response = self.response
    let stream = await chunks.map { chunk in
      return try await transform(response, chunk)
    }
    return HTTPResponse(response: response, chunks: stream)
  }
}

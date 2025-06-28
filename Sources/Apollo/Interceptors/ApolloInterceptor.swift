import Combine
import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

public typealias InterceptorResultStream<Request: GraphQLRequest> =
NonCopyableAsyncThrowingStream<GraphQLResponse<Request.Operation>>

public protocol ResponseParsingInterceptor: Sendable {
  func parse<Request: GraphQLRequest>(
    response: consuming HTTPResponse,
    for request: Request,
    includeCacheRecords: Bool
  ) async throws -> InterceptorResultStream<GraphQLResponse<Request.Operation>>
}

public struct GraphQLResponse<Operation: GraphQLOperation>: Sendable, Hashable {
  public let result: GraphQLResult<Operation.Data>
  public let cacheRecords: RecordSet?

  public init(result: GraphQLResult<Operation.Data>, cacheRecords: RecordSet?) {
    self.result = result
    self.cacheRecords = cacheRecords
  }
}

/// A protocol to set up a chainable unit of networking work.
public protocol ApolloInterceptor: Sendable {

  typealias NextInterceptorFunction<Request: GraphQLRequest> = @Sendable (Request) async throws ->
    InterceptorResultStream<Request>

  /// Called when this interceptor should do its work.
  ///
  /// - Parameters:
  ///   - chain: The chain the interceptor is a part of.
  ///   - request: The request, as far as it has been constructed
  ///   - response: [optional] The response, if received
  ///   - completion: The completion block to fire when data needs to be returned to the UI.
  func intercept<Request: GraphQLRequest>(
    request: Request,
    next: NextInterceptorFunction<Request>
  ) async throws -> InterceptorResultStream<Request>

}

public struct HTTPResponse: Sendable, ~Copyable {
  public let response: HTTPURLResponse

  public let chunks: NonCopyableAsyncThrowingStream<Data>

  public consuming func mapChunks(
    _ transform: @escaping @Sendable (HTTPURLResponse, Data) async throws -> (Data)
  ) async throws -> HTTPResponse {
    let response = self.response
    let stream = try await chunks.map { chunk in
      return try await transform(response, chunk)
    }
    return HTTPResponse(response: response, chunks: stream)
  }
}

public protocol HTTPInterceptor: Sendable {

  typealias NextHTTPInterceptorFunction = @Sendable (URLRequest) async throws -> HTTPResponse

  func intercept(
    request: URLRequest,
    next: NextHTTPInterceptorFunction
  ) async throws -> HTTPResponse

}

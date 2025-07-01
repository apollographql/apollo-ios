/// An interceptor that handles the parsing of response data for a ``GraphQLRequest``.
public protocol ResponseParsingInterceptor: Sendable {
  func parse<Request: GraphQLRequest>(
    response: consuming HTTPResponse,
    for request: Request,
    includeCacheRecords: Bool
  ) async throws -> InterceptorResultStream<Request>
}

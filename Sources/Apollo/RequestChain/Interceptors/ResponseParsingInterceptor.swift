/// A protocol for an interceptor in a ``RequestChain`` that handles the parsing of response data for a
/// ``GraphQLRequest``.
public protocol ResponseParsingInterceptor: Sendable {

  /// The function called by the ``RequestChain`` to execute parsing of response data for a ``GraphQLRequest``.
  /// - Parameters:
  ///   - response: The ``HTTPResponse`` to be parsed
  ///   - request: The ``GraphQLRequest`` used to fetch the data of the `response`
  ///   - includeCacheRecords: Indicates if parsing should include cache records for the parsed `response` to be
  ///   written to an ``ApolloStore``. If this is `true`, the ``ParsedResult``s emitted by the returned stream should
  ///   have their ``ParsedResult/cacheRecords`` field set.
  /// - Returns: A stream of ``ParsedResult`` for each of the ``HTTPResponse/chunks`` of the ``HTTPResponse``
  func parse<Request: GraphQLRequest>(
    response: consuming HTTPResponse,
    for request: Request,
    includeCacheRecords: Bool
  ) async throws -> InterceptorResultStream<Request>
}

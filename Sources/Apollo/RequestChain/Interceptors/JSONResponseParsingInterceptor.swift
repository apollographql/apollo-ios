import Foundation
@_spi(Unsafe) import ApolloAPI

/// A ``ResponseParsingInterceptor`` which uses a ``JSONResponseParser`` to parse JSON response data.
public actor JSONResponseParsingInterceptor: ResponseParsingInterceptor {

  public init() {}

  private actor ResultStorage<Request: GraphQLRequest> {
    var currentResult: ParsedResult<Request.Operation>?

    func setResult(_ result: ParsedResult<Request.Operation>) {
      currentResult = result
    }
  }

  public func parse<Request: GraphQLRequest>(
    response: consuming HTTPResponse,
    for request: Request,
    includeCacheRecords: Bool
  ) async throws -> InterceptorResultStream<Request> {
    let parser = JSONResponseParser(
      response: response.response,
      operationVariables: request.operation.__variables,
      includeCacheRecords: includeCacheRecords
    )

    let storage = ResultStorage<Request>()

    return await response.chunks.compactMap { chunk in
      try Task.checkCancellation()

      if let parsedResponse = try await parser.parse(
          dataChunk: chunk,
          mergingIncrementalItemsInto: await storage.currentResult
      ) {
        await storage.setResult(parsedResponse)
        return parsedResponse
      }

      return nil
    }
  }
}

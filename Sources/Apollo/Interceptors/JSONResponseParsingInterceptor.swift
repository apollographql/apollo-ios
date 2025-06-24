import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

/// An interceptor which parses JSON response data into a `GraphQLResult` and attaches it to the `HTTPResponse`.
public struct JSONResponseParsingInterceptor: ResponseParsingInterceptor {

  public init() {}

  public func parse<Request: GraphQLRequest>(
    response: HTTPURLResponse,
    dataChunkStream: any AsyncChunkSequence,
    for request: Request,
    includeCacheRecords: Bool
  ) async throws -> InterceptorResultStream<GraphQLResponse<Request.Operation>> {

    let parser = JSONResponseParser(
      response: response,
      operationVariables: request.operation.__variables,
      includeCacheRecords: includeCacheRecords
    )

    let stream = AsyncThrowingStream<GraphQLResponse<Request.Operation>, any Error> { continuation in
      let task = Task<(), Never> {
        do {
          defer { continuation.finish() }
          var currentResult: GraphQLResponse<Request.Operation>?

          for try await chunk in dataChunkStream {
            try Task.checkCancellation()

            guard
              let parsedResponse = try await parser.parse(
                dataChunk: chunk as! Data,
                mergingIncrementalItemsInto: currentResult
              )
            else {
              continue
            }

            currentResult = parsedResponse
            continuation.yield(parsedResponse)
          }


        } catch {
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { _ in task.cancel() }
    }
    return InterceptorResultStream<GraphQLResponse<Request.Operation>>(stream: stream)
  }
}

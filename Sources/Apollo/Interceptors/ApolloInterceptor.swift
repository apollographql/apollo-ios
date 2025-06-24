import Foundation
import Combine
#if !COCOAPODS
import ApolloAPI
#endif

public protocol ResponseParsingInterceptor: Sendable {
  func parse<Request: GraphQLRequest>(
    response: HTTPURLResponse,
    dataChunkStream: any AsyncChunkSequence,
    for request: Request,
    includeCacheRecords: Bool
  ) async throws -> InterceptorResultStream<GraphQLResponse<Request.Operation>>
}

public struct GraphQLResponse<Operation: GraphQLOperation>: Sendable, Equatable {
    public let result: GraphQLResult<Operation.Data>
    public let cacheRecords: RecordSet?
}

/// A protocol to set up a chainable unit of networking work.
public protocol ApolloInterceptor: Sendable {

  typealias NextInterceptorFunction<Request: GraphQLRequest> = @Sendable (Request) async throws -> InterceptorResultStream<GraphQLResponse<Request.Operation>>

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
  ) async throws -> InterceptorResultStream<GraphQLResponse<Request.Operation>>

}

public struct HTTPResponse: Sendable {
  public let response: HTTPURLResponse

  /// This is the data for a single chunk of the response body.
  ///
  /// If this is not a multipart response, this will include the data for the entire response body.
  ///
  /// If this is a multipart response, the response chunk will only be one chunk.
  /// The `InterceptorResultStream` will return multiple results – one for each multipart chunk.
  public let rawResponseChunk: Data
}

public protocol HTTPInterceptor: Sendable {

  typealias NextHTTPInterceptorFunction<Request: GraphQLRequest> = @Sendable (Request) async throws -> InterceptorResultStream<HTTPResponse>

  func intercept<Request: GraphQLRequest>(
    request: Request,
    next: NextHTTPInterceptorFunction<Request>
  ) async throws -> InterceptorResultStream<HTTPResponse>

}

public struct InterceptorResultStream<T: Sendable>: Sendable, ~Copyable {

  private let stream: AsyncThrowingStream<T, any Error>

  init(stream: AsyncThrowingStream<T, any Error>) {
    self.stream = stream
  }

  public consuming func map(
    _ transform: @escaping @Sendable (T) async throws -> T
  ) async throws -> InterceptorResultStream<T> {
    let stream = self.stream

    let newStream = AsyncThrowingStream { continuation in
      let task = Task {
        do {
          for try await result in stream {
            try Task.checkCancellation()

            try await continuation.yield(transform(result))
          }
          continuation.finish()

        } catch {
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { _ in task.cancel() }
    }
    return Self.init(stream: newStream)
  }

  public consuming func compactMap(
    _ transform: @escaping @Sendable (T) async throws -> T?
  ) async throws -> InterceptorResultStream<T> {
    let stream = self.stream

    let newStream = AsyncThrowingStream { continuation in
      let task = Task {
        do {
          for try await result in stream {
            try Task.checkCancellation()

            guard let newResult = try await transform(result) else {
              continue
            }

            continuation.yield(newResult)
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { _ in task.cancel() }
    }
    return Self.init(stream: newStream)
  }

  public consuming func getResults() -> AsyncThrowingStream<T, any Error> {
    return stream
  }

}

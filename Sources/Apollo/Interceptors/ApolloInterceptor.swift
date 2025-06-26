import Combine
import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

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
}

/// A protocol to set up a chainable unit of networking work.
public protocol ApolloInterceptor: Sendable {

  typealias NextInterceptorFunction<Request: GraphQLRequest> = @Sendable (Request) async throws ->
    InterceptorResultStream<GraphQLResponse<Request.Operation>>

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

public struct HTTPResponse: Sendable, ~Copyable {
  public let response: HTTPURLResponse

  public let chunks: InterceptorResultStream<Data>

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

#warning("TODO: Rename to something that explains what this actually does instead of its current use case.")
public struct InterceptorResultStream<T: Sendable>: Sendable, ~Copyable {

  private let stream: AsyncThrowingStream<T, any Error>

  init(stream: AsyncThrowingStream<T, any Error>) {
    self.stream = stream
  }

  init<S: AsyncSequence & Sendable>(stream wrapped: sending S) where S.Element == T {
    self.stream = AsyncThrowingStream { continuation in
      let task = Task { [wrapped] in
        do {
          for try await element in wrapped {
            continuation.yield(element)
          }

          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { _ in task.cancel() }
    }
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

  // MARK: - Error Handling

  #warning("TODO: Write unit tests for this. Docs: if return nil, error is supressed and stream finishes.")
  public consuming func mapErrors(
    _ transform: @escaping @Sendable (any Error) async throws -> T?
  ) async throws -> InterceptorResultStream<T> {
    let stream = self.stream

    let newStream = AsyncThrowingStream { continuation in
      let task = Task {
        do {
          for try await result in stream {
            try Task.checkCancellation()

            continuation.yield(result)
          }
          continuation.finish()

        } catch {
          do {
            if let recoveryResult = try await transform(error) {
              continuation.yield(recoveryResult)
            }
            continuation.finish()

          } catch {
            continuation.finish(throwing: error)
          }
        }
      }

      continuation.onTermination = { _ in task.cancel() }
    }
    return Self.init(stream: newStream)
  }

}

#warning("Do we keep this? Helps make TaskLocalValues work, but extension on Swift standard lib type could conflict with other extensions")
extension TaskLocal {

  @_disfavoredOverload
  final public func withValue<R: ~Copyable>(
    _ valueDuringOperation: Value,
    operation: () async throws -> R
  ) async rethrows -> R {
    var returnValue: R?

    try await self.withValue(valueDuringOperation) {
      returnValue = try await operation()
    }

    return returnValue!
  }

  @_disfavoredOverload
  final public func withValue<R: ~Copyable>(
    _ valueDuringOperation: Value,
    operation: () throws -> R
  ) rethrows -> R {
    var returnValue: R?

    try self.withValue(valueDuringOperation) {
      returnValue = try operation()
    }

    return returnValue!
  }

}

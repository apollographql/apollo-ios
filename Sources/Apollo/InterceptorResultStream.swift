import Foundation

#warning("TODO: Rename to something that explains what this actually does instead of its current use case.")
public struct InterceptorResultStream<T: Sendable>: Sendable, ~Copyable {

  private let stream: AsyncThrowingStream<T, any Error>

  public init(stream: AsyncThrowingStream<T, any Error>) {
    self.stream = stream
  }

  public init<S: AsyncSequence & Sendable>(stream wrapped: sending S) where S.Element == T {
    self.stream = AsyncThrowingStream.executingInAsyncTask { [wrapped] continuation in
      for try await element in wrapped {
        continuation.yield(element)
      }
    }
  }

  public consuming func map(
    _ transform: @escaping @Sendable (T) async throws -> T
  ) async throws -> InterceptorResultStream<T> {
    let stream = self.stream

    let newStream = AsyncThrowingStream.executingInAsyncTask { continuation in
      for try await result in stream {
        try Task.checkCancellation()

        try await continuation.yield(transform(result))
      }
    }

    return Self.init(stream: newStream)
  }

  public consuming func compactMap(
    _ transform: @escaping @Sendable (T) async throws -> T?
  ) async throws -> InterceptorResultStream<T> {
    let stream = self.stream

    let newStream = AsyncThrowingStream.executingInAsyncTask { continuation in
      for try await result in stream {
        try Task.checkCancellation()

        guard let newResult = try await transform(result) else {
          continue
        }

        continuation.yield(newResult)
      }
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

    let newStream = AsyncThrowingStream.executingInAsyncTask { continuation in
      do {
        for try await result in stream {
          try Task.checkCancellation()

          continuation.yield(result)
        }

      } catch {
        do {
          if let recoveryResult = try await transform(error) {
            continuation.yield(recoveryResult)
          }

        } catch {
          continuation.finish(throwing: error)
        }
      }
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

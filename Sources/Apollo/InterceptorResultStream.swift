import Foundation

/// A move-only wrapper around an `AsyncThrowingStream` that conforms to `~Copyable` used to
/// protect against multiple concurrent consumers receiving partial data.
///
/// `AsyncThrowingStream` does not support multiple consumers awaiting on it's elements. Any
/// elements consumed by one consumer will not be emitted to any others.
/// `NonCopyableAsyncThrowingStream` helps to protect a stream's elements from being consumed
/// until the final consumer.
///
/// Intermediary consumers may used the mapping functions of the stream to read or transform the
/// stream's emitted values. These functions wrap the consumed stream in a new stream, which is
/// returned. Because these functions `consume` the reciever, only the newly returned stream is
/// available to be used after the function returns.
///
/// When a stream reaches it's final consumer, `getStream()` may be called to return the
/// underlying `AsyncThrowingStream`. The caller is then responsible for ensuring the stream
/// is only awaited by a single consumer.
public struct NonCopyableAsyncThrowingStream<Element: Sendable>: Sendable, ~Copyable {

  private let stream: AsyncThrowingStream<Element, any Error>

#warning("Maybe these shouldn't be public inits. Easy to create bugs when creating your own stream")
  public init(stream: AsyncThrowingStream<Element, any Error>) {
    self.stream = stream
  }

  public init<S: AsyncSequence & Sendable>(stream wrapped: sending S) where S.Element == Element {
    self.stream = AsyncThrowingStream.executingInAsyncTask { [wrapped] continuation in
      for try await element in wrapped {
        continuation.yield(element)
      }
    }
  }

  public consuming func map<ElementOfResult>(
    _ transform: @escaping @Sendable (Element) async throws -> ElementOfResult
  ) async -> NonCopyableAsyncThrowingStream<ElementOfResult> {
    let stream = self.stream

    let newStream = AsyncThrowingStream.executingInAsyncTask { continuation in
      for try await result in stream {
        try Task.checkCancellation()

        try await continuation.yield(transform(result))
      }
    }

    return NonCopyableAsyncThrowingStream<ElementOfResult>.init(stream: newStream)
  }

  public consuming func compactMap<ElementOfResult>(
    _ transform: @escaping @Sendable (Element) async throws -> ElementOfResult?
  ) async -> NonCopyableAsyncThrowingStream<ElementOfResult> {
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

    return NonCopyableAsyncThrowingStream<ElementOfResult>.init(stream: newStream)
  }

  /// Exposes the underlying `AsyncThrowingStream` for final consumption.
  ///
  /// When a stream reaches it's final consumer, `getStream()` may be called to return the
  /// underlying `AsyncThrowingStream`. The caller is then responsible for ensuring the stream
  /// is only awaited by a single consumer.
  ///
  /// - Returns: The underlying `AsyncThrowingStream`
  public consuming func getStream() -> AsyncThrowingStream<Element, any Error> {
    return stream
  }

  // MARK: - Error Handling

  #warning("TODO: Write unit tests for this. Docs: if return nil, error is supressed and stream finishes.")
  public consuming func mapErrors(
    _ transform: @escaping @Sendable (any Error) async throws -> Element?
  ) async -> NonCopyableAsyncThrowingStream<Element> {
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

    return NonCopyableAsyncThrowingStream.init(stream: newStream)
  }

}

#warning("Do we keep this public? Helps make TaskLocalValues work, but extension on Swift standard lib type could conflict with other extensions")
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

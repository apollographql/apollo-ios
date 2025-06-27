import Foundation

extension AsyncThrowingStream where Failure == any Swift.Error {
  static func executingInAsyncTask(_ block: @escaping @Sendable (Continuation) async throws -> Void) -> Self {
    return AsyncThrowingStream { continuation in
      let task = Task {
        do {
          try await block(continuation)
          continuation.finish()

        } catch {
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { _ in task.cancel() }
    }
  }
}

extension AsyncThrowingStream.Continuation {
  func passthroughResults(
    of stream: AsyncThrowingStream<Element, Failure>
  ) async throws {
    for try await element in stream {
      self.yield(element)
    }
  }
}

import Foundation
import Atomics

extension ApolloStore {
  final class ReaderWriter: Sendable {

    /// Atomic counter for number of current readers.
    /// While writing, this will have a value of `WRITING`
    private let readerCount = ManagedAtomic(0)

    /// Value for `readerCount` while in writing state
    private static let WRITING = -1

    // MARK: - Read

    func read(_ body: () async throws -> Void) async rethrows {
      await beginReading()
      defer { finishReading() }

      try await body()
    }

    private func beginReading() async {
      var didIncrementReadCount = false

      while true {
        let currentReaderCount = readerCount.load(ordering: .relaxed)

        guard currentReaderCount != Self.WRITING else {
          await Task.yield()
          continue
        }

        (didIncrementReadCount, _) = readerCount.weakCompareExchange(
          // Ensure no other thread has changed count before increment
          expected: currentReaderCount,
          // Increment count to add reader
          desired: currentReaderCount + 1,
          ordering: .acquiringAndReleasing
        )

        if didIncrementReadCount { return }
      }
    }

    private func finishReading() {
      readerCount.wrappingDecrement(ordering: .acquiringAndReleasing)
    }

    // MARK: - Write
    func write(_ body: () async throws -> Void) async rethrows {
      await beginWriting()
      defer { finishWriting() }
      try await body()
    }

    private func beginWriting() async {
      while true {
        let (didSetWritingFlag, _) = readerCount.weakCompareExchange(
          expected: 0,
          desired: Self.WRITING,
          ordering: .acquiringAndReleasing
        )

        if didSetWritingFlag { return } else {
          await Task.yield()
        }
      }
    }

    func finishWriting() {
      readerCount.store(0, ordering: .releasing)
    }
  }
}


import Foundation

actor AsyncReadWriteLock {
  private enum State {
    case idle
    case reading
    case writing
  }

  private var state: State = .idle
  private var queue: Queue = Queue()
  private var runningReadCount: UInt = 0

  /// Waits for all current reads/writes to be completed, then calls the provided closure while preventing
  /// any other reads/writes from beginning.
  ///
  /// This function should be `rethrows` but the compiler doesn't understand that when passing the `block` into a Task.
  /// If the `body` provided does not throw, this function will not throw.
  func write(_ body: @Sendable @escaping () async throws -> Void) async throws {
    switch state {
    case .writing, .reading:
      await addToQueueAndWait(isWriter: true)

    case .idle:
      state = .writing
    }

    defer { writeTaskDidFinish() }

    let writeTask = Task {
      try await body()
    }

    try await writeTask.value
  }

  /// Waits for all current writes to be completed, then calls the provided closure while preventing
  /// any other writes from beginning. Other reads may be executed concurrently.
  ///
  /// This function should be `rethrows` but the compiler doesn't understand that when passing the `block` into a Task.
  /// If the `body` provided does not throw, this function will not throw.
  func read(_ body: @Sendable @escaping () async throws -> Void) async throws {
    switch state {
    case .writing:
      await addToQueueAndWait(isWriter: false)

    case .reading:
      // If we are currently reading, there will only be a queue if there is at least one waiting writer. If a writer
      // is waiting, we should queue the new reader for after the write.
      if !queue.isEmpty {
        await addToQueueAndWait(isWriter: false)
      }
      
    case .idle:
      state = .reading
    }

    runningReadCount += 1

    defer { readTaskDidFinish() }

    let readTask = Task {
      try await body()
    }

    try await readTask.value
  }

  private func addToQueueAndWait(isWriter: Bool) async {
    await withCheckedContinuation { continuation in
      switch isWriter {
      case true:
        queue.addWriteTask(continuation)
      case false:
        queue.addReadTask(continuation)
      }
    }
  }

  private func readTaskDidFinish() {
    runningReadCount -= 1
    if runningReadCount == 0 {
      wakeNext()
    }
  }

  private func writeTaskDidFinish() {
    wakeNext()
  }

  private func wakeNext() {
    guard let nextItem = queue.pop() else {
      state = .idle
      return
    }

    switch nextItem {
    case let .write(continuation):
      state = .writing
      continuation.resume()

    case let .readBatch(continuations):
      state = .reading
      for continuation in continuations {
        continuation.resume()
      }
    }
  }

  /// MARK: - Queue
  private struct Queue {
    enum Item {
      case write(CheckedContinuation<Void, Never>)
      case readBatch([CheckedContinuation<Void, Never>])
    }

    private var queueItems: [Item] = []

    mutating func addWriteTask(_ continuation: CheckedContinuation<Void, Never>) {
      queueItems.append(.write(continuation))
    }

    mutating func addReadTask(_ continuation: CheckedContinuation<Void, Never>) {
      if case var .readBatch(batch) = queueItems.first {
        batch.append(continuation)
        queueItems[0] = .readBatch(batch)

      } else {
        queueItems.append(.readBatch([continuation]))
      }
    }

    mutating func pop() -> Item? {
      guard !queueItems.isEmpty else {
        return nil
      }
      return queueItems.removeFirst()
    }

    var isEmpty: Bool {
      queueItems.isEmpty
    }
  }

}

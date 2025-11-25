import Foundation

actor AsyncReadWriteLock {
  private enum State {
    case idle
    case reading
    case writing
  }

  private final class ReadTask: Sendable {
    let task: Task<Void, any Swift.Error>

    init(_ body: @Sendable @escaping () async throws -> Void) {
      task = Task {
        try await body()
      }
    }
  }

  private var currentReadTasks: [ObjectIdentifier: ReadTask] = [:]
  private var currentWriteTask: Task<Void, any Swift.Error>?
  private var queue: [(handle: CheckedContinuation<Void, Never>, isWriter: Bool)] = []

  private var state: State {
    if currentWriteTask != nil { return .writing }
    if !currentReadTasks.isEmpty { return .reading }
    return .idle
  }

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
      break
    }

    defer {
      currentWriteTask = nil
      writeTaskDidFinish()
    }
    let writeTask = Task {
      try await body()
    }
    currentWriteTask = writeTask

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
      break
    }

    let readTask = ReadTask(body)
    let taskID = ObjectIdentifier(readTask)
    defer {
      currentReadTasks[taskID] = nil
      readTaskDidFinish()
    }
    currentReadTasks[taskID] = readTask

    try await readTask.task.value
  }

  private func addToQueueAndWait(isWriter: Bool) async {
    await withCheckedContinuation { continuation in
      queue.append((handle: continuation, isWriter: isWriter))
    }
  }

  private func readTaskDidFinish() {
    if state == .idle {
      wakeNext()
    }
  }

  private func writeTaskDidFinish() {
    wakeNext()
  }

  private func wakeNext() {
    guard !queue.isEmpty else {
      return
    }

    let next = queue[0]
    next.handle.resume(returning: ())

    if next.isWriter {
      queue.remove(at: 0)
      return

    } else {
      var lastReader = 0
      for i in 1..<queue.count {
        guard !queue[i].isWriter else { break }
        queue[i].handle.resume(returning: ())
        lastReader = i
      }
      queue.removeSubrange(0...lastReader)
    }
  }

}

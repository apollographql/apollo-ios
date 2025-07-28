import Foundation

actor AsyncReadWriteLock {
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

  /// Waits for all current reads/writes to be completed, then calls the provided closure while preventing
  /// any other reads/writes from beginning.
  ///
  /// This function should be `rethrows` but the compiler doesn't understand that when passing the `block` into a Task.
  ///  If the `body` provided does not throw, this function will not throw.
  func write(_ body: @Sendable @escaping () async throws -> Void) async throws {
    while currentWriteTask != nil || !currentReadTasks.isEmpty {
      await Task.yield()
      continue
    }

    defer { currentWriteTask = nil }
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
  ///  If the `body` provided does not throw, this function will not throw.
  func read(_ body: @Sendable @escaping () async throws -> Void) async throws {
    while currentWriteTask != nil {
      await Task.yield()
      continue
    }

    let readTask = ReadTask(body)
    let taskID = ObjectIdentifier(readTask)
    defer { currentReadTasks[taskID] = nil }
    currentReadTasks[taskID] = readTask

    try await readTask.task.value
  }

}

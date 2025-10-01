import Foundation

/// An object that can be used to cancel an in progress action.
@available(*, deprecated)
public protocol Cancellable: Sendable {
  /// Cancel an in progress action.
  func cancel()
}

// MARK: - Task Cancellable

@available(*, deprecated)
final class TaskCancellable<Success: Sendable, Failure: Error>: Apollo.Cancellable {

  let task: Task<Success, Failure>

  init(task: Task<Success, Failure>) {
    self.task = task
  }

  func cancel() {
    task.cancel()
  }
}

// MARK: - GraphQLQueryWatcher

@available(*, deprecated)
extension GraphQLQueryWatcher: Cancellable {}

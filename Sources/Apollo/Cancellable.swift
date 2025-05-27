import Foundation

/// An object that can be used to cancel an in progress action.
@available(*, deprecated)
public protocol Cancellable: AnyObject, Sendable {
    /// Cancel an in progress action.
    func cancel()
}

// MARK: - URL Session Conformance

@available(*, deprecated)
extension URLSessionTask: Cancellable {}

// MARK: - Early-Exit Helper

/// A class to return when we need to bail out of something which still needs to return `Cancellable`.
@available(*, deprecated)
public final class EmptyCancellable: Cancellable {

  // Needs to be public so this can be instantiated outside of the current framework.
  public init() {}

  public func cancel() {
    // Do nothing, an error occurred and there is nothing to cancel.
  }
}

// MARK: - Task Conformance

#warning("Test that this works. Task is a struct, not a class.")
@available(*, deprecated)
public final class TaskCancellable<Success: Sendable, Failure: Error>: Cancellable {

  let task: Task<Success, Failure>

  init(task: Task<Success, Failure>) {
    self.task = task
  }

  public func cancel() {
    task.cancel()
  }
}

// MARK: - CancellationState

@available(*, deprecated)
public class CancellationState: Cancellable, @unchecked Sendable {

  @Atomic var isCancelled: Bool = false

  nonisolated public func cancel() {
    if isCancelled { return }
    $isCancelled.mutate {
      $0 = true
    }
  }
}

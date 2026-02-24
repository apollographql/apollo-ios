import Foundation

/// Manages continuations for callers waiting for a WebSocket connection to be established.
///
/// Populated while the connection is in the `connecting` state. Resumed when `connection_ack`
/// arrives or failed if the connection terminates before acknowledgement.
///
/// This is a value type designed to be stored as a property of an actor. It does not provide
/// its own synchronization — all access must be serialized by the owning actor.
struct ConnectionWaiterQueue {

  /// Continuations keyed by UUID so individual waiters can be cancelled independently
  /// via `withTaskCancellationHandler`.
  private var waiters: [UUID: CheckedContinuation<Void, any Swift.Error>] = [:]

  /// Adds a waiter continuation with the given ID.
  mutating func add(id: UUID, continuation: CheckedContinuation<Void, any Swift.Error>) {
    waiters[id] = continuation
  }

  /// Cancels a single waiter identified by its UUID.
  ///
  /// Called from the `onCancel` handler of `withTaskCancellationHandler` when the
  /// waiting task is cancelled before `connection_ack` arrives.
  mutating func cancel(id: UUID) {
    if let waiter = waiters.removeValue(forKey: id) {
      waiter.resume(throwing: CancellationError())
    }
  }

  /// Resumes all pending waiters with success.
  mutating func resumeAll() {
    let current = waiters
    waiters.removeAll()
    for (_, waiter) in current {
      waiter.resume()
    }
  }

  /// Fails all pending waiters with the given error.
  mutating func failAll(with error: any Swift.Error) {
    let current = waiters
    waiters.removeAll()
    for (_, waiter) in current {
      waiter.resume(throwing: error)
    }
  }
}

import Foundation

/// A thread-safe container for a ``SubscriptionState`` value.
///
/// Transports use this class to communicate subscription lifecycle state to
/// the ``SubscriptionStream`` held by the consumer. The transport updates
/// the state from its own isolation context, while the consumer reads it
/// from any context.
package final class SubscriptionStateStorage: @unchecked Sendable {
  private let lock = NSLock()
  private var _state: SubscriptionState = .pending

  package init() {}

  package var state: SubscriptionState {
    lock.lock()
    defer { lock.unlock() }
    return _state
  }

  package func set(_ state: SubscriptionState) {
    lock.lock()
    _state = state
    lock.unlock()
  }
}

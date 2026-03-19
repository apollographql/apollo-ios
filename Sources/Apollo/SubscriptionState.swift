/// The lifecycle state of an individual GraphQL subscription.
///
/// This state reflects where the subscription currently is in its lifecycle,
/// from initial setup through active data reception to termination.
///
/// For WebSocket-based subscriptions, the state includes connection-aware
/// states like ``reconnecting`` and ``paused`` that reflect the health of
/// the underlying connection.
public enum SubscriptionState: Sendable, Equatable, CustomStringConvertible {

  /// The reason a subscription finished.
  public enum FinishReason: Sendable, Equatable {
    /// The server completed the subscription normally.
    case completed
    /// The subscription was cancelled by the client.
    case cancelled
    /// The subscription was terminated due to an error.
    ///
    /// Use pattern matching to extract the error:
    /// ```swift
    /// if case .finished(.error(let error)) = stream.state {
    ///   print("Subscription failed: \(error)")
    /// }
    /// ```
    case error(any Error)

    public static func == (lhs: FinishReason, rhs: FinishReason) -> Bool {
      switch (lhs, rhs) {
      case (.completed, .completed): return true
      case (.cancelled, .cancelled): return true
      case (.error, .error): return true
      default: return false
      }
    }
  }

  /// The subscription has been initiated but is not yet active.
  ///
  /// The transport may still be establishing a connection or sending
  /// the subscribe message to the server.
  case pending

  /// The subscription is active and may receive data from the server.
  case active

  /// The subscription's underlying connection was intentionally paused.
  ///
  /// The subscription will resume automatically when the connection is
  /// restored via the transport's `resume()` method.
  case paused

  /// The subscription's underlying connection was lost.
  ///
  /// The transport is attempting to reconnect and will automatically
  /// resubscribe when the connection is restored.
  case reconnecting

  /// The subscription has ended.
  ///
  /// Inspect the associated ``FinishReason`` to determine whether the
  /// subscription completed normally, was cancelled by the client,
  /// or terminated due to an error.
  case finished(FinishReason)

  public static func == (lhs: SubscriptionState, rhs: SubscriptionState) -> Bool {
    switch (lhs, rhs) {
    case (.pending, .pending): return true
    case (.active, .active): return true
    case (.paused, .paused): return true
    case (.reconnecting, .reconnecting): return true
    case (.finished(let l), .finished(let r)): return l == r
    default: return false
    }
  }

  public var description: String {
    switch self {
    case .pending: return "pending"
    case .active: return "active"
    case .paused: return "paused"
    case .reconnecting: return "reconnecting"
    case .finished(let reason):
      switch reason {
      case .completed: return "finished(completed)"
      case .cancelled: return "finished(cancelled)"
      case .error(let error): return "finished(error: \(error))"
      }
    }
  }
}

/// A protocol for creating custom operation message identifiers for WebSocket operations.
///
/// Conform to this protocol to provide custom identifiers for GraphQL operations sent over
/// WebSocket. The default implementation, ``ApolloSequencedOperationMessageIdCreator``,
/// generates sequential numeric identifiers starting from 1.
///
/// Thread-safety is provided by the ``WebSocketTransport`` actor. Implementations do not need
/// their own synchronization — the `mutating` requirement allows value-type implementations
/// to maintain internal state (such as a counter) that is protected by the actor's isolation.
public protocol OperationMessageIdCreator: Sendable {
  /// Generates a unique identifier for a WebSocket operation message.
  ///
  /// Called once for each GraphQL operation (query, mutation, or subscription) sent over the
  /// WebSocket connection. The returned identifier is used in the `id` field of the `subscribe`
  /// and `complete` messages in the `graphql-transport-ws` protocol.
  mutating func requestId() -> String
}

/// The default ``OperationMessageIdCreator`` that generates sequential numeric identifiers.
///
/// Identifiers start from a configurable number (defaults to `1`) and increment by one for
/// each operation: `"1"`, `"2"`, `"3"`, etc.
///
/// Thread-safety is provided by the ``WebSocketTransport`` actor — no additional
/// synchronization is needed.
public struct ApolloSequencedOperationMessageIdCreator: OperationMessageIdCreator {
  private var sequenceNumber: Int

  /// Creates a new sequenced ID creator.
  ///
  /// - Parameter sequenceNumber: The starting sequence number. Defaults to `1`.
  public init(startAt sequenceNumber: Int = 1) {
    self.sequenceNumber = sequenceNumber
  }

  public mutating func requestId() -> String {
    let id = sequenceNumber
    sequenceNumber += 1
    return "\(id)"
  }
}

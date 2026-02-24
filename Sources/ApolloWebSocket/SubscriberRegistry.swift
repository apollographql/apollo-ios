@_spi(Unsafe) import ApolloAPI

/// Manages the collection of active operation subscribers for a WebSocket transport.
///
/// This is a value type designed to be stored as a property of an actor. It does not provide
/// its own synchronization — all access must be serialized by the owning actor.
struct SubscriberRegistry {

  /// Tracks a single subscriber's continuation, operation, and lifecycle status.
  private struct Record {
    enum Status {
      /// Registered but the subscribe message has not yet been sent to the server
      /// (e.g. still waiting for the connection to be established).
      case pending
      /// The subscribe message has been sent to the server.
      case subscribed
    }

    let continuation: AsyncThrowingStream<JSONObject, any Swift.Error>.Continuation
    let operation: any GraphQLOperation
    var status: Status
  }

  /// Active subscribers keyed by operation ID.
  private var records: [WebSocketTransport.OperationID: Record] = [:]

  private var nextOperationID: WebSocketTransport.OperationID = 1

  /// Whether there are any active subscribers.
  var isEmpty: Bool { records.isEmpty }

  /// The number of active subscribers.
  var count: Int { records.count }

  /// Registers a new subscriber for the given operation.
  ///
  /// Returns the assigned operation ID and the stream that will receive JSON payloads
  /// from incoming `next` messages.
  mutating func register(
    for operation: any GraphQLOperation
  ) -> (WebSocketTransport.OperationID, AsyncThrowingStream<JSONObject, any Swift.Error>) {
    let id = nextOperationID
    nextOperationID += 1

    let (stream, continuation) = AsyncThrowingStream<JSONObject, any Swift.Error>.makeStream()
    records[id] = Record(
      continuation: continuation,
      operation: operation,
      status: .pending
    )

    return (id, stream)
  }

  /// Yields a JSON payload to the subscriber with the given ID.
  func yield(_ payload: JSONObject, for id: WebSocketTransport.OperationID) {
    records[id]?.continuation.yield(payload)
  }

  /// Removes the subscriber with the given ID and finishes its continuation.
  ///
  /// Returns `true` if a subscriber with the given ID existed and was removed,
  /// `false` if the subscriber was already removed (e.g. by a prior server `complete`).
  @discardableResult
  mutating func finish(_ id: WebSocketTransport.OperationID, throwing error: (any Swift.Error)? = nil) -> Bool {
    guard let record = records.removeValue(forKey: id) else { return false }
    record.continuation.finish(throwing: error)
    return true
  }

  /// Marks a subscriber as having sent its subscribe message to the server.
  mutating func markSubscribed(_ id: WebSocketTransport.OperationID) {
    records[id]?.status = .subscribed
  }

  /// The IDs and operations of all subscribers with `.subscribed` status.
  ///
  /// Used for resubscription after reconnection. Does not include `.pending` subscribers,
  /// whose inner tasks will send their own subscribe messages after connection is established.
  var activeSubscriptions: [(id: WebSocketTransport.OperationID, operation: any GraphQLOperation)] {
    records.compactMap { (id, record) in
      record.status == .subscribed ? (id, record.operation) : nil
    }
  }

  /// Finishes all subscribers, optionally with an error, and clears the registry.
  mutating func finishAll(throwing error: (any Swift.Error)? = nil) {
    let active = records
    records.removeAll()
    for (_, record) in active {
      record.continuation.finish(throwing: error)
    }
  }

  /// Finishes all non-subscription (query/mutation) subscribers with the given error.
  ///
  /// One-shot operations should not survive reconnection — replaying a mutation
  /// could cause duplicate side effects.
  mutating func finishNonSubscriptions(throwing error: any Swift.Error) {
    for (id, record) in records {
      guard type(of: record.operation).operationType != .subscription else { continue }
      records.removeValue(forKey: id)
      record.continuation.finish(throwing: error)
    }
  }
}

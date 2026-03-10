import Apollo
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
    let stateStorage: SubscriptionStateStorage?

    func finish(reason: SubscriptionState.FinishReason) {
      stateStorage?.set(.finished(reason))
      switch reason {
      case .completed, .cancelled:
        continuation.finish()
      case .error(let error):
        continuation.finish(throwing: error)
      }
    }
  }

  /// Active subscribers keyed by operation ID.
  private var records: [WebSocketTransport.OperationID: Record] = [:]

  private var operationMessageIdCreator: any OperationMessageIdCreator

  init(operationMessageIdCreator: any OperationMessageIdCreator) {
    self.operationMessageIdCreator = operationMessageIdCreator
  }

  /// Whether there are any active subscribers.
  var isEmpty: Bool { records.isEmpty }

  /// The number of active subscribers.
  var count: Int { records.count }

  /// Registers a new subscriber for the given operation.
  ///
  /// Returns the assigned operation ID and the stream that will receive JSON payloads
  /// from incoming `next` messages.
  ///
  /// - Parameters:
  ///   - operation: The GraphQL operation to register.
  ///   - stateStorage: An optional state storage for tracking the subscription's lifecycle
  ///     state. Pass `nil` for non-subscription operations (queries/mutations).
  mutating func register(
    for operation: any GraphQLOperation,
    stateStorage: SubscriptionStateStorage? = nil
  ) -> (WebSocketTransport.OperationID, AsyncThrowingStream<JSONObject, any Swift.Error>) {
    let id = operationMessageIdCreator.requestId()

    let (stream, continuation) = AsyncThrowingStream<JSONObject, any Swift.Error>.makeStream()

    // When the consuming task is cancelled the runtime invokes onTermination.
    // Finishing the continuation here unblocks any pending `next()` call so the
    // consumer's `for try await` loop can exit and run its own cleanup.
    continuation.onTermination = { @Sendable _ in
      continuation.finish()
    }

    records[id] = Record(
      continuation: continuation,
      operation: operation,
      status: .pending,
      stateStorage: stateStorage
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
  mutating func finish(_ id: WebSocketTransport.OperationID, reason: SubscriptionState.FinishReason = .completed) -> Bool {
    guard let record = records.removeValue(forKey: id) else { return false }
    record.finish(reason: reason)
    return true
  }

  /// Marks a subscriber as having sent its subscribe message to the server.
  mutating func markSubscribed(_ id: WebSocketTransport.OperationID) {
    records[id]?.status = .subscribed
    records[id]?.stateStorage?.set(.active)
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

  /// Finishes all subscribers with the given reason and clears the registry.
  mutating func finishAll(reason: SubscriptionState.FinishReason = .completed) {
    let active = records
    records.removeAll()
    for (_, record) in active {
      record.finish(reason: reason)
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
      record.finish(reason: .error(error))
    }
  }

  /// Sets the state of all subscriptions with `.subscribed` status to ``SubscriptionState/reconnecting``.
  ///
  /// Called when the connection is lost and auto-reconnection is being attempted.
  /// Only affects subscriptions (not queries/mutations) that have already been subscribed.
  func markSubscriptionsReconnecting() {
    for (_, record) in records {
      guard record.status == .subscribed else { continue }
      record.stateStorage?.set(.reconnecting)
    }
  }

  /// Sets the state of all surviving subscriptions to ``SubscriptionState/paused``.
  ///
  /// Called when the transport is paused. Only subscriptions survive a pause;
  /// queries and mutations are terminated before this is called.
  func markSubscriptionsPaused() {
    for (_, record) in records {
      guard type(of: record.operation).operationType == .subscription else { continue }
      record.stateStorage?.set(.paused)
    }
  }
}

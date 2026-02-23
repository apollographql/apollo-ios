@_spi(Execution) import Apollo
@_spi(Unsafe) import ApolloAPI
import Foundation

public actor WebSocketTransport: SubscriptionNetworkTransport, NetworkTransport {

  public enum Error: Swift.Error {
    /// WebSocketTransport has not yet been implemented for Apollo iOS 2.0.
    /// This will be implemented in a future release.
    case notImplemented
    /// The received WebSocket message could not be parsed as a valid `graphql-transport-ws` message.
    case unrecognizedMessage
    /// The WebSocket connection was closed before the server acknowledged the connection.
    case connectionClosed
    /// The subscription operation does not have a query document definition.
    case missingQueryDocument
    /// The server sent one or more GraphQL errors for a subscription operation.
    case graphQLErrors([GraphQLError])
  }

  /// Configuration options for ``WebSocketTransport``.
  public struct Configuration: Sendable {
    /// The interval to wait before attempting to reconnect after a disconnect.
    ///
    /// - A value of `0` means reconnect immediately with no delay.
    /// - A negative value (e.g. `-1`) disables auto-reconnection entirely.
    ///
    /// When auto-reconnection is enabled and the connection drops while there are active
    /// subscribers, the transport will automatically reconnect and re-subscribe all active
    /// operations on the new connection. Subscriber streams are kept alive across the
    /// reconnection — callers are unaware the disconnect happened.
    ///
    /// Default: `-1` (disabled).
    public var reconnectionInterval: TimeInterval

    /// Whether auto-reconnection is enabled based on the configuration.
    public var isReconnectEnabled: Bool {
      reconnectionInterval >= 0
    }

    public init(reconnectionInterval: TimeInterval = -1) {
      self.reconnectionInterval = reconnectionInterval
    }
  }

  struct Constants {
    static let headerWSProtocolName = "Sec-WebSocket-Protocol"
    static let headerWSProtocolValue = "graphql-transport-ws"
  }

  enum ConnectionState {
    case notStarted
    case connecting
    case connected
    case disconnected
  }

  /// Tracks a single subscriber's continuation, operation, and lifecycle status.
  struct SubscriberRecord {
    enum Status {
      /// Registered but the subscribe message has not yet been sent to the server
      /// (e.g. still waiting for the connection to be established).
      case pending
      /// The subscribe message has been sent to the server.
      case subscribed
    }

    let continuation: AsyncThrowingStream<JSONObject, any Swift.Error>.Continuation
    let operation: any GraphQLSubscription
    var status: Status
  }

  public let urlSession: WebSocketURLSession

  public let store: ApolloStore

  public let configuration: Configuration

  private let request: URLRequest

  private var connection: WebSocketConnection

  var connectionState: ConnectionState = .notStarted

  private var nextOperationID: OperationID = 1

  /// Active subscribers keyed by operation ID. Each record contains the continuation that
  /// receives raw JSON payloads from incoming `next` messages, the operation reference
  /// (used to re-subscribe on reconnection), and the current lifecycle status.
  var subscribers: [OperationID: SubscriberRecord] = [:]

  /// Continuations of callers waiting for the connection to reach the `connected` state.
  /// Populated only while `connectionState == .connecting`. Resumed when `connectionAck` arrives
  /// or failed if the connection stream terminates before acknowledgement.
  /// Keyed by UUID so individual waiters can be cancelled via `withTaskCancellationHandler`.
  private var connectionWaiters: [UUID: CheckedContinuation<Void, any Swift.Error>] = [:]

  public init(
    urlSession: WebSocketURLSession,
    store: ApolloStore,
    endpointURL: URL,
    configuration: Configuration = Configuration()
  ) throws {
    self.urlSession = urlSession
    self.store = store
    self.configuration = configuration
    self.request = try Self.createURLRequest(endpointURL: endpointURL)
    self.connection = WebSocketConnection(task: urlSession.webSocketTask(with: request))
  }

  // MARK: - Request Setup

  private static func createURLRequest(
    endpointURL: URL
  ) throws -> URLRequest {
    var request = URLRequest(url: endpointURL)

    request.setValue(Constants.headerWSProtocolValue, forHTTPHeaderField: Constants.headerWSProtocolName)

    return request
  }

  // MARK: - Connection Management

  /// Ensures the WebSocket connection is established before returning.
  ///
  /// Handles all four connection states:
  /// - `notStarted`: Opens the connection and waits for `connection_ack`.
  /// - `connecting`: Waits for the in-progress connection to receive `connection_ack`.
  /// - `connected`: Returns immediately.
  /// - `disconnected`: Creates a fresh connection and waits for `connection_ack`.
  private func ensureConnected() async throws {
    switch connectionState {
    case .notStarted:
      connectionState = .connecting
      startConnectionReceiveLoop()
      try await waitForConnectionAck()

    case .connecting:
      try await waitForConnectionAck()

    case .connected:
      return

    case .disconnected:
      connection = WebSocketConnection(task: urlSession.webSocketTask(with: request))
      connectionState = .connecting
      startConnectionReceiveLoop()
      try await waitForConnectionAck()
    }
  }

  /// Spawns a task that iterates the connection's message stream and routes incoming messages.
  ///
  /// When the stream terminates (normally or with error), the behavior depends on state:
  /// - If the connection was previously `connected`, there are active subscribers, and
  ///   auto-reconnection is enabled: attempts reconnection without terminating subscriber streams.
  /// - Otherwise: transitions to `disconnected`, fails pending connection waiters, and finishes
  ///   all subscriber streams.
  private func startConnectionReceiveLoop() {
    let connectionStream = self.connection.openConnection()

    Task {
      do {
        for try await message in connectionStream {
          didReceive(message: message)
        }
        await handleDisconnection()
      } catch {
        // Use Task.isCancelled to distinguish genuine task cancellation from
        // connection errors. The WebSocket task's receive() may throw errors
        // (including CancellationError) when the connection closes, which should
        // be treated as a disconnection — not as task cancellation.
        await handleDisconnection(error: Task.isCancelled ? nil : error)
      }
    }
  }

  /// Handles a disconnection from the receive loop.
  ///
  /// When `error` is nil, this is a normal disconnection (stream ended cleanly or task was
  /// cancelled). When non-nil, the error is forwarded to connection waiters and subscribers
  /// if reconnection is not attempted.
  private func handleDisconnection(error: (any Swift.Error)? = nil) async {
    let wasConnected = (self.connectionState == .connected)
    self.connectionState = .disconnected

    if wasConnected && !subscribers.isEmpty && configuration.isReconnectEnabled {
      await attemptReconnection()
    } else {
      failConnectionWaiters(with: error ?? Error.connectionClosed)
      finishAllSubscribers(throwing: error)
    }
  }

  /// Attempts to reconnect after a disconnect by creating a new connection.
  ///
  /// Waits for `reconnectionInterval` (if > 0) before connecting. Subscriber continuations
  /// are kept alive — they will receive data from the new connection after reconnection
  /// succeeds. If the reconnection attempt itself fails, `startConnectionReceiveLoop` will
  /// detect that the state was never `connected` and terminate everything.
  private func attemptReconnection() async {
    if configuration.reconnectionInterval > 0 {
      do {
        try await Task.sleep(nanoseconds: UInt64(configuration.reconnectionInterval * 1_000_000_000))
      } catch {
        // Sleep was cancelled — terminate everything
        finishAllSubscribers()
        return
      }
    }

    // If all subscribers were cancelled during the reconnection delay, no need to reconnect.
    guard !subscribers.isEmpty else {
      return
    }

    connection = WebSocketConnection(task: urlSession.webSocketTask(with: request))
    connectionState = .connecting
    startConnectionReceiveLoop()
  }

  /// Suspends the caller until the connection transitions to `connected`.
  ///
  /// If the connection is already `connected` (e.g. because `connection_ack` was buffered and
  /// processed before this method runs), returns immediately without suspending.
  /// Responds to task cancellation by resuming the waiter with `CancellationError`.
  private func waitForConnectionAck() async throws {
    if connectionState == .connected { return }

    let waiterID = UUID()
    try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Swift.Error>) in
        if Task.isCancelled {
          continuation.resume(throwing: CancellationError())
        } else {
          connectionWaiters[waiterID] = continuation
        }
      }
    } onCancel: {
      Task { await self.cancelConnectionWaiter(id: waiterID) }
    }
  }

  /// Cancels a single connection waiter identified by its UUID.
  /// Called from the `onCancel` handler of `withTaskCancellationHandler` when the
  /// waiting task is cancelled before `connection_ack` arrives.
  private func cancelConnectionWaiter(id: UUID) {
    if let waiter = connectionWaiters.removeValue(forKey: id) {
      waiter.resume(throwing: CancellationError())
    }
  }

  /// Resumes all pending connection waiters with success.
  private func resumeConnectionWaiters() {
    let waiters = connectionWaiters
    connectionWaiters.removeAll()
    for (_, waiter) in waiters {
      waiter.resume()
    }
  }

  /// Resumes all pending connection waiters with the given error.
  private func failConnectionWaiters(with error: any Swift.Error) {
    let waiters = connectionWaiters
    connectionWaiters.removeAll()
    for (_, waiter) in waiters {
      waiter.resume(throwing: error)
    }
  }

  // MARK: - Subscriber Management

  private func registerSubscriber(
    for operation: any GraphQLSubscription
  ) -> (OperationID, AsyncThrowingStream<JSONObject, any Swift.Error>) {
    let id = nextOperationID
    nextOperationID += 1

    let (stream, continuation) = AsyncThrowingStream<JSONObject, any Swift.Error>.makeStream()
    subscribers[id] = SubscriberRecord(
      continuation: continuation,
      operation: operation,
      status: .pending
    )

    return (id, stream)
  }

  /// Cancels a subscription from the client side. Removes the subscriber from the registry,
  /// finishes its payload stream, and sends a `complete` message to the server.
  /// No-ops if the subscriber was already removed (e.g. server already completed it).
  private func cancelSubscription(operationID: OperationID) {
    guard let record = subscribers.removeValue(forKey: operationID) else { return }
    record.continuation.finish()

    let message = Message.Outgoing.complete(id: operationID)
    if let wsMessage = try? message.toWebSocketMessage() {
      connection.send(wsMessage)
    }
  }

  private func sendSubscribeMessage<Subscription: GraphQLSubscription>(
    operationID: OperationID,
    subscription: Subscription
  ) throws {
    guard let queryDocument = Subscription.definition?.queryDocument else {
      throw Error.missingQueryDocument
    }

    let payload = SubscribePayload(
      operationName: Subscription.operationName,
      query: queryDocument,
      variables: subscription.__variables,
      extensions: nil
    )
    let message = Message.Outgoing.subscribe(id: operationID, payload: payload)
    connection.send(try message.toWebSocketMessage())
    subscribers[operationID]?.status = .subscribed
  }

  /// Re-sends subscribe messages for all subscribers that were previously subscribed.
  ///
  /// Called after a successful reconnection (on `connection_ack`). Only re-subscribes entries
  /// with status `.subscribed` — entries with status `.pending` are new subscribers whose
  /// inner tasks will send their own subscribe message after `ensureConnected()` returns.
  private func resubscribeActiveSubscribers() {
    for (id, record) in subscribers where record.status == .subscribed {
      do {
        try sendSubscribeMessage(operationID: id, subscription: record.operation)
      } catch {
        // Defensive: if re-subscribe fails (e.g. missing query document — shouldn't happen
        // since the first subscribe succeeded), terminate this individual subscriber.
        let removed = subscribers.removeValue(forKey: id)
        removed?.continuation.finish(throwing: error)
      }
    }
  }

  private func finishAllSubscribers(throwing error: (any Swift.Error)? = nil) {
    let active = subscribers
    subscribers.removeAll()
    for (_, record) in active {
      record.continuation.finish(throwing: error)
    }
  }

  // MARK: - Processing Messages

  private func didReceive(message: URLSessionWebSocketTask.Message) {
    do {
      let incoming = try Message.Incoming.from(message)

      switch incoming {
      case .connectionAck:
        self.connectionState = .connected
        resumeConnectionWaiters()
        resubscribeActiveSubscribers()

      case .next(let id, let payload):
        subscribers[id]?.continuation.yield(payload)

      case .error(let id, let errors):
        let record = subscribers.removeValue(forKey: id)
        record?.continuation.finish(throwing: Error.graphQLErrors(errors))

      case .complete(let id):
        let record = subscribers.removeValue(forKey: id)
        record?.continuation.finish()

      case .ping, .pong:
        break
      }
    } catch {
      // Unrecognized message — ignore for now
    }
  }

  // MARK: - Network Transport Protocol Conformance

  nonisolated public func send<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    fetchBehavior: Apollo.FetchBehavior,
    requestConfiguration: Apollo.RequestConfiguration
  ) throws -> AsyncThrowingStream<Apollo.GraphQLResponse<Subscription>, any Swift.Error> {
    return AsyncThrowingStream { continuation in
      let innerTask = Task {
        let (operationID, payloadStream) = await self.registerSubscriber(for: subscription)
        do {
          try await self.ensureConnected()
          try Task.checkCancellation()
          try await self.sendSubscribeMessage(operationID: operationID, subscription: subscription)

          for try await payload in payloadStream {
            let handler = JSONResponseParser.SingleResponseExecutionHandler<Subscription>(
              responseBody: payload,
              operationVariables: subscription.__variables
            )
            let parsedResult = try await handler.execute(includeCacheRecords: false)
            continuation.yield(parsedResult.result)
          }

          if Task.isCancelled {
            await self.cancelSubscription(operationID: operationID)
          }
          continuation.finish()

        } catch {
          await self.cancelSubscription(operationID: operationID)
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { @Sendable reason in
        guard case .cancelled = reason else { return }
        innerTask.cancel()
      }
    }
  }

  nonisolated public func send<Mutation: GraphQLMutation>(
    mutation: Mutation,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResponse<Mutation>, any Swift.Error> {
    throw Error.notImplemented
  }

  nonisolated public func send<Query: GraphQLQuery>(
    query: Query,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration
  ) throws
    -> AsyncThrowingStream<GraphQLResponse<Query>, any Swift.Error>
  {
    throw Error.notImplemented
  }

}

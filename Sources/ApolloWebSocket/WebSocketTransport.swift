@_spi(Execution) import Apollo
@_spi(Unsafe) import ApolloAPI
import Foundation

public actor WebSocketTransport: SubscriptionNetworkTransport, NetworkTransport {
  
  typealias OperationID = String
  
  public enum Error: Swift.Error {
    /// The received WebSocket message could not be parsed as a valid `graphql-transport-ws` message.
    case unrecognizedMessage
    /// The WebSocket connection was closed before the server acknowledged the connection.
    case connectionClosed
    /// The server sent one or more GraphQL errors for an operation.
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

    /// The request body creator used to build the JSON payload for `subscribe` messages.
    ///
    /// This is always called with `sendQueryDocument: true` and `autoPersistQuery: false`.
    /// The default ``DefaultRequestBodyCreator`` includes `clientAwarenessMetadata` in the
    /// payload when available.
    public var requestBodyCreator: any JSONRequestBodyCreator

    /// The payload to send on connection. Defaults to `nil`.
    public var connectingPayload: JSONEncodableDictionary?

    /// The ``OperationMessageIdCreator`` used to generate a unique message identifier per
    /// operation. Defaults to ``ApolloSequencedOperationMessageIdCreator``.
    public var operationMessageIdCreator: any OperationMessageIdCreator

    /// The interval at which the client sends ping messages to the server as a keepalive.
    ///
    /// Some servers require clients to send periodic pings and will drop the connection
    /// if they don't receive one within a certain timeframe.
    ///
    /// - A positive value (e.g. `20`) sends a ping every 20 seconds while connected.
    /// - A value of `nil` disables client-initiated pings (the default).
    ///
    /// Pings are only sent after `connection_ack` is received. The timer is stopped on
    /// disconnect or pause, and restarted on reconnect.
    ///
    /// Default: `nil` (disabled).
    public var pingInterval: TimeInterval?

    /// Metadata used by GraphOS Studio's
    /// [client awareness](https://www.apollographql.com/docs/graphos/platform/insights/client-segmentation)
    /// feature.
    ///
    /// When set, the client application name and version are sent as HTTP headers
    /// (`apollographql-client-name`, `apollographql-client-version`) on the WebSocket
    /// connection request.
    ///
    /// Default: `ClientAwarenessMetadata()` (includes Apollo library awareness headers).
    public var clientAwarenessMetadata: ClientAwarenessMetadata

    public init(
      reconnectionInterval: TimeInterval = -1,
      requestBodyCreator: any JSONRequestBodyCreator = DefaultRequestBodyCreator(),
      connectingPayload: JSONEncodableDictionary? = nil,
      operationMessageIdCreator: any OperationMessageIdCreator = ApolloSequencedOperationMessageIdCreator(),
      pingInterval: TimeInterval? = nil,
      clientAwarenessMetadata: ClientAwarenessMetadata = ClientAwarenessMetadata()
    ) {
      self.reconnectionInterval = reconnectionInterval
      self.requestBodyCreator = requestBodyCreator
      self.connectingPayload = connectingPayload
      self.operationMessageIdCreator = operationMessageIdCreator
      self.pingInterval = pingInterval
      self.clientAwarenessMetadata = clientAwarenessMetadata
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
    /// The connection was intentionally paused by the caller. The underlying WebSocket is
    /// closed, but subscription streams remain alive for seamless resumption.
    case paused
  }

  /// The delegate that receives lifecycle events from this transport.
  ///
  /// Delegate methods are `isolated` to this actor, meaning they execute within the
  /// transport's isolation domain. The transport awaits each delegate call before
  /// continuing its receive loop.
  public weak var delegate: (any WebSocketTransportDelegate)?

  /// Sets the delegate that receives lifecycle events from this transport.
  public func setDelegate(_ delegate: (any WebSocketTransportDelegate)?) {
    self.delegate = delegate
  }

  public let urlSession: WebSocketURLSession

  public let store: ApolloStore

  public private(set) var configuration: Configuration

  private var request: URLRequest

  private var connection: WebSocketConnection

  var connectionState: ConnectionState = .notStarted

  /// Tracks whether the transport has ever successfully connected. Used to distinguish
  /// initial connection from reconnection for delegate callbacks.
  private var hasBeenConnected = false

  private var subscriberRegistry: SubscriberRegistry

  private var connectionWaiters = ConnectionWaiterQueue()

  /// The task that periodically sends client-initiated ping messages.
  /// Created after `connection_ack` and cancelled on disconnect/pause.
  private var pingTimerTask: Task<Void, Never>?

  /// The number of active subscribers. Exposed for test assertions.
  var subscriberCount: Int { subscriberRegistry.count }

  public init(
    urlSession: WebSocketURLSession,
    store: ApolloStore,
    endpointURL: URL,
    configuration: Configuration = Configuration()
  ) throws {
    self.urlSession = urlSession
    self.store = store
    self.configuration = configuration
    self.request = try Self.createURLRequest(
      endpointURL: endpointURL,
      clientAwarenessMetadata: configuration.clientAwarenessMetadata
    )
    self.connection = WebSocketConnection(task: urlSession.webSocketTask(with: request))
    self.subscriberRegistry = SubscriberRegistry(
      operationMessageIdCreator: configuration.operationMessageIdCreator
    )
  }

  // MARK: - Request Setup

  private static func createURLRequest(
    endpointURL: URL,
    clientAwarenessMetadata: ClientAwarenessMetadata
  ) throws -> URLRequest {
    var request = URLRequest(url: endpointURL)

    request.setValue(Constants.headerWSProtocolValue, forHTTPHeaderField: Constants.headerWSProtocolName)

    clientAwarenessMetadata.applyHeaders(to: &request)

    return request
  }

  // MARK: - Connection Management

  /// Ensures the WebSocket connection is established before returning.
  ///
  /// Handles all connection states:
  /// - `notStarted`: Opens the connection and waits for `connection_ack`.
  /// - `connecting`: Waits for the in-progress connection to receive `connection_ack`.
  /// - `connected`: Returns immediately.
  /// - `disconnected`: Creates a fresh connection and waits for `connection_ack`.
  /// - `paused`: Waits for `resume()` to re-establish the connection.
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

    case .paused:
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
    /// Keeps a reference to the connection the the receive loop was opened on. If a reconnect occurs,
    /// `self.connection` will be a new connection and we should ignore disconnection events for this loop.
    let loopConnection = self.connection
    let connectionStream = self.connection.openConnection(
      connectingPayload: configuration.connectingPayload
    )

    Task {
      do {
        for try await message in connectionStream {
          didReceive(message: message)
        }

        guard self.connection === loopConnection else { return }
        await handleDisconnection()
      } catch {
        guard self.connection === loopConnection else { return }
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
  ///
  /// One-shot operations (queries and mutations) are always terminated immediately on
  /// disconnect — they should never be retried across a reconnection, as replaying a
  /// mutation could cause duplicate side effects.
  private func handleDisconnection(error: (any Swift.Error)? = nil) async {
    guard connectionState != .paused else { return }

    let wasConnected = (self.connectionState == .connected)
    self.connectionState = .disconnected
    stopPingTimer()

    delegate?.webSocketTransport(self, didDisconnectWithError: error)

    // Terminate one-shot operations (queries/mutations) immediately, regardless of
    // whether reconnection is enabled. Only subscriptions survive reconnection.
    subscriberRegistry.finishNonSubscriptions(throwing: error ?? Error.connectionClosed)

    if wasConnected && !subscriberRegistry.isEmpty && configuration.isReconnectEnabled {
      subscriberRegistry.markSubscriptionsReconnecting()
      await attemptReconnection()
    } else {
      connectionWaiters.failAll(with: error ?? Error.connectionClosed)
      if let error {
        subscriberRegistry.finishAll(reason: .error(error))
      } else {
        subscriberRegistry.finishAll(reason: .completed)
      }
    }
  }

  /// Attempts to reconnect after a disconnect by creating a new connection.
  ///
  /// Waits for `reconnectionInterval` (if > 0) before connecting. Subscriber continuations
  /// are kept alive — they will receive data from the new connection after reconnection
  /// succeeds. If the reconnection attempt itself fails, `startConnectionReceiveLoop` will
  /// detect that the state was never `connected` and terminate everything.
  private func attemptReconnection() async {
    let previousConnection = self.connection

    if configuration.reconnectionInterval > 0 {
      do {
        try await Task.sleep(nanoseconds: UInt64(configuration.reconnectionInterval * 1_000_000_000))
      } catch {
        // Sleep was cancelled — terminate everything
        subscriberRegistry.finishAll(reason: .cancelled)
        return
      }
    }

    // If the connection was replaced during the delay (e.g. by an explicit reconnection),
    // bail out — that reconnection already started a new receive loop.
    guard self.connection === previousConnection else { return }

    // If all subscribers were cancelled during the reconnection delay, no need to reconnect.
    guard !subscriberRegistry.isEmpty else {
      return
    }

    // If the transport was paused during the reconnection delay, don't reconnect.
    guard connectionState != .paused else { return }

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
          connectionWaiters.add(id: waiterID, continuation: continuation)
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
    connectionWaiters.cancel(id: id)
  }

  // MARK: - Client-Initiated Ping Keepalive

  /// Starts the periodic ping timer if `pingInterval` is configured.
  ///
  /// Spawns a task that sends a `ping` message at the configured interval. The task
  /// runs until cancelled (via ``stopPingTimer()``). Called after `connection_ack`.
  private func startPingTimer() {
    guard let interval = configuration.pingInterval, interval > 0 else { return }

    stopPingTimer()

    let connection = self.connection
    pingTimerTask = Task { [weak self] in
      let nanoseconds = UInt64(interval * 1_000_000_000)
      while !Task.isCancelled {
        do {
          try await Task.sleep(nanoseconds: nanoseconds)
        } catch {
          break
        }

        guard let _ = self, !Task.isCancelled else { break }

        guard let pingMessage = try? Message.Outgoing.ping(payload: nil).toWebSocketMessage() else {
          continue
        }
        connection.send(pingMessage)
      }
    }
  }

  /// Stops the periodic ping timer.
  private func stopPingTimer() {
    pingTimerTask?.cancel()
    pingTimerTask = nil
  }

  // MARK: - Runtime Configuration Updates

  /// Updates the HTTP headers used when creating new WebSocket connection requests.
  ///
  /// Headers are applied to the stored `URLRequest` and take effect on the next connection
  /// (including reconnections). The `Sec-WebSocket-Protocol` header is always preserved.
  ///
  /// - Parameters:
  ///   - headerValues: A dictionary of header field names to values. A `nil` value removes
  ///     the header field.
  ///   - reconnectIfConnected: If `true` and the transport is currently connected,
  ///     disconnects and reconnects with the updated headers.
  public func updateHeaderValues(
    _ headerValues: [String: String?],
    reconnectIfConnected: Bool = false
  ) {
    for (key, value) in headerValues {
      request.setValue(value, forHTTPHeaderField: key)
    }
    if reconnectIfConnected && connectionState == .connected {
      disconnectAndReconnect()
    }
  }

  /// Updates the `connectingPayload` dictionary sent in the `connection_init` message.
  ///
  /// The payload takes effect on the next connection (including reconnections).
  ///
  /// - Parameters:
  ///   - payload: The new connecting payload dictionary, or `nil` to clear it.
  ///   - reconnectIfConnected: If `true` and the transport is currently connected,
  ///     disconnects and reconnects with the updated payload.
  public func updateConnectingPayload(
    _ payload: JSONEncodableDictionary?,
    reconnectIfConnected: Bool = false
  ) {
    configuration.connectingPayload = payload
    if reconnectIfConnected && connectionState == .connected {
      disconnectAndReconnect()
    }
  }

  /// Disconnects the current WebSocket connection and immediately starts a new one.
  ///
  /// Replaces the connection, which invalidates the old receive loop (it will see that
  /// `self.connection` no longer matches and exit). Active subscribers will be resubscribed
  /// when the new `connection_ack` arrives.
  private func disconnectAndReconnect() {
    connection = WebSocketConnection(task: urlSession.webSocketTask(with: request))
    connectionState = .connecting
    startConnectionReceiveLoop()
  }

  // MARK: - Pause / Resume

  /// Gracefully pauses the WebSocket connection without terminating subscriber streams.
  ///
  /// The underlying WebSocket task is closed and the transport transitions to a `paused` state.
  /// Active subscription streams remain alive and will automatically be re-subscribed when
  /// ``resume()`` is called and the new connection is acknowledged by the server.
  ///
  /// Auto-reconnection is suppressed while paused. One-shot operations (queries and mutations)
  /// that are in-flight are terminated immediately, as they cannot safely survive a
  /// connection interruption.
  ///
  /// This method is a no-op if the transport has not yet started or is already paused.
  ///
  /// Typical usage:
  /// ```swift
  /// // App entering background
  /// await transport.pause()
  ///
  /// // App returning to foreground
  /// await transport.resume()
  /// ```
  public func pause() {
    switch connectionState {
    case .notStarted, .paused:
      return
    case .connected, .connecting, .disconnected:
      break
    }

    connectionState = .paused
    stopPingTimer()

    // Terminate one-shot operations — they cannot survive a pause because replaying
    // a mutation could cause duplicate side effects.
    subscriberRegistry.finishNonSubscriptions(throwing: Error.connectionClosed)

    // Mark surviving subscriptions as paused so consumers can observe the state.
    subscriberRegistry.markSubscriptionsPaused()

    // Close the underlying WebSocket task. This causes the receive loop's stream to
    // end, at which point the loop checks connectionState, sees `.paused`, and exits
    // without triggering auto-reconnection or finishing subscriber streams.
    connection.close()
  }

  /// Re-establishes the WebSocket connection after a ``pause()``, or opens a new connection
  /// from a stopped or disconnected state.
  ///
  /// Creates a fresh WebSocket task and begins the connection handshake. Once the server
  /// sends `connection_ack`, all surviving subscription streams are automatically
  /// re-subscribed on the new connection.
  ///
  /// This method is a no-op if the transport is already connecting or connected.
  ///
  /// Can also be used to eagerly open a connection before any ``subscribe`` calls:
  /// ```swift
  /// let transport = try WebSocketTransport(...)
  /// await transport.resume()
  /// // Connection is now being established; subsequent subscribe() calls
  /// // will use this connection without additional setup delay.
  /// ```
  public func resume() {
    switch connectionState {
    case .notStarted:
      connectionState = .connecting
      startConnectionReceiveLoop()

    case .paused, .disconnected:
      connection = WebSocketConnection(task: urlSession.webSocketTask(with: request))
      connectionState = .connecting
      startConnectionReceiveLoop()

    case .connecting, .connected:
      return
    }
  }

  // MARK: - Subscriber Management

  private func registerSubscriber(
    for operation: any GraphQLOperation,
    stateStorage: SubscriptionStateStorage? = nil
  ) -> (OperationID, AsyncThrowingStream<JSONObject, any Swift.Error>) {
    subscriberRegistry.register(for: operation, stateStorage: stateStorage)
  }

  /// Cancels a subscription from the client side. Removes the subscriber from the registry,
  /// finishes its payload stream, and sends a `complete` message to the server.
  /// No-ops if the subscriber was already removed (e.g. server already completed it).
  private func cancelSubscription(operationID: OperationID) {
    guard subscriberRegistry.finish(operationID, reason: .cancelled) else { return }

    let message = Message.Outgoing.complete(id: operationID)
    if let wsMessage = try? message.toWebSocketMessage() {
      connection.send(wsMessage)
    }
  }

  private func sendSubscribeMessage<Operation: GraphQLOperation>(
    operationID: OperationID,
    operation: Operation
  ) throws {
    let payload = configuration.requestBodyCreator.requestBody(
      for: operation,
      sendQueryDocument: true,
      autoPersistQuery: false
    )
    let message = Message.Outgoing.subscribe(id: operationID, payload: payload)
    connection.send(try message.toWebSocketMessage())
    subscriberRegistry.markSubscribed(operationID)
  }

  /// Re-sends subscribe messages for all subscribers that were previously subscribed.
  ///
  /// Called after a successful reconnection (on `connection_ack`). Only re-subscribes entries
  /// with status `.subscribed` — entries with status `.pending` are new subscribers whose
  /// inner tasks will send their own subscribe message after `ensureConnected()` returns.
  private func resubscribeActiveSubscribers() {
    for (id, operation) in subscriberRegistry.activeSubscriptions {
      do {
        try sendSubscribeMessage(operationID: id, operation: operation)
      } catch {
        // Defensive: if re-subscribe fails (e.g. missing query document — shouldn't happen
        // since the first subscribe succeeded), terminate this individual subscriber.
        subscriberRegistry.finish(id, reason: .error(error))
      }
    }
  }

  // MARK: - Processing Messages

  private func didReceive(message: URLSessionWebSocketTask.Message) {
    do {
      let incoming = try Message.Incoming.from(message)

      switch incoming {
      case .connectionAck:
        let isReconnect = hasBeenConnected
        self.connectionState = .connected
        self.hasBeenConnected = true
        connectionWaiters.resumeAll()
        resubscribeActiveSubscribers()
        startPingTimer()

        if isReconnect {
          delegate?.webSocketTransportDidReconnect(self)
        } else {
          delegate?.webSocketTransportDidConnect(self)
        }

      case .next(let id, let payload):
        subscriberRegistry.yield(payload, for: id)

      case .error(let id, let errors):
        subscriberRegistry.finish(id, reason: .error(Error.graphQLErrors(errors)))

      case .complete(let id):
        subscriberRegistry.finish(id, reason: .completed)

      case .ping(let payload):
        // Per the graphql-transport-ws protocol, a pong must be sent in response
        // to a ping "as soon as possible".
        if let pongMessage = try? Message.Outgoing.pong(payload: nil).toWebSocketMessage() {
          connection.send(pongMessage)
        }
        delegate?.webSocketTransport(self, didReceivePingWithPayload: payload)

      case .pong(let payload):
        delegate?.webSocketTransport(self, didReceivePongWithPayload: payload)
      }
    } catch {
      subscriberRegistry.finishAll(reason: .error(Error.unrecognizedMessage))
    }
  }

  // MARK: - Operation Execution

  /// Sends a GraphQL operation over the WebSocket connection and returns a stream of responses.
  ///
  /// This is the shared implementation for queries, mutations, and subscriptions. All three
  /// use the same `subscribe` message type in the `graphql-transport-ws` protocol. The server
  /// replies with `next` (results) and `complete` (stream end) messages.
  private nonisolated func sendOperation<Operation: GraphQLOperation>(
    operation: Operation
  ) -> AsyncThrowingStream<GraphQLResponse<Operation>, any Swift.Error> {
    AsyncThrowingStream { continuation in
      let innerTask = Task {
        let (operationID, payloadStream) = await self.registerSubscriber(for: operation)
        do {
          try await self.ensureConnected()
          try Task.checkCancellation()
          try await self.sendSubscribeMessage(operationID: operationID, operation: operation)

          for try await payload in payloadStream {
            let handler = JSONResponseParser.SingleResponseExecutionHandler<Operation>(
              responseBody: payload,
              operationVariables: operation.__variables
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

  /// Sends a GraphQL subscription over the WebSocket connection and returns a
  /// ``SubscriptionStream`` that tracks the subscription's lifecycle state.
  ///
  /// This method creates a ``SubscriptionStateStorage`` that is updated as the subscription
  /// moves through its lifecycle: pending → active → (reconnecting/paused) → stopped.
  private nonisolated func sendSubscription<Operation: GraphQLSubscription>(
    subscription: Operation
  ) -> SubscriptionStream<GraphQLResponse<Operation>> {
    let stateStorage = SubscriptionStateStorage()

    let stream = AsyncThrowingStream<GraphQLResponse<Operation>, any Swift.Error> { continuation in
      let innerTask = Task {
        let (operationID, payloadStream) = await self.registerSubscriber(
          for: subscription,
          stateStorage: stateStorage
        )
        do {
          try await self.ensureConnected()
          try Task.checkCancellation()
          try await self.sendSubscribeMessage(operationID: operationID, operation: subscription)

          for try await payload in payloadStream {
            let handler = JSONResponseParser.SingleResponseExecutionHandler<Operation>(
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

    return SubscriptionStream(stream: stream, stateProvider: { stateStorage.state })
  }

  // MARK: - Network Transport Protocol Conformance

  nonisolated public func send<Query: GraphQLQuery>(
    query: Query,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResponse<Query>, any Swift.Error> {
    sendOperation(operation: query)
  }

  nonisolated public func send<Mutation: GraphQLMutation>(
    mutation: Mutation,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResponse<Mutation>, any Swift.Error> {
    sendOperation(operation: mutation)
  }

  nonisolated public func send<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    fetchBehavior: Apollo.FetchBehavior,
    requestConfiguration: Apollo.RequestConfiguration
  ) throws -> SubscriptionStream<Apollo.GraphQLResponse<Subscription>> {
    sendSubscription(subscription: subscription)
  }

}

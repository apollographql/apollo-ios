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

  public let urlSession: WebSocketURLSession

  public let store: ApolloStore

  private let request: URLRequest

  private var connection: WebSocketConnection

  var connectionState: ConnectionState = .notStarted

  private var nextOperationID: OperationID = 1

  /// Active subscribers keyed by operation ID. Each continuation receives raw JSON payloads
  /// from incoming `next` messages that are then parsed into typed `GraphQLResponse`s
  /// per-subscriber.
  var subscribers: [OperationID: AsyncThrowingStream<JSONObject, any Swift.Error>.Continuation] = [:]

  /// Continuations of callers waiting for the connection to reach the `connected` state.
  /// Populated only while `connectionState == .connecting`. Resumed when `connectionAck` arrives
  /// or failed if the connection stream terminates before acknowledgement.
  /// Keyed by UUID so individual waiters can be cancelled via `withTaskCancellationHandler`.
  private var connectionWaiters: [UUID: CheckedContinuation<Void, any Swift.Error>] = [:]

  public init(
    urlSession: WebSocketURLSession,
    store: ApolloStore,
    endpointURL: URL
  ) throws {
    self.urlSession = urlSession
    self.store = store
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
  /// When the stream terminates (normally or with error), transitions to `disconnected`,
  /// fails any pending connection waiters, and finishes all subscribers.
  private func startConnectionReceiveLoop() {
    let connectionStream = self.connection.openConnection()

    Task {
      do {
        for try await message in connectionStream {
          didReceive(message: message)
        }
        self.connectionState = .disconnected
        failConnectionWaiters(with: Error.connectionClosed)
        finishAllSubscribers()

      } catch is CancellationError {
        self.connectionState = .disconnected
        failConnectionWaiters(with: Error.connectionClosed)
        finishAllSubscribers()

      } catch {
        self.connectionState = .disconnected
        failConnectionWaiters(with: error)
        finishAllSubscribers(throwing: error)
      }
    }
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

  private func registerSubscriber() -> (OperationID, AsyncThrowingStream<JSONObject, any Swift.Error>) {
    let id = nextOperationID
    nextOperationID += 1

    let (stream, continuation) = AsyncThrowingStream<JSONObject, any Swift.Error>.makeStream()
    subscribers[id] = continuation

    return (id, stream)
  }

  /// Cancels a subscription from the client side. Removes the subscriber from the registry,
  /// finishes its payload stream, and sends a `complete` message to the server.
  /// No-ops if the subscriber was already removed (e.g. server already completed it).
  private func cancelSubscription(operationID: OperationID) {
    guard let continuation = subscribers.removeValue(forKey: operationID) else { return }
    continuation.finish()

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
  }

  private func finishAllSubscribers(throwing error: (any Swift.Error)? = nil) {
    let active = subscribers
    subscribers.removeAll()
    for (_, continuation) in active {
      continuation.finish(throwing: error)
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

      case .next(let id, let payload):
        subscribers[id]?.yield(payload)

      case .error(let id, let errors):
        // TODO: Forward errors to subscriber
        _ = errors
        _ = id

      case .complete(let id):
        let continuation = subscribers.removeValue(forKey: id)
        continuation?.finish()

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
        let (operationID, payloadStream) = await self.registerSubscriber()
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

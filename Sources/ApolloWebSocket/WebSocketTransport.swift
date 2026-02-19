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

  private var connectionState: ConnectionState = .notStarted

  private var nextOperationID: OperationID = 1

  /// Active subscribers keyed by operation ID. Each continuation receives raw JSON payloads
  /// from incoming `next` messages that are then parsed into typed `GraphQLResponse`s
  /// per-subscriber.
  private var subscribers: [OperationID: AsyncThrowingStream<JSONObject, any Swift.Error>.Continuation] = [:]

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

  private func startWebSocketConnection() throws {
    guard case .notStarted = self.connectionState else {
      return
    }
    self.connectionState = .connecting

    let connectionStream = self.connection.openConnection()

    Task {
      do {
        for try await message in connectionStream {
          didReceive(message: message)
        }
        finishAllSubscribers()
      } catch is CancellationError {
        self.connectionState = .disconnected
        finishAllSubscribers()
      } catch {
        self.connectionState = .disconnected
        finishAllSubscribers(throwing: error)
      }
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

  private func sendSubscribeMessage<Subscription: GraphQLSubscription>(
    operationID: OperationID,
    subscription: Subscription
  ) {
    let payload = SubscribePayload(
      operationName: Subscription.operationName,
      query: Subscription.definition?.queryDocument ?? "",
      variables: subscription.__variables,
      extensions: nil
    )
    let message = Message.Outgoing.subscribe(id: operationID, payload: payload)
    do {
      connection.send(try message.toWebSocketMessage())
    } catch {
      // Serialization error — subscriber will be notified when connection drops
    }
  }

  private func finishAllSubscribers(throwing error: (any Swift.Error)? = nil) {
    for (_, continuation) in subscribers {
      continuation.finish(throwing: error)
    }
    subscribers.removeAll()
  }

  // MARK: - Processing Messages

  private func didReceive(message: URLSessionWebSocketTask.Message) {
    do {
      let incoming = try Message.Incoming.from(message)

      switch incoming {
      case .connectionAck:
        self.connectionState = .connected

      case .next(let id, let payload):
        subscribers[id]?.yield(payload)

      case .error(let id, let errors):
        // TODO: Forward errors to subscriber
        _ = errors
        _ = id

      case .complete(let id):
        subscribers[id]?.finish()
        subscribers.removeValue(forKey: id)

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
      Task {
        do {
          let (operationID, payloadStream) = await self.registerSubscriber()
          try await self.startWebSocketConnection()
          await self.sendSubscribeMessage(operationID: operationID, subscription: subscription)

          for try await payload in payloadStream {
            let handler = JSONResponseParser.SingleResponseExecutionHandler<Subscription>(
              responseBody: payload,
              operationVariables: subscription.__variables
            )
            let parsedResult = try await handler.execute(includeCacheRecords: false)
            continuation.yield(parsedResult.result)
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
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

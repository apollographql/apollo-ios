import Apollo
import ApolloAPI
import Foundation

public actor WebSocketTransport: SubscriptionNetworkTransport, NetworkTransport {

  public enum Error: Swift.Error {
    /// WebSocketTransport has not yet been implemented for Apollo iOS 2.0. This will be implemented in a future
    /// release.
    case notImplemented
    case invalidURL(url: URL)
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
      } catch {
//        print(error)
        self.connectionState = .disconnected
      }
    }
  }

  // MARK: - Processing Messages

  private func didReceive(message: URLSessionWebSocketTask.Message) {
    self.connectionState = .connected
  }

  // MARK: - Network Transport Protocol Conformance

  nonisolated public func send<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    fetchBehavior: Apollo.FetchBehavior,
    requestConfiguration: Apollo.RequestConfiguration
  ) throws -> AsyncThrowingStream<Apollo.GraphQLResponse<Subscription>, any Swift.Error> {
    Task {
      try await startWebSocketConnection()
    }

    return AsyncThrowingStream {
      try await Task.sleep(nanoseconds: 5_000_000_000)

      return nil
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

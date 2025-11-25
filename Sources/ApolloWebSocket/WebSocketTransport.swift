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
    static let headerWSUpgradeName = "Upgrade"
    static let headerWSUpgradeValue = "websocket"
    static let headerWSHostName = "Host"
    static let headerWSConnectionName = "Connection"
    static let headerWSConnectionValue = "Upgrade"
    static let headerWSProtocolName = "Sec-WebSocket-Protocol"
    static let headerWSVersionName = "Sec-WebSocket-Version"
    static let headerWSVersionValue = "13"
    //    static let headerWSExtensionName   = "Sec-WebSocket-Extensions"
    static let headerWSKeyName = "Sec-WebSocket-Key"
    static let headerOriginName = "Origin"
    //    static let headerWSAcceptName      = "Sec-WebSocket-Accept"
    //    static let BUFFER_MAX              = 4096
    //    static let FinMask: UInt8          = 0x80
    //    static let OpCodeMask: UInt8       = 0x0F
    //    static let RSVMask: UInt8          = 0x70
    //    static let RSV1Mask: UInt8         = 0x40
    //    static let MaskMask: UInt8         = 0x80
    //    static let PayloadLenMask: UInt8   = 0x7F
    //    static let MaxFrameSize: Int       = 32
    //    static let httpSwitchProtocolCode  = 101
    static let supportedSSLSchemes = ["wss", "https"]
    //    static let WebsocketDisconnectionErrorKeyName = "WebsocketDisconnectionErrorKeyName"
    //
    //    struct Notifications {
    //      static let WebsocketDidConnect = "WebsocketDidConnectNotification"
    //      static let WebsocketDidDisconnect = "WebsocketDidDisconnectNotification"
    //    }
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
    endpointURL: URL,
    protocol: WebSocketProtocol
  ) throws {
    self.urlSession = urlSession
    self.store = store
    self.request = try Self.createURLRequest(endpointURL: endpointURL, protocol: `protocol`)
    self.connection = WebSocketConnection(task: urlSession.webSocketTask(with: request))
  }

  // MARK: - Request Setup

  private static func createURLRequest(
    endpointURL: URL,
    protocol: WebSocketProtocol
  ) throws -> URLRequest {
    var request = URLRequest(url: endpointURL)
    //    request.httpMethod = "POST"

    let port = try webSocketPort(for: endpointURL)

    request.setValue(
      Constants.headerWSUpgradeValue,
      forHTTPHeaderField: Constants.headerWSUpgradeName
    )
    request.setValue(
      Constants.headerWSConnectionValue,
      forHTTPHeaderField: Constants.headerWSConnectionName
    )
    let headerSecKey = generateWebSocketKey()
    request.setValue(
      Constants.headerWSVersionValue,
      forHTTPHeaderField: Constants.headerWSVersionName
    )
    request.setValue(
      headerSecKey,
      forHTTPHeaderField: Constants.headerWSKeyName
    )

    if let host = endpointURL.host,
      request.allHTTPHeaderFields?[Constants.headerWSHostName] == nil
    {
      request.setValue("\(host):\(port)", forHTTPHeaderField: Constants.headerWSHostName)
    }

    if request.value(forHTTPHeaderField: Constants.headerOriginName) == nil {
      var origin = endpointURL.absoluteString
      if let hostUrl = URL(string: "/", relativeTo: endpointURL) {
        origin = hostUrl.absoluteString
        origin.remove(at: origin.index(before: origin.endIndex))
      }
      request.setValue(origin, forHTTPHeaderField: Constants.headerOriginName)
    }

    request.setValue(`protocol`.description, forHTTPHeaderField: Constants.headerWSProtocolName)

    return request
  }

  private static func webSocketPort(for endpointURL: URL) throws -> Int {
    if let port = endpointURL.port {
      return port
    }

    guard let scheme = endpointURL.scheme else {
      throw Error.invalidURL(url: endpointURL)
    }

    if Constants.supportedSSLSchemes.contains(endpointURL.scheme!) {
      return 443
    } else {
      return 80
    }
  }

  /// Generate a WebSocket key as needed in RFC.
  private static func generateWebSocketKey() -> String {
    var key = ""
    let seed = 16
    for _ in 0..<seed {
      let uni = UnicodeScalar(UInt32(97 + arc4random_uniform(25)))
      key += "\(Character(uni!))"
    }
    let data = key.data(using: String.Encoding.utf8)
    let baseKey = data?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    return baseKey!
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
        print(error)
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

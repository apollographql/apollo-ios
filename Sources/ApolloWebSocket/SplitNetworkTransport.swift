#if !COCOAPODS
import Apollo
#endif

/// A network transport that sends subscriptions using one `NetworkTransport` and other requests using another `NetworkTransport`. Ideal for sending subscriptions via a web socket but everything else via HTTP. 
public class SplitNetworkTransport {
  private let httpNetworkTransport: NetworkTransport
  private let webSocketNetworkTransport: NetworkTransport
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - httpNetworkTransport: A `NetworkTransport` to use for non-subscription requests. Should generally be a `HTTPNetworkTransport` or something similar.
  ///   - webSocketNetworkTransport: A `NetworkTransport` to use for subscription requests. Should generally be a `WebSocketTransport` or something similar.
  public init(httpNetworkTransport: NetworkTransport, webSocketNetworkTransport: NetworkTransport) {
    self.httpNetworkTransport = httpNetworkTransport
    self.webSocketNetworkTransport = webSocketNetworkTransport
  }
}

// MARK: - NetworkTransport conformance

extension SplitNetworkTransport: NetworkTransport {
  
  public func send<Operation>(operation: Operation, completionHandler: @escaping (Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable {
    if operation.operationType == .subscription {
      return webSocketNetworkTransport.send(operation: operation, completionHandler: completionHandler)
    } else {
      return httpNetworkTransport.send(operation: operation, completionHandler: completionHandler)
    }
  }
}

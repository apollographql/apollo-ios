#if !COCOAPODS
import Apollo
#endif

/// A network transport that sends subscriptions using one `NetworkTransport` and other requests using another `NetworkTransport`. Ideal for sending subscriptions via a web socket but everything else via HTTP.
public class SplitNetworkTransport {
  private let httpNetworkTransport: UploadingNetworkTransport
  private let webSocketNetworkTransport: NetworkTransport

  public var clientName: String {
    let httpName = self.httpNetworkTransport.clientName
    let websocketName = self.webSocketNetworkTransport.clientName
    if httpName == websocketName {
      return httpName
    } else {
      return "SPLIT_HTTPNAME_\(httpName)_WEBSOCKETNAME_\(websocketName)"
    }
  }

  public var clientVersion: String {
    let httpVersion = self.httpNetworkTransport.clientVersion
    let websocketVersion = self.webSocketNetworkTransport.clientVersion
    if httpVersion == websocketVersion {
      return httpVersion
    } else {
      return "SPLIT_HTTPVERSION_\(httpVersion)_WEBSOCKETVERSION_\(websocketVersion)"
    }
  }
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - httpNetworkTransport: An `UploadingNetworkTransport` to use for non-subscription requests. Should generally be a `HTTPNetworkTransport` or something similar.
  ///   - webSocketNetworkTransport: A `NetworkTransport` to use for subscription requests. Should generally be a `WebSocketTransport` or something similar.
  public init(httpNetworkTransport: UploadingNetworkTransport, webSocketNetworkTransport: NetworkTransport) {
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

// MARK: - UploadingNetworkTransport conformance

extension SplitNetworkTransport: UploadingNetworkTransport {

  public func upload<Operation>(operation: Operation,
                                files: [GraphQLFile],
                                completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable {
    return httpNetworkTransport.upload(operation: operation,
                                       files: files,
                                       completionHandler: completionHandler)
  }
}

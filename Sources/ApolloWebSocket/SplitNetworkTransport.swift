import Foundation
#if !COCOAPODS
import Apollo
#endif

/// A network transport that sends subscriptions using one `NetworkTransport` and other requests using another `NetworkTransport`. Ideal for sending subscriptions via a web socket but everything else via HTTP.
public class SplitNetworkTransport {
  private let uploadingNetworkTransport: UploadingNetworkTransport
  private let webSocketNetworkTransport: NetworkTransport

  public var clientName: String {
    let httpName = self.uploadingNetworkTransport.clientName
    let websocketName = self.webSocketNetworkTransport.clientName
    if httpName == websocketName {
      return httpName
    } else {
      return "SPLIT_HTTPNAME_\(httpName)_WEBSOCKETNAME_\(websocketName)"
    }
  }

  public var clientVersion: String {
    let httpVersion = self.uploadingNetworkTransport.clientVersion
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
  ///   - uploadingNetworkTransport: An `UploadingNetworkTransport` to use for non-subscription requests. Should generally be a `RequestChainNetworkTransport` or something similar.
  ///   - webSocketNetworkTransport: A `NetworkTransport` to use for subscription requests. Should generally be a `WebSocketTransport` or something similar.
  public init(uploadingNetworkTransport: UploadingNetworkTransport, webSocketNetworkTransport: NetworkTransport) {
    self.uploadingNetworkTransport = uploadingNetworkTransport
    self.webSocketNetworkTransport = webSocketNetworkTransport
  }
}

// MARK: - NetworkTransport conformance

extension SplitNetworkTransport: NetworkTransport {

  public func send<Operation: GraphQLOperation>(operation: Operation,
                                                cachePolicy: CachePolicy,
                                                contextIdentifier: UUID? = nil,
                                                callbackQueue: DispatchQueue = .main,
                                                completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable {
    if operation.operationType == .subscription {
      return webSocketNetworkTransport.send(operation: operation,
                                            cachePolicy: cachePolicy,
                                            contextIdentifier: contextIdentifier,
                                            callbackQueue: callbackQueue,
                                            completionHandler: completionHandler)
    } else {
      return uploadingNetworkTransport.send(operation: operation,
                                            cachePolicy: cachePolicy,
                                            contextIdentifier: contextIdentifier,
                                            callbackQueue: callbackQueue,
                                            completionHandler: completionHandler)
    }
  }
}

// MARK: - UploadingNetworkTransport conformance

extension SplitNetworkTransport: UploadingNetworkTransport {

  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    callbackQueue: DispatchQueue = .main,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable {
    return uploadingNetworkTransport.upload(operation: operation,
                                            files: files,
                                            callbackQueue: callbackQueue,
                                            completionHandler: completionHandler)
  }
}

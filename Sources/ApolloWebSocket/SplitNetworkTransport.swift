import Foundation
#if !COCOAPODS
import Apollo
import ApolloAPI
#endif

/// A network transport that sends subscriptions using one `NetworkTransport` and other requests using another `NetworkTransport`. Ideal for sending subscriptions via a web socket but everything else via HTTP.
public class SplitNetworkTransport {
  private let uploadingNetworkTransport: any UploadingNetworkTransport
  private let webSocketNetworkTransport: any NetworkTransport

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
  public init(uploadingNetworkTransport: any UploadingNetworkTransport, webSocketNetworkTransport: any NetworkTransport) {
    self.uploadingNetworkTransport = uploadingNetworkTransport
    self.webSocketNetworkTransport = webSocketNetworkTransport
  }
}

// MARK: - NetworkTransport conformance

extension SplitNetworkTransport: NetworkTransport {

  public func send<Operation: GraphQLOperation>(operation: Operation,
                                                cachePolicy: CachePolicy,
                                                contextIdentifier: UUID? = nil,
                                                context: (any RequestContext)? = nil,
                                                callbackQueue: DispatchQueue = .main,
                                                completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void) -> any Cancellable {
    if Operation.operationType == .subscription {
      return webSocketNetworkTransport.send(operation: operation,
                                            cachePolicy: cachePolicy,
                                            contextIdentifier: contextIdentifier,
                                            context: context,
                                            callbackQueue: callbackQueue,
                                            completionHandler: completionHandler)
    } else {
      return uploadingNetworkTransport.send(operation: operation,
                                            cachePolicy: cachePolicy,
                                            contextIdentifier: contextIdentifier,
                                            context: context,
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
    context: (any RequestContext)?,
    callbackQueue: DispatchQueue = .main,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void) -> any Cancellable {
    return uploadingNetworkTransport.upload(operation: operation,
                                            files: files,
                                            context: context,
                                            callbackQueue: callbackQueue,
                                            completionHandler: completionHandler)
  }
}

import Foundation

#if !COCOAPODS
  import Apollo
  import ApolloAPI
#endif

#warning(
  """
  TODO: This is messy. Why is http network transport called "uploadingNetworkTransport"?
  Websocket transport should be typesafe to a protocol that guaruntees it supports web sockets/ subscriptions
  """
)
/// A network transport that sends subscriptions using one `NetworkTransport` and other requests using another `NetworkTransport`. Ideal for sending subscriptions via a web socket but everything else via HTTP.
public final class SplitNetworkTransport: Sendable {
  private let uploadingNetworkTransport: any UploadingNetworkTransport
  private let webSocketNetworkTransport: any SubscriptionNetworkTransport

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - uploadingNetworkTransport: An `UploadingNetworkTransport` to use for non-subscription requests. Should generally be a `RequestChainNetworkTransport` or something similar.
  ///   - webSocketNetworkTransport: A `NetworkTransport` to use for subscription requests. Should generally be a `WebSocketTransport` or something similar.
  public init(
    uploadingNetworkTransport: any UploadingNetworkTransport,
    webSocketNetworkTransport: any SubscriptionNetworkTransport
  ) {
    self.uploadingNetworkTransport = uploadingNetworkTransport
    self.webSocketNetworkTransport = webSocketNetworkTransport
  }
}

// MARK: - NetworkTransport conformance

extension SplitNetworkTransport: NetworkTransport {

  public func send<Query>(
    query: Query,
    cachePolicy: CachePolicy
  ) throws -> AsyncThrowingStream<GraphQLResult<Query.Data>, any Error> where Query: GraphQLQuery {
    return try uploadingNetworkTransport.send(
      query: query,
      cachePolicy: cachePolicy
    )
  }

  public func send<Mutation>(
    mutation: Mutation,
    cachePolicy: CachePolicy
  ) throws -> AsyncThrowingStream<GraphQLResult<Mutation.Data>, any Error> where Mutation: GraphQLMutation {
    return try uploadingNetworkTransport.send(
      mutation: mutation,
      cachePolicy: cachePolicy
    )
  }
}

// MARK: - SubscriptionNetworkTransport conformance

extension SplitNetworkTransport: SubscriptionNetworkTransport {
  public func send<Subscription>(
    subscription: Subscription,
    cachePolicy: CachePolicy
  ) throws -> AsyncThrowingStream<GraphQLResult<Subscription.Data>, any Error> where Subscription: GraphQLSubscription {
    return try webSocketNetworkTransport.send(
      subscription: subscription,
      cachePolicy: cachePolicy
    )
  }
}

// MARK: - UploadingNetworkTransport conformance

extension SplitNetworkTransport: UploadingNetworkTransport {

  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile]
  ) throws -> AsyncThrowingStream<GraphQLResult<Operation.Data>, any Error> {
    return try uploadingNetworkTransport.upload(
      operation: operation,
      files: files
    )
  }
}

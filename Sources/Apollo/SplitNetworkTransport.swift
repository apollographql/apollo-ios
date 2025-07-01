import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

/// A network transport that sends allows you to use different `NetworkTransport` types for each operation type.
///
/// This can be used, for example, to send subscriptions via a web socket transport but everything else via HTTP.
public final class SplitNetworkTransport<
  QueryTransport: NetworkTransport,
  MutationTransport: NetworkTransport,
  SubscriptionTransport: Sendable,
  UploadTransport: Sendable
>: NetworkTransport, Sendable {

  private let queryTransport: QueryTransport
  private let mutationTransport: MutationTransport
  private let subscriptionTransport: SubscriptionTransport
  private let uploadTransport: UploadTransport

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - uploadingNetworkTransport: An `UploadingNetworkTransport` to use for non-subscription requests. Should generally be a `RequestChainNetworkTransport` or something similar.
  ///   - webSocketNetworkTransport: A `NetworkTransport` to use for subscription requests. Should generally be a `WebSocketTransport` or something similar.
  public init(
    queryTransport: QueryTransport,
    mutationTransport: MutationTransport,
    subscriptionTransport: SubscriptionTransport = Void(),
    uploadTransport: UploadTransport = Void(),
  ) {
    self.queryTransport = queryTransport
    self.mutationTransport = mutationTransport
    self.subscriptionTransport = subscriptionTransport
    self.uploadTransport = uploadTransport
  }

  // MARK: - NetworkTransport conformance

  public func send<Query: GraphQLQuery>(
    query: Query,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResult<Query>, any Error> {
    return try queryTransport.send(
      query: query,
      fetchBehavior: fetchBehavior,
      requestConfiguration: requestConfiguration
    )
  }

  public func send<Mutation: GraphQLMutation>(
    mutation: Mutation,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResult<Mutation>, any Error> {
    return try mutationTransport.send(
      mutation: mutation,
      requestConfiguration: requestConfiguration
    )
  }
}

// MARK: - SubscriptionNetworkTransport conformance

extension SplitNetworkTransport: SubscriptionNetworkTransport
where SubscriptionTransport: SubscriptionNetworkTransport {

  public func send<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResult<Subscription>, any Error> {
    return try subscriptionTransport.send(
      subscription: subscription,
      fetchBehavior: fetchBehavior,
      requestConfiguration: requestConfiguration
    )
  }
}

// MARK: - UploadingNetworkTransport conformance

extension SplitNetworkTransport: UploadingNetworkTransport where UploadTransport: UploadingNetworkTransport {

  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResult<Operation>, any Error> {
    return try uploadTransport.upload(
      operation: operation,
      files: files,
      requestConfiguration: requestConfiguration
    )
  }
}

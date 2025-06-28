import Foundation

#if !COCOAPODS
  import Apollo
  import ApolloAPI
#endif

public final class WebSocketTransport: SubscriptionNetworkTransport {

  public enum Error: Swift.Error {
    case notImplemented
  }

  public func send<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    fetchBehavior: Apollo.FetchBehavior,
    requestConfiguration: Apollo.RequestConfiguration
  ) throws -> AsyncThrowingStream<Apollo.GraphQLResult<Subscription.Data>, any Swift.Error> {
    throw Error.notImplemented
  }

}

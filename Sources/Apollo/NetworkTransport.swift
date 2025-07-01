import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

/// A network transport is responsible for sending GraphQL operations to a server.
public protocol NetworkTransport: AnyObject, Sendable {

  /// Send a GraphQL operation to a server and return a response.
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - fetchBehavior: The `FetchBehavior` to use for this request.
  ///                    Determines if fetching will include cache/network fetches.
  ///   - requestConfiguration: A configuration used to configure per-request behaviors for this request
  /// - Returns: A stream of `GraphQLResult`s for each response.
  func send<Query: GraphQLQuery>(
    query: Query,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResult<Query>, any Error>

  func send<Mutation: GraphQLMutation>(
    mutation: Mutation,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResult<Mutation>, any Error>

}

// MARK: -

public protocol SubscriptionNetworkTransport {

  func send<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResult<Subscription>, any Error>

}

// MARK: -

/// A network transport which can also handle uploads of files.
public protocol UploadingNetworkTransport {

  /// Uploads the given files with the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to send
  ///   - files: An array of `GraphQLFile` objects to send.
  ///   - requestConfiguration: A configuration used to configure per-request behaviors for this request
  /// - Returns: A stream of `GraphQLResult`s for each response.
  func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResult<Operation>, any Error>
}

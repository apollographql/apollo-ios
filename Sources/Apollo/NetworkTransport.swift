import Foundation
import ApolloAPI

/// A protocol for a type that is responsible for sending GraphQL query and mutation operations to a server.
///
/// To support subscription operations, a ``NetworkTransport`` should also implement the
/// ``SubscriptionNetworkTransport`` protocol.
public protocol NetworkTransport: AnyObject, Sendable {

  /// Send a GraphQL query to a server and return a response.
  ///
  /// - Parameters:
  ///   - query: The `GraphQLQuery` operation to send.
  ///   - fetchBehavior: The `FetchBehavior` to use for this request.
  ///   Determines if fetching will include cache/network fetches.
  ///   - requestConfiguration: A configuration used to configure per-request behaviors for this request
  /// - Returns: A stream of `GraphQLResult`s for each response.
  func send<Query: GraphQLQuery>(
    query: Query,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResponse<Query>, any Error>

  /// Send a GraphQL mutation to a server and return a response.
  ///
  /// - Parameters:
  ///   - mutation: The `GraphQLMutation` operation to send.
  ///   - fetchBehavior: The `FetchBehavior` to use for this request.
  ///   Determines if fetching will include cache/network fetches.
  ///   - requestConfiguration: A configuration used to configure per-request behaviors for this request
  /// - Returns: A stream of `GraphQLResult`s for each response.
  func send<Mutation: GraphQLMutation>(
    mutation: Mutation,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResponse<Mutation>, any Error>

}

// MARK: -

/// A protocol for a type that is responsible for sending GraphQL subscriptions to a server.
///
/// To support query and mutation operations, a ``SubscriptionNetworkTransport`` should also implement the
/// ``NetworkTransport`` protocol.
public protocol SubscriptionNetworkTransport {

  /// Send a GraphQL subscription to a server and return a response stream.
  ///
  /// - Parameters:
  ///   - subscription: The `GraphQLSubscription` operation to send.
  ///   - fetchBehavior: The `FetchBehavior` to use for this request.
  ///   Determines if fetching will include cache/network fetches.
  ///   - requestConfiguration: A configuration used to configure per-request behaviors for this request
  /// - Returns: A stream of `GraphQLResult`s for each response.
  func send<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResponse<Subscription>, any Error>

}

// MARK: -

/// A protocol for a type that is responsible for sending GraphQL file upload operations to a server.
///
/// To support query and mutation operations without file uploads, an ``UploadingNetworkTransport`` should also
/// implement the ``NetworkTransport`` protocol.
public protocol UploadingNetworkTransport {

  /// Sends a GraphQL operation to a server and uploads the given files.
  ///
  /// - Parameters:
  ///   - operation: The GraphQL operation to send
  ///   - files: An array of `GraphQLFile` objects to send.
  ///   - requestConfiguration: A configuration used to configure per-request behaviors for this request
  /// - Returns: A stream of `GraphQLResult`s for each response.
  func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    requestConfiguration: RequestConfiguration
  ) throws -> AsyncThrowingStream<GraphQLResponse<Operation>, any Error>
}

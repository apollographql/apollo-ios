import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// The `ApolloClientProtocol` provides the core API for Apollo. This API provides methods to fetch and watch queries, and to perform mutations.
#warning("TODO: move this to ApolloTestSupport? In test support, should have extension that implements all cache policy type functions from fetch behavior function")
public protocol ApolloClientProtocol: AnyObject, Sendable {

  ///  A store used as a local cache.
  var store: ApolloStore { get }

  /// Clears the `NormalizedCache` of the client's `ApolloStore`.
  func clearCache() async throws

  // MARK: - Fetch Functions

  /// Fetches a query from the server or from the local cache, depending on the current contents of the cache and the
  /// specified cache policy.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - fetchBehavior: A ``FetchBehavior`` that specifies when results should be fetched from the server or from the
  ///   local cache.
  ///   - requestConfiguration: A configuration used to configure per-request behaviors for this request
  func fetch<Query: GraphQLQuery>(
    query: Query,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration?
  ) throws -> AsyncThrowingStream<GraphQLResult<Query>, any Error>

  func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.CacheAndNetwork,
    requestConfiguration: RequestConfiguration?
  ) throws -> AsyncThrowingStream<GraphQLResult<Query>, any Error>
  where Query.ResponseFormat == SingleResponseFormat

  func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.SingleResponse,
    requestConfiguration: RequestConfiguration?
  ) throws -> AsyncThrowingStream<GraphQLResult<Query>, any Error>
  where Query.ResponseFormat == IncrementalDeferredResponseFormat

  func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.CacheAndNetwork,
    requestConfiguration: RequestConfiguration?
  ) throws -> AsyncThrowingStream<GraphQLResult<Query>, any Error>
  where Query.ResponseFormat == IncrementalDeferredResponseFormat

  func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.CacheOnly,
    requestConfiguration: RequestConfiguration?
  ) async throws -> GraphQLResult<Query>

  // MARK: - Watch Functions

  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the
  /// current contents of the cache and the specified cache policy. After the initial fetch, the returned query
  /// watcher object will get notified whenever any of the data the query result depends on changes in the local cache,
  /// and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - fetchBehavior: A ``FetchBehavior`` that specifies when results should be fetched from the server or from the
  ///   local cache.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the watcher's initial fetch. If `nil` the
  ///   client's `defaultRequestConfiguration` will be used.
  ///   - refetchOnFailedUpdates: Should the watcher perform a network fetch when it's watched
  ///   objects have changed, but reloading them from the cache fails. Defaults to `true`.
  ///   - resultHandler: A closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  func watch<Query: GraphQLQuery>(
    query: Query,
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration?,
    refetchOnFailedUpdates: Bool,
    resultHandler: @escaping GraphQLQueryWatcher<Query>.ResultHandler
  ) async -> GraphQLQueryWatcher<Query>

  func watch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.SingleResponse,
    requestConfiguration: RequestConfiguration?,
    refetchOnFailedUpdates: Bool,
    resultHandler: @escaping GraphQLQueryWatcher<Query>.ResultHandler
  ) async -> GraphQLQueryWatcher<Query>

  func watch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.CacheAndNetwork,
    requestConfiguration: RequestConfiguration?,
    refetchOnFailedUpdates: Bool,
    resultHandler: @escaping GraphQLQueryWatcher<Query>.ResultHandler
  ) async -> GraphQLQueryWatcher<Query>

  func watch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.CacheOnly,
    requestConfiguration: RequestConfiguration?,
    refetchOnFailedUpdates: Bool,
    resultHandler: @escaping GraphQLQueryWatcher<Query>.ResultHandler
  ) async -> GraphQLQueryWatcher<Query>

  // MARK: - Mutation Functions

  /// Performs a mutation by sending it to the server.
  ///
  /// Mutations always need to send their mutation data to the server, so there is no `cachePolicy` or `fetchBehavior`
  /// parameter.
  ///
  /// - Parameters:
  ///   - mutation: The mutation to perform.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the watcher's initial fetch. If `nil` the
  ///   client's `defaultRequestConfiguration` will be used.
  func perform<Mutation: GraphQLMutation>(
    mutation: Mutation,
    requestConfiguration: RequestConfiguration?
  ) async throws -> GraphQLResult<Mutation>
  where Mutation.ResponseFormat == SingleResponseFormat

  func perform<Mutation: GraphQLMutation>(
    mutation: Mutation,
    requestConfiguration: RequestConfiguration?
  ) throws -> AsyncThrowingStream<GraphQLResult<Mutation>, any Error>
  where Mutation.ResponseFormat == IncrementalDeferredResponseFormat

  // MARK: - Upload Functions

  /// Uploads the given files with the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to send
  ///   - files: An array of `GraphQLFile` objects to send.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the watcher's initial fetch. If `nil` the
  ///   client's `defaultRequestConfiguration` will be used.
  ///
  ///   - Note: An error will be thrown If your `networkTransport` does not also conform to `UploadingNetworkTransport`.
  func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    requestConfiguration: RequestConfiguration?
  ) async throws -> GraphQLResult<Operation>
  where Operation.ResponseFormat == SingleResponseFormat

  // MARK: - Subscription Functions

  /// Subscribe to a subscription
  ///
  /// - Parameters:
  ///   - subscription: The subscription to subscribe to.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the
  ///   local cache.
  func subscribe<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    cachePolicy: CachePolicy.Subscription,
    requestConfiguration: RequestConfiguration?
  ) async throws -> AsyncThrowingStream<GraphQLResult<Subscription>, any Error>

}

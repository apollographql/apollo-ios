import Foundation

/// The `ApolloClientProtocol` provides the core API for Apollo. This API provides methods to fetch and watch queries, and to perform mutations.
public protocol ApolloClientProtocol: class {

  ///  A store used as a local cache.
  var store: ApolloStore { get }

  /// A function that returns a cache key for a particular result object. If it returns `nil`, a default cache key based on the field path will be used.
  var cacheKeyForObject: CacheKeyForObject? { get set }

  /// Clears the underlying cache.
  /// Be aware: In more complex setups, the same underlying cache can be used across multiple instances, so if you call this on one instance, it'll clear that cache across all instances which share that cache.
  ///
  /// - Parameters:
  ///   - callbackQueue: The queue to fall back on. Should default to the main queue.
  ///   - completion: [optional] A completion closure to execute when clearing has completed. Should default to nil.
  func clearCache(callbackQueue: DispatchQueue, completion: ((Result<Void, Error>) -> Void)?)

  /// Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - contextIdentifier: [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Should default to `nil`.
  ///   - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress fetch.
  func fetch<Query: GraphQLQuery>(query: Query,
                                  cachePolicy: CachePolicy,
                                  contextIdentifier: UUID?,
                                  queue: DispatchQueue,
                                  resultHandler: GraphQLResultHandler<Query.Data>?) -> Cancellable

  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
  ///   - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  func watch<Query: GraphQLQuery>(query: Query,
                                  cachePolicy: CachePolicy,
                                  resultHandler: @escaping GraphQLResultHandler<Query.Data>) -> GraphQLQueryWatcher<Query>

  /// Performs a mutation by sending it to the server.
  ///
  /// - Parameters:
  ///   - mutation: The mutation to perform.
  ///   - publishResultToStore: If `true`, this will publish the result returned from the operation to the cache store. Default is `true`.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress mutation.
  func perform<Mutation: GraphQLMutation>(mutation: Mutation,
                                          publishResultToStore: Bool,
                                          queue: DispatchQueue,
                                          resultHandler: GraphQLResultHandler<Mutation.Data>?) -> Cancellable

  /// Uploads the given files with the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to send
  ///   - files: An array of `GraphQLFile` objects to send.
  ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - completionHandler: The completion handler to execute when the request completes or errors. Note that an error will be returned If your `networkTransport` does not also conform to `UploadingNetworkTransport`.
  /// - Returns: An object that can be used to cancel an in progress request.
  func upload<Operation: GraphQLOperation>(operation: Operation,
                                           files: [GraphQLFile],
                                           queue: DispatchQueue,
                                           resultHandler: GraphQLResultHandler<Operation.Data>?) -> Cancellable

  /// Subscribe to a subscription
  ///
  /// - Parameters:
  ///   - subscription: The subscription to subscribe to.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress subscription.
  func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription,
                                                    queue: DispatchQueue,
                                                    resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> Cancellable
}

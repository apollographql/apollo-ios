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
  ///   - context: [optional] A context to use for the cache to work with results. Should default to nil.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress fetch.
  func fetchWithContext<Query: GraphQLQuery>(query: Query,
                                  cachePolicy: CachePolicy,
                                  context: UnsafeMutableRawPointer?,
                                  queue: DispatchQueue,
                                  resultHandler: GraphQLResultWithContextHandler<Query.Data>?) -> Cancellable
  
  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
  ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  func watchWithContext<Query: GraphQLQuery>(query: Query,
                                  cachePolicy: CachePolicy,
                                  queue: DispatchQueue,
                                  resultHandler: @escaping GraphQLResultWithContextHandler<Query.Data>) -> GraphQLQueryWatcher<Query>
  
  /// Performs a mutation by sending it to the server.
  ///
  /// - Parameters:
  ///   - mutation: The mutation to perform.
  ///   - context: [optional] A context to use for the cache to work with results. Should default to nil.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress mutation.
  func performWithContext<Mutation: GraphQLMutation>(mutation: Mutation,
                                          context: UnsafeMutableRawPointer?,
                                          queue: DispatchQueue,
                                          resultHandler: GraphQLResultWithContextHandler<Mutation.Data>?) -> Cancellable
  
  /// Uploads the given files with the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to send
  ///   - context: [optional] A context to use for the cache to work with results. Should default to nil.
  ///   - files: An array of `GraphQLFile` objects to send.
  ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - completionHandler: The completion handler to execute when the request completes or errors
  /// - Returns: An object that can be used to cancel an in progress request.
  /// - Throws: If your `networkTransport` does not also conform to `UploadingNetworkTransport`.
  func uploadWithContext<Operation: GraphQLOperation>(operation: Operation,
                                           context: UnsafeMutableRawPointer?,
                                           files: [GraphQLFile],
                                           queue: DispatchQueue,
                                           resultHandler: GraphQLResultWithContextHandler<Operation.Data>?) -> Cancellable
  
  /// Subscribe to a subscription
  ///
  /// - Parameters:
  ///   - subscription: The subscription to subscribe to.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress subscription.
  func subscribeWithContext<Subscription: GraphQLSubscription>(subscription: Subscription,
                                                    queue: DispatchQueue,
                                                    resultHandler: @escaping GraphQLResultWithContextHandler<Subscription.Data>) -> Cancellable
}

// MARK: Extension for result handler
public extension ApolloClientProtocol {
  /// Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache.
  ///   - context: [optional] A context to use for the cache to work with results. Should default to nil.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress fetch.
  func fetch<Query: GraphQLQuery>(query: Query,
                                  cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                  context: UnsafeMutableRawPointer? = nil,
                                  queue: DispatchQueue = .main,
                                  resultHandler: GraphQLResultHandler<Query.Data>? = nil) -> Cancellable {
    return fetchWithContext(query: query, cachePolicy: cachePolicy, context: context, queue: queue, resultHandler: convertOptionalHandler(resultHandler))
  }

  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
  ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  func watch<Query: GraphQLQuery>(query: Query,
                                  cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                  queue: DispatchQueue = .main,
                                  resultHandler: @escaping GraphQLResultHandler<Query.Data>) -> GraphQLQueryWatcher<Query> {
    return watchWithContext(query: query, cachePolicy: cachePolicy, queue: queue, resultHandler: convertHandler(resultHandler))
  }

  /// Performs a mutation by sending it to the server.
  ///
  /// - Parameters:
  ///   - mutation: The mutation to perform.
  ///   - context: [optional] A context to use for the cache to work with results. Should default to nil.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress mutation.
  func perform<Mutation: GraphQLMutation>(mutation: Mutation,
                                          context: UnsafeMutableRawPointer? = nil,
                                          queue: DispatchQueue = .main,
                                          resultHandler: GraphQLResultHandler<Mutation.Data>? = nil) -> Cancellable {
    return performWithContext(mutation: mutation, context: context, queue: queue, resultHandler: convertOptionalHandler(resultHandler))
  }

  /// Uploads the given files with the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to send
  ///   - context: [optional] A context to use for the cache to work with results. Should default to nil.
  ///   - files: An array of `GraphQLFile` objects to send.
  ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - completionHandler: The completion handler to execute when the request completes or errors
  /// - Returns: An object that can be used to cancel an in progress request.
  /// - Throws: If your `networkTransport` does not also conform to `UploadingNetworkTransport`.
  func upload<Operation: GraphQLOperation>(operation: Operation,
                                           context: UnsafeMutableRawPointer? = nil,
                                           files: [GraphQLFile],
                                           queue: DispatchQueue = .main,
                                           resultHandler: GraphQLResultHandler<Operation.Data>? = nil) -> Cancellable {
    return uploadWithContext(operation: operation, context: context, files: files, queue: queue, resultHandler: convertOptionalHandler(resultHandler))
  }

  /// Subscribe to a subscription
  ///
  /// - Parameters:
  ///   - subscription: The subscription to subscribe to.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress subscription.
  func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription,
                                                    queue: DispatchQueue = .main,
                                                    resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> Cancellable {
    return subscribeWithContext(subscription: subscription, queue: queue, resultHandler: convertHandler(resultHandler))
  }

  /// Converts a `GraphQLResultHandler?` to `GraphQLResultWithContextHandler?`
  private func convertOptionalHandler<Data>(_ handler: GraphQLResultHandler<Data>? = nil) -> GraphQLResultWithContextHandler<Data>? {
    guard let handler = handler else { return nil }
    return convertHandler(handler)
  }

  /// Converts a `GraphQLResultHandler` to `GraphQLResultWithContextHandler`
  private func convertHandler<Data>(_ handler: @escaping GraphQLResultHandler<Data>) -> GraphQLResultWithContextHandler<Data> {
    return { result in
      switch result {
      case .success(let (data, _)):
        handler(.success(data))
      case .failure(let error):
        handler(.failure(error))
      }
    }
  }
}

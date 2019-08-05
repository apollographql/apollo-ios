// Created by guillaume_sabran on 8/5/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Dispatch

// MARK: - Protocol

/// Describes the Apollo client interface
public protocol ApolloClientProtocol: class {

  var store: ApolloStore { get }

  var cacheKeyForObject: CacheKeyForObject? { get set }

  /// Clears the underlying cache.
  /// Be aware: In more complex setups, the same underlying cache can be used across multiple instances, so if you call this on one instance, it'll clear that cache across all instances which share that cache.
  ///
  /// - Returns: Promise which fulfills when clear is complete.
  func clearCache() -> Promise<Void>

  /// Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when query results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress fetch.
  @discardableResult func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy, context: UnsafeMutableRawPointer?, queue: DispatchQueue, resultHandler: GraphQLResultHandler<Query.Data>?) -> Cancellable

  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  func watch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy, queue: DispatchQueue, resultHandler: @escaping GraphQLResultHandler<Query.Data>) -> GraphQLQueryWatcher<Query>

  /// Performs a mutation by sending it to the server.
  ///
  /// - Parameters:
  ///   - mutation: The mutation to perform.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress mutation.
  @discardableResult func perform<Mutation: GraphQLMutation>(mutation: Mutation, context: UnsafeMutableRawPointer?, queue: DispatchQueue, resultHandler: GraphQLResultHandler<Mutation.Data>?) -> Cancellable

  /// Subscribe to a subscription
  ///
  /// - Parameters:
  ///   - subscription: The subscription to subscribe to.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress subscription.
  @discardableResult func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription, queue: DispatchQueue, resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> Cancellable
}

// MARK: - Extension

public extension ApolloClientProtocol {

  @discardableResult func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, context: UnsafeMutableRawPointer? = nil, queue: DispatchQueue = DispatchQueue.main, resultHandler: GraphQLResultHandler<Query.Data>? = nil) -> Cancellable {
    return fetch(query: query, cachePolicy: cachePolicy, context: context, queue: queue, resultHandler: resultHandler)
  }

  func watch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping GraphQLResultHandler<Query.Data>) -> GraphQLQueryWatcher<Query> {
    return watch(query: query, cachePolicy: cachePolicy, queue: queue, resultHandler: resultHandler)
  }

  @discardableResult func perform<Mutation: GraphQLMutation>(mutation: Mutation, context: UnsafeMutableRawPointer? = nil, queue: DispatchQueue = DispatchQueue.main, resultHandler: GraphQLResultHandler<Mutation.Data>? = nil) -> Cancellable {
    return perform(mutation: mutation, context: context, queue: queue, resultHandler: resultHandler)
  }

  @discardableResult func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription, queue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> Cancellable {
    return subscribe(subscription: subscription, queue: queue, resultHandler: resultHandler)
  }
}

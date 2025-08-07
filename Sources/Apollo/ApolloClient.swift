import Dispatch
import Foundation
import ApolloAPI

public struct RequestConfiguration: Sendable {
  public var requestTimeout: TimeInterval?
  public var writeResultsToCache: Bool

  public init(
    requestTimeout: TimeInterval? = nil,
    writeResultsToCache: Bool = true
  ) {
    self.requestTimeout = requestTimeout
    self.writeResultsToCache = writeResultsToCache
  }
}

// MARK: -

/// `ApolloClient` is the primary public entry point for interacting with a GraphQL server and a local GraphQL
/// normalized cache. This class provides the
public final class ApolloClient: Sendable {

  let networkTransport: any NetworkTransport

  public let store: ApolloStore

  public let defaultRequestConfiguration: RequestConfiguration

  public enum Error: Swift.Error, LocalizedError, Hashable {
    case noResults
    case noUploadTransport
    case noSubscriptionTransport

    public var errorDescription: String? {
      switch self {
      case .noResults:
        return """
          The operation completed without returning any results. This can occur if the network returns a success response with no body content.
          If using a `RequestChainNetworkTransport`, this can also occur if an interceptor fails to pass on the emitted results.
          """
      case .noUploadTransport:
        return "Attempting to upload using a transport which does not support uploads. This is a developer error."
      case .noSubscriptionTransport:
        return
          "Attempting to begin a subscription using a transport which does not support subscriptions. This is a developer error."
      }
    }
  }

  /// Creates a client with the specified network transport and store.
  ///
  /// - Parameters:
  ///   - networkTransport: A network transport used to send operations to a server.
  ///   - store: A store used as a local cache. Note that if the `NetworkTransport` or any of its dependencies takes
  ///   a store, you should make sure the same store is passed here so that it can be cleared properly.
  ///   - defaultRequestConfiguration: A default``RequestConfiguration`` for the client's requests. When starting a
  ///   request with the client, if no ``RequestConfiguration`` is provided the default will be used.
  ///   - clientAwarenessMetadata: Metadata used by the
  ///     [client awareness](https://www.apollographql.com/docs/graphos/platform/insights/client-segmentation)
  ///     feature of GraphOS Studio.
  public init(
    networkTransport: any NetworkTransport,
    store: ApolloStore,
    defaultRequestConfiguration: RequestConfiguration = RequestConfiguration(),
    clientAwarenessMetadata: ClientAwarenessMetadata = ClientAwarenessMetadata()
  ) {
    self.networkTransport = networkTransport
    self.store = store
    self.defaultRequestConfiguration = defaultRequestConfiguration
    self.context = ClientContext(clientAwarenessMetadata: clientAwarenessMetadata)
  }

  /// Convenience initializer that creates a client with a default network transport and cache setup.
  ///
  /// This initializer creates a client that uses an in-memory only cache and a `RequestChainNetworkTransport`
  /// connecting to the specified URL with a default interceptor setup.
  ///
  /// The ``InMemoryNormalizedCache`` used by this client does not persist data between application runs.
  ///
  /// - Parameters:
  ///   - url: The URL of a GraphQL server to connect to.
  ///   - defaultRequestConfiguration: A default``RequestConfiguration`` for the client's requests. When starting a
  ///   request with the client, if no ``RequestConfiguration`` is provided the default will be used.
  ///   - clientAwarenessMetadata: Metadata used by the
  ///     [client awareness](https://www.apollographql.com/docs/graphos/platform/insights/client-segmentation)
  ///     feature of GraphOS Studio.
  public convenience init(
    url: URL,
    defaultRequestConfiguration: RequestConfiguration = RequestConfiguration(),
    clientAwarenessMetadata: ClientAwarenessMetadata = ClientAwarenessMetadata()
  ) {
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let provider = DefaultInterceptorProvider()
    let transport = RequestChainNetworkTransport(
      urlSession: URLSession(configuration: .default),
      interceptorProvider: provider,
      store: store,
      endpointURL: url
    )

    self.init(
      networkTransport: transport,
      store: store,
      defaultRequestConfiguration: defaultRequestConfiguration
    )
  }

  /// Clears the `NormalizedCache` of the client's `ApolloStore`.
  public func clearCache() async throws {
    try await self.store.clearCache()
  }

  // MARK: - Fetch Query

  // MARK: Fetch Query w/Fetch Behavior

  public func fetch<Query: GraphQLQuery>(
    query: Query,
    fetchBehavior: FetchBehavior = FetchBehavior.CacheFirst,
    requestConfiguration: RequestConfiguration? = nil
  ) throws -> AsyncThrowingStream<GraphQLResponse<Query>, any Swift.Error> {
    return try doInClientContext {
      return try self.networkTransport.send(
        query: query,
        fetchBehavior: fetchBehavior,
        requestConfiguration: requestConfiguration ?? self.defaultRequestConfiguration
      )
    }
  }

  // MARK: Single Response Format

  public func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.SingleResponse,
    requestConfiguration: RequestConfiguration? = nil
  ) async throws -> GraphQLResponse<Query>
  where Query.ResponseFormat == SingleResponseFormat {
    for try await result in try fetch(
      query: query,
      fetchBehavior: cachePolicy.toFetchBehavior(),
      requestConfiguration: requestConfiguration
    ) {
      return result
    }
    throw Error.noResults
  }

  public func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.CacheAndNetwork,
    requestConfiguration: RequestConfiguration? = nil
  ) throws -> AsyncThrowingStream<GraphQLResponse<Query>, any Swift.Error>
  where Query.ResponseFormat == SingleResponseFormat {
    return try fetch(
      query: query,
      fetchBehavior: FetchBehavior.CacheAndNetwork,
      requestConfiguration: requestConfiguration
    )
  }

  // MARK: Incremental Response Format

  public func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.SingleResponse,
    requestConfiguration: RequestConfiguration? = nil
  ) throws -> AsyncThrowingStream<GraphQLResponse<Query>, any Swift.Error>
  where Query.ResponseFormat == IncrementalDeferredResponseFormat {
    return try fetch(
      query: query,
      fetchBehavior: cachePolicy.toFetchBehavior(),
      requestConfiguration: requestConfiguration
    )
  }

  public func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.CacheAndNetwork,
    requestConfiguration: RequestConfiguration? = nil
  ) throws -> AsyncThrowingStream<GraphQLResponse<Query>, any Swift.Error>
  where Query.ResponseFormat == IncrementalDeferredResponseFormat {
    return try fetch(
      query: query,
      fetchBehavior: cachePolicy.toFetchBehavior(),
      requestConfiguration: requestConfiguration
    )
  }

  // MARK: Cache Only
  
  /// Fetches a query from the local cache. Does not attempt to fetch results from the server.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: The `CacheOnly` cache policy.
  ///   - requestConfiguration: A configuration used to configure per-request behaviors for this request
  ///
  ///   - Returns: The response loaded from the cache. On a cache miss, this will return `nil`.
  public func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.CacheOnly,
    requestConfiguration: RequestConfiguration? = nil
  ) async throws -> GraphQLResponse<Query>? {
    do {
      for try await result in try fetch(
        query: query,
        fetchBehavior: cachePolicy.toFetchBehavior(),
        requestConfiguration: requestConfiguration
      ) {
        return result
      }
      return nil
    } catch ApolloClient.Error.noResults {
      return nil
    }
  }

  // MARK: - Watch Query

  // MARK: Watch Query w/Fetch Behavior

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
  public func watch<Query: GraphQLQuery>(
    query: Query,
    fetchBehavior: FetchBehavior = FetchBehavior.CacheFirst,
    requestConfiguration: RequestConfiguration? = nil,
    refetchOnFailedUpdates: Bool = true,
    resultHandler: @escaping GraphQLQueryWatcher<Query>.ResultHandler
  ) async -> GraphQLQueryWatcher<Query> {
    let watcher = await GraphQLQueryWatcher(
      client: self,
      query: query,
      refetchOnFailedUpdates: refetchOnFailedUpdates,
      resultHandler: resultHandler
    )
    Task {
      await watcher.fetch(fetchBehavior: fetchBehavior, requestConfiguration: requestConfiguration)
    }
    return watcher
  }

  // MARK: Watch Query - CachePolicy Overloads

  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the
  /// current contents of the cache and the specified cache policy. After the initial fetch, the returned query
  /// watcher object will get notified whenever any of the data the query result depends on changes in the local cache,
  /// and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the
  ///   local cache.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the watcher's initial fetch. If `nil` the
  ///   client's `defaultRequestConfiguration` will be used.
  ///   - refetchOnFailedUpdates: Should the watcher perform a network fetch when it's watched
  ///   objects have changed, but reloading them from the cache fails. Defaults to `true`.
  ///   - resultHandler: A closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  public func watch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.SingleResponse,
    requestConfiguration: RequestConfiguration? = nil,
    refetchOnFailedUpdates: Bool = true,
    resultHandler: @escaping GraphQLQueryWatcher<Query>.ResultHandler
  ) async -> GraphQLQueryWatcher<Query> {
    return await self.watch(
      query: query,
      fetchBehavior: cachePolicy.toFetchBehavior(),
      requestConfiguration: requestConfiguration,
      refetchOnFailedUpdates: refetchOnFailedUpdates,
      resultHandler: resultHandler
    )
  }

  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the
  /// current contents of the cache and the specified cache policy. After the initial fetch, the returned query
  /// watcher object will get notified whenever any of the data the query result depends on changes in the local cache,
  /// and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the
  ///   local cache.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the watcher's initial fetch. If `nil` the
  ///   client's `defaultRequestConfiguration` will be used.
  ///   - refetchOnFailedUpdates: Should the watcher perform a network fetch when it's watched
  ///   objects have changed, but reloading them from the cache fails. Defaults to `true`.
  ///   - resultHandler: A closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  public func watch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.CacheAndNetwork,
    requestConfiguration: RequestConfiguration? = nil,
    refetchOnFailedUpdates: Bool = true,
    resultHandler: @escaping GraphQLQueryWatcher<Query>.ResultHandler
  ) async -> GraphQLQueryWatcher<Query> {
    return await self.watch(
      query: query,
      fetchBehavior: cachePolicy.toFetchBehavior(),
      requestConfiguration: requestConfiguration,
      refetchOnFailedUpdates: refetchOnFailedUpdates,
      resultHandler: resultHandler
    )
  }

  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the
  /// current contents of the cache and the specified cache policy. After the initial fetch, the returned query
  /// watcher object will get notified whenever any of the data the query result depends on changes in the local cache,
  /// and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the
  ///   local cache.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the watcher's initial fetch. If `nil` the
  ///   client's `defaultRequestConfiguration` will be used.
  ///   - refetchOnFailedUpdates: Should the watcher perform a network fetch when it's watched
  ///   objects have changed, but reloading them from the cache fails. Defaults to `true`.
  ///   - resultHandler: A closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  public func watch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy.Query.CacheOnly,
    requestConfiguration: RequestConfiguration? = nil,
    refetchOnFailedUpdates: Bool = true,
    resultHandler: @escaping GraphQLQueryWatcher<Query>.ResultHandler
  ) async -> GraphQLQueryWatcher<Query> {
    return await self.watch(
      query: query,
      fetchBehavior: cachePolicy.toFetchBehavior(),
      requestConfiguration: requestConfiguration,
      refetchOnFailedUpdates: refetchOnFailedUpdates,
      resultHandler: resultHandler
    )
  }

  // MARK: - Perform Mutation

  /// Performs a mutation by sending it to the server.
  ///
  /// Mutations always need to send their mutation data to the server, so there is no `cachePolicy` or `fetchBehavior`
  /// parameter.
  ///
  /// - Parameters:
  ///   - mutation: The mutation to perform.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the watcher's initial fetch. If `nil` the
  ///   client's `defaultRequestConfiguration` will be used.
  public func perform<Mutation: GraphQLMutation>(
    mutation: Mutation,
    requestConfiguration: RequestConfiguration? = nil
  ) async throws -> GraphQLResponse<Mutation>
  where Mutation.ResponseFormat == SingleResponseFormat {
    for try await result in try self.sendMutation(
      mutation: mutation,
      requestConfiguration: requestConfiguration
    ) {
      return result
    }
    throw Error.noResults
  }

  /// Performs a mutation by sending it to the server.
  ///
  /// Mutations always need to send their mutation data to the server, so there is no `cachePolicy` or `fetchBehavior`
  /// parameter.
  ///
  /// - Parameters:
  ///   - mutation: The mutation to perform.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the watcher's initial fetch. If `nil` the
  ///   client's `defaultRequestConfiguration` will be used.
  public func perform<Mutation: GraphQLMutation>(
    mutation: Mutation,
    requestConfiguration: RequestConfiguration? = nil
  ) throws -> AsyncThrowingStream<GraphQLResponse<Mutation>, any Swift.Error>
  where Mutation.ResponseFormat == IncrementalDeferredResponseFormat {
    return try sendMutation(mutation: mutation, requestConfiguration: requestConfiguration)
  }

  public func sendMutation<Mutation: GraphQLMutation>(
    mutation: Mutation,
    requestConfiguration: RequestConfiguration?
  ) throws -> AsyncThrowingStream<GraphQLResponse<Mutation>, any Swift.Error> {
    return try doInClientContext {
      return try self.networkTransport.send(
        mutation: mutation,
        requestConfiguration: requestConfiguration ?? defaultRequestConfiguration
      )
    }
  }

  // MARK: - Upload Operation

  /// Uploads the given files with the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to send
  ///   - files: An array of `GraphQLFile` objects to send.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the watcher's initial fetch. If `nil` the
  ///   client's `defaultRequestConfiguration` will be used.
  ///
  ///   - Note: An error will be thrown If your `networkTransport` does not also conform to `UploadingNetworkTransport`.
  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    requestConfiguration: RequestConfiguration? = nil
  ) async throws -> GraphQLResponse<Operation>
  where Operation.ResponseFormat == SingleResponseFormat {
    for try await result in try self.sendUpload(
      operation: operation,
      files: files,
      requestConfiguration: requestConfiguration
    ) {
      return result
    }
    throw Error.noResults
  }

  /// Uploads the given files with the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to send
  ///   - files: An array of `GraphQLFile` objects to send.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the watcher's initial fetch. If `nil` the
  ///   client's `defaultRequestConfiguration` will be used.
  ///
  ///   - Note: An error will be thrown If your `networkTransport` does not also conform to `UploadingNetworkTransport`.
  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    requestConfiguration: RequestConfiguration? = nil
  ) throws -> AsyncThrowingStream<GraphQLResponse<Operation>, any Swift.Error>
  where Operation.ResponseFormat == IncrementalDeferredResponseFormat {
    return try self.sendUpload(
      operation: operation,
      files: files,
      requestConfiguration: requestConfiguration
    )
  }

  private func sendUpload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    requestConfiguration: RequestConfiguration?
  ) throws -> AsyncThrowingStream<GraphQLResponse<Operation>, any Swift.Error> {
    guard let uploadingTransport = self.networkTransport as? (any UploadingNetworkTransport) else {
      assertionFailure(
        "Trying to upload without an uploading transport. Please make sure your network transport conforms to `UploadingNetworkTransport`."
      )
      throw Error.noUploadTransport
    }

    return try doInClientContext {
      return try uploadingTransport.upload(
        operation: operation,
        files: files,
        requestConfiguration: requestConfiguration ?? defaultRequestConfiguration
      )
    }
  }

  // MARK: - Subscription Operations

  /// Subscribe to a subscription
  ///
  /// - Parameters:
  ///   - subscription: The subscription to subscribe to.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the
  ///   local cache.
  public func subscribe<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    cachePolicy: CachePolicy.Subscription = .cacheThenNetwork,
    requestConfiguration: RequestConfiguration? = nil
  ) async throws -> AsyncThrowingStream<GraphQLResponse<Subscription>, any Swift.Error> {
    guard let subscriptionTransport = self.networkTransport as? (any SubscriptionNetworkTransport) else {
      assertionFailure(
        "Trying to subscribe without a subscription transport. Please make sure your network transport conforms to `SubscriptionNetworkTransport`."
      )
      throw Error.noSubscriptionTransport
    }

    return try doInClientContext {
      return
        try subscriptionTransport
        .send(
          subscription: subscription,
          fetchBehavior: cachePolicy.toFetchBehavior(),
          requestConfiguration: requestConfiguration ?? defaultRequestConfiguration
        )
    }
  }

  // MARK: - ClientContext

  @TaskLocal internal static var context: ClientContext?

  private let context: ClientContext

  struct ClientContext: Sendable {
    /// The telemetry metadata about the client. This is used by GraphOS Studio's
    /// [client awareness](https://www.apollographql.com/docs/graphos/platform/insights/client-segmentation)
    /// feature.
    let clientAwarenessMetadata: ClientAwarenessMetadata
  }

  private func doInClientContext<T>(_ block: () throws -> T) rethrows -> T {
    return try ApolloClient.$context.withValue(self.context) {
      return try block()
    }
  }
}

// MARK: - Deprecations

/// A handler for operation results.
///
/// - Parameters:
///   - result: The result of a performed operation. Will have a `GraphQLResult` with any parsed data and any GraphQL errors on `success`, and an `Error` on `failure`.
@available(*, deprecated)
public typealias GraphQLResultHandler<Operation: GraphQLOperation> = @Sendable (
  Result<GraphQLResponse<Operation>, any Error>
) ->
  Void

@available(*, deprecated)
public enum CachePolicy_v1: Sendable, Hashable {
  /// Return data from the cache if available, else fetch results from the server.
  case returnCacheDataElseFetch
  ///  Always fetch results from the server.
  case fetchIgnoringCacheData
  ///  Always fetch results from the server, and don't store these in the cache.
  case fetchIgnoringCacheCompletely
  /// Return data from the cache if available, else return an error.
  case returnCacheDataDontFetch
  /// Return data from the cache if available, and always fetch results from the server.
  case returnCacheDataAndFetch

  /// The current default cache policy.
  nonisolated(unsafe) public static var `default`: CachePolicy_v1 = .returnCacheDataElseFetch

  func toFetchBehavior() -> FetchBehavior {
    switch self {
    case .returnCacheDataElseFetch:
      return FetchBehavior.CacheFirst
    case .fetchIgnoringCacheData:
      return FetchBehavior.NetworkOnly
    case .fetchIgnoringCacheCompletely:
      return FetchBehavior.NetworkOnly
    case .returnCacheDataDontFetch:
      return FetchBehavior.CacheOnly
    case .returnCacheDataAndFetch:
      return FetchBehavior.CacheAndNetwork
    }
  }
}

extension ApolloClient {

  @available(*, deprecated)
  public func clearCache(
    callbackQueue: DispatchQueue = .main,
    completion: (@Sendable (Result<Void, any Swift.Error>) -> Void)? = nil
  ) {
    self.store.clearCache(callbackQueue: callbackQueue, completion: completion)
  }

  @_disfavoredOverload
  @available(*, deprecated)
  @discardableResult public func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy_v1? = nil,
    context: (any RequestContext)? = nil,
    queue: DispatchQueue = .main,
    resultHandler: GraphQLResultHandler<Query>? = nil
  ) -> (any Cancellable) {
    let cachePolicy = cachePolicy ?? CachePolicy_v1.default
    return awaitStreamInTask(
      {
        try self.fetch(
          query: query,
          fetchBehavior: cachePolicy.toFetchBehavior(),
          requestConfiguration: RequestConfiguration(writeResultsToCache: cachePolicy != .fetchIgnoringCacheCompletely)
        )
      },
      callbackQueue: queue,
      completion: resultHandler
    )
  }

  @available(*, deprecated)
  private func awaitStreamInTask<T: Sendable>(
    _ body: @escaping @Sendable () async throws -> AsyncThrowingStream<T, any Swift.Error>,
    callbackQueue: DispatchQueue?,
    completion: (@Sendable (Result<T, any Swift.Error>) -> Void)?
  ) -> some Cancellable {
    let task = Task {
      do {
        let resultStream = try await body()

        for try await result in resultStream {
          DispatchQueue.returnResultAsyncIfNeeded(
            on: callbackQueue,
            action: completion,
            result: .success(result)
          )
        }

      } catch {
        DispatchQueue.returnResultAsyncIfNeeded(
          on: callbackQueue,
          action: completion,
          result: .failure(error)
        )
      }
    }
    return TaskCancellable(task: task)
  }

  @_disfavoredOverload
  @available(
    *,
    deprecated,
    renamed: "watch(query:cachePolicy:refetchOnFailedUpdates:context:callbackQueue:resultHandler:)"
  )
  public func watch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy_v1? = nil,
    context: (any RequestContext)? = nil,
    callbackQueue: DispatchQueue = .main,
    resultHandler: @escaping GraphQLResultHandler<Query>
  ) async -> GraphQLQueryWatcher<Query> {
    let cachePolicy = cachePolicy ?? CachePolicy_v1.default
    let config = RequestConfiguration(
      requestTimeout: defaultRequestConfiguration.requestTimeout,
      writeResultsToCache: cachePolicy == .fetchIgnoringCacheCompletely
        ? false : defaultRequestConfiguration.writeResultsToCache
    )
    return await self.watch(
      query: query,
      fetchBehavior: cachePolicy.toFetchBehavior(),
      requestConfiguration: config,
      resultHandler: resultHandler
    )
  }

  @discardableResult
  @_disfavoredOverload
  @available(
    *,
    deprecated,
    renamed: "perform(mutation:requestConfiguration:)"
  )
  public func perform<Mutation: GraphQLMutation>(
    mutation: Mutation,
    publishResultToStore: Bool = true,
    queue: DispatchQueue = .main,
    resultHandler: GraphQLResultHandler<Mutation>? = nil
  ) -> (any Cancellable) {
    let config = RequestConfiguration(
      requestTimeout: defaultRequestConfiguration.requestTimeout,
      writeResultsToCache: publishResultToStore
    )

    return awaitStreamInTask(
      {
        try self.networkTransport.send(
          mutation: mutation,
          requestConfiguration: config
        )
      },
      callbackQueue: queue,
      completion: resultHandler
    )
  }

  @discardableResult
  @_disfavoredOverload
  @available(
    *,
    deprecated,
    renamed: "upload(operation:files:requestConfiguration:)"
  )
  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    queue: DispatchQueue = .main,
    resultHandler: GraphQLResultHandler<Operation>? = nil
  ) -> (any Cancellable) {
    return awaitStreamInTask(
      {
        try self.sendUpload(
          operation: operation,
          files: files,
          requestConfiguration: nil
        )
      },
      callbackQueue: queue,
      completion: resultHandler
    )
  }

  @discardableResult
  @_disfavoredOverload
  @available(
    *,
    deprecated,
    renamed: "subscribe(subscription:cachePolicy:requestConfiguration:)"
  )
  public func subscribe<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    queue: DispatchQueue = .main,
    resultHandler: @escaping GraphQLResultHandler<Subscription>
  ) -> any Cancellable {
    return awaitStreamInTask(
      {
        try await self.subscribe(subscription: subscription)
      },
      callbackQueue: queue,
      completion: resultHandler
    )
  }

}

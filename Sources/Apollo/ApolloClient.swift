import Dispatch
import Foundation

#if !COCOAPODS
  import ApolloAPI
#endif

/// A cache policy that specifies whether results should be fetched from the server or loaded from the local cache.
#warning("TODO: rethink this API. Only valid for queries currently")
public enum CachePolicy: Sendable, Hashable {
  /// Return data from the cache if available, else fetch results from the server.
  case cacheFirst
  /// Attempt to fetch results from the server, if failed, return data from the cache if available.
  case networkFirst
  ///  Fetch results from the server, do not attempt to read data from the cache.
  case networkOnly
  //  /// Return data from the cache if available, and always fetch results from the server.
  //  case cacheAndNetwork  // seperate function?
  //
  //  /// Return data from the cache if available, else return an error.
  //  case cacheOnly  // replace with separate function?

  ///  Always fetch results from the server, and don't store these in the cache.
  //  case fetchIgnoringCacheCompletely

}

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
/// The `ApolloClient` class implements the core API for Apollo by conforming to `ApolloClientProtocol`.
public final class ApolloClient: ApolloClientProtocol, Sendable {

  let networkTransport: any NetworkTransport

  public let store: ApolloStore

  #warning("TODO: unit test usage")
  public let defaultCachePolicy: CachePolicy

  public let defaultRequestConfiguration: RequestConfiguration

  public enum ApolloClientError: Error, LocalizedError, Hashable {
    case noResults
    case noUploadTransport
    case noSubscriptionTransport

    public var errorDescription: String? {
      switch self {
      case .noResults:
        return "The operation completed without returning any results."
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
  ///   - defaultCachePolicy: TODO
  ///   - clientAwarenessMetadata: Metadata used by the
  ///     [client awareness](https://www.apollographql.com/docs/graphos/platform/insights/client-segmentation)
  ///     feature of GraphOS Studio.
  public init(
    networkTransport: any NetworkTransport,
    store: ApolloStore,
    defaultCachePolicy: CachePolicy = .cacheFirst,
    defaultRequestConfiguration: RequestConfiguration = RequestConfiguration(),
    clientAwarenessMetadata: ClientAwarenessMetadata = ClientAwarenessMetadata()
  ) {
    self.networkTransport = networkTransport
    self.store = store
    self.defaultCachePolicy = defaultCachePolicy
    self.defaultRequestConfiguration = defaultRequestConfiguration
    self.context = ClientContext(clientAwarenessMetadata: clientAwarenessMetadata)
  }

  /// Creates a client with a `RequestChainNetworkTransport` connecting to the specified URL.
  ///
  /// - Parameters:
  ///   - url: The URL of a GraphQL server to connect to.
  ///   - clientAwarenessMetadata: Metadata used by the
  ///     [client awareness](https://www.apollographql.com/docs/graphos/platform/insights/client-segmentation)
  ///     feature of GraphOS Studio.
  public convenience init(
    url: URL,
    defaultCachePolicy: CachePolicy = .cacheFirst,
    defaultRequestConfiguration: RequestConfiguration = RequestConfiguration(),
    clientAwarenessMetadata: ClientAwarenessMetadata = ClientAwarenessMetadata()
  ) {
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let provider = DefaultInterceptorProvider()
    let transport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: url,
      clientAwarenessMetadata: clientAwarenessMetadata
    )

    self.init(
      networkTransport: transport,
      store: store,
      defaultCachePolicy: defaultCachePolicy,
      defaultRequestConfiguration: defaultRequestConfiguration
    )
  }

  public func clearCache() async throws {
    try await self.store.clearCache()
  }

  // MARK: - Fetch Query

  public func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy? = nil,
    requestConfiguration: RequestConfiguration? = nil
  ) async throws -> GraphQLResult<Query.Data>
  where Query.ResponseFormat == SingleResponseFormat {
    for try await result in try sendQuery(
      query: query,
      cachePolicy: cachePolicy,
      requestConfiguration: requestConfiguration
    ) {
      return result
    }
    throw ApolloClientError.noResults
  }

  public func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy? = nil,
    requestConfiguration: RequestConfiguration? = nil
  ) throws -> AsyncThrowingStream<GraphQLResult<Query.Data>, any Error>
  where Query.ResponseFormat == IncrementalDeferredResponseFormat {
    return try sendQuery(query: query, cachePolicy: cachePolicy, requestConfiguration: requestConfiguration)
  }

  private func sendQuery<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy?,
    requestConfiguration: RequestConfiguration?
  ) throws -> AsyncThrowingStream<GraphQLResult<Query.Data>, any Error> {
    return try doInClientContext {
      return try self.networkTransport.send(
        query: query,
        cachePolicy: cachePolicy ?? self.defaultCachePolicy,
        requestConfiguration: requestConfiguration ?? self.defaultRequestConfiguration
      )
    }
  }

  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
  ///   - refetchOnFailedUpdates: Should the watcher perform a network fetch when it's watched
  ///     objects have changed, but reloading them from the cache fails. Should default to `true`.
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  ///   - callbackQueue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  public func watch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy? = nil,
    refetchOnFailedUpdates: Bool = true,
    callbackQueue: DispatchQueue = .main,
    resultHandler: @escaping GraphQLResultHandler<Query.Data>
  ) -> GraphQLQueryWatcher<Query> {
    let watcher = GraphQLQueryWatcher(
      client: self,
      query: query,
      refetchOnFailedUpdates: refetchOnFailedUpdates,
      callbackQueue: callbackQueue,
      resultHandler: resultHandler
    )
    watcher.fetch(cachePolicy: cachePolicy ?? self.defaultCachePolicy)
    return watcher
  }

  @discardableResult
  public func perform<Mutation: GraphQLMutation>(
    mutation: Mutation,
    publishResultToStore: Bool = true,
    queue: DispatchQueue = .main,
    resultHandler: GraphQLResultHandler<Mutation.Data>? = nil
  ) -> (any Cancellable) {
    return awaitStreamInTask(
      {
        try self.networkTransport.send(
          mutation: mutation,
          cachePolicy: publishResultToStore ? self.defaultCachePolicy : .networkOnly,  // TODO: should be NoCache
        )
      },
      callbackQueue: queue,
      completion: resultHandler
    )
  }

  @discardableResult
  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    queue: DispatchQueue = .main,
    resultHandler: GraphQLResultHandler<Operation.Data>? = nil
  ) -> (any Cancellable) {
    guard let uploadingTransport = self.networkTransport as? (any UploadingNetworkTransport) else {
      assertionFailure(
        "Trying to upload without an uploading transport. Please make sure your network transport conforms to `UploadingNetworkTransport`."
      )
      queue.async {
        resultHandler?(.failure(ApolloClientError.noUploadTransport))
      }
      return EmptyCancellable()
    }

    return awaitStreamInTask(
      {
        try uploadingTransport.upload(
          operation: operation,
          files: files
        )
      },
      callbackQueue: queue,
      completion: resultHandler
    )
  }

  public func subscribe<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    queue: DispatchQueue = .main,
    resultHandler: @escaping GraphQLResultHandler<Subscription.Data>
  ) -> any Cancellable {
    guard let networkTransport = networkTransport as? (any SubscriptionNetworkTransport) else {
      assertionFailure(
        "Trying to subscribe without a subscription transport. Please make sure your network transport conforms to `SubscriptionNetworkTransport`."
      )
      queue.async {
        resultHandler(.failure(ApolloClientError.noSubscriptionTransport))
      }
      return EmptyCancellable()
    }

    return awaitStreamInTask(
      {
        try networkTransport.send(
          subscription: subscription,
          cachePolicy: self.defaultCachePolicy,  // TODO: should this just be networkOnly?
        )
      },
      callbackQueue: queue,
      completion: resultHandler
    )
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
public typealias GraphQLResultHandler<Data: RootSelectionSet> = @Sendable (Result<GraphQLResult<Data>, any Error>) ->
  Void

extension ApolloClient {

  @available(*, deprecated)
  public func clearCache(
    callbackQueue: DispatchQueue = .main,
    completion: (@Sendable (Result<Void, any Error>) -> Void)? = nil
  ) {
    self.store.clearCache(callbackQueue: callbackQueue, completion: completion)
  }

  @available(*, deprecated)
  @discardableResult public func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy? = nil,
    context: (any RequestContext)? = nil,
    queue: DispatchQueue = .main,
    resultHandler: GraphQLResultHandler<Query.Data>? = nil
  ) -> (any Cancellable) {
    return awaitStreamInTask(
      {
        try self.networkTransport.send(
          query: query,
          cachePolicy: cachePolicy ?? self.defaultCachePolicy
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
    cachePolicy: CachePolicy? = nil,
    context: (any RequestContext)? = nil,
    callbackQueue: DispatchQueue = .main,
    resultHandler: @escaping GraphQLResultHandler<Query.Data>
  ) -> GraphQLQueryWatcher<Query> {
    let watcher = GraphQLQueryWatcher(
      client: self,
      query: query,
      context: context,
      callbackQueue: callbackQueue,
      resultHandler: resultHandler
    )
    watcher.fetch(cachePolicy: cachePolicy ?? self.defaultCachePolicy)
    return watcher
  }

}

// MARK: - Fetch Behavior Creation
extension FetchBehavior {
  fileprivate init(queryCachePolicy: CachePolicy) {
    switch queryCachePolicy {
    case .cacheFirst:
      self.shouldAttemptCacheRead = true
      self.shouldAttemptNetworkFetch = .onCacheFailure

    case .networkFirst:
      self
    }

  }
}

import Foundation
import ApolloAPI

/// A ``GraphQLQueryWatcher`` is responsible for watching the store, and calling the result handler with a new result
/// whenever any of query's data changes.
///
/// - Important: The store retains the watcher while subscribed. You must call ``GraphQLQueryWatcher/cancel()`` on your
/// query watcher when you are done watching updates. Failure to call `cancel()` before releasing your reference to the
/// returned watcher will result in a memory leak.
public actor GraphQLQueryWatcher<Query: GraphQLQuery>: ApolloStoreSubscriber {
  public typealias ResultHandler = @Sendable (Result<GraphQLResponse<Query>, any Swift.Error>) -> Void
  private typealias FetchBlock = @Sendable (FetchBehavior, RequestConfiguration?) throws -> AsyncThrowingStream<
    GraphQLResponse<Query>, any Error
  >?

  /// The ``GraphQLQuery`` for the watcher.
  ///
  /// When ``fetch(fetchBehavior:requestConfiguration:)`` is called, this query will be fetched and the `resultHandler`
  /// will be called with the results.
  /// After the initial fetch, changes in the local cache to any of the query's data will trigger this query
  /// to be re-fetched from the cache and the `resultHandler` will be called again with the updated results.
  public let query: Query

  /// Determines if the watcher should perform a network fetch when it's watched objects have
  /// changed, but reloading them from the cache fails. Defaults to `true`.
  ///
  /// If set to `false`, the watcher will not receive updates if the cache load fails.
  public let refetchOnFailedUpdates: Bool

  public private(set) var cancelled: Bool = false

  private var lastFetch: FetchContext?
  private var dependentKeys: Set<CacheKey>? = nil

  private let resultHandler: ResultHandler
  private let contextIdentifier = UUID()
  private let fetchBlock: FetchBlock
  private let cancelBlock: @Sendable (GraphQLQueryWatcher) -> Void
  private nonisolated(unsafe) var subscriptionToken: ApolloStore.SubscriptionToken!

  private struct FetchContext {
    let task: Task<Void, Never>
    let fetchBehavior: FetchBehavior
    let requestConfiguration: RequestConfiguration?
  }

  /// Designated initializer
  ///
  /// The watcher will not begin watching for updates on the query until an initial fetch is triggered and completes.
  /// The initial fetch provides the watcher the data to watch for changes. A fetch must be triggered after the watcher
  /// is initialized using any of the `fetch` methods provided by the ``GraphQLQueryWatcher``. Once the initial result
  /// is returned, the watcher has begun watching for changes.
  ///
  /// - Parameters:
  ///   - client: The ``ApolloClient`` used to make fetch requests for the watcher.
  ///   - query: The `GraphQLQuery` to watch.
  ///   - refetchOnFailedUpdates: Should the watcher perform a network fetch when it's watched
  ///     objects have changed, but reloading them from the cache fails. Defaults to `true`.
  ///   - resultHandler: The result handler to call when updated data is received.
  public init(
    client: ApolloClient,
    query: Query,
    refetchOnFailedUpdates: Bool = true,
    resultHandler: @escaping ResultHandler
  ) async {
    self.query = query
    self.refetchOnFailedUpdates = refetchOnFailedUpdates
    self.resultHandler = resultHandler

    self.fetchBlock = { [weak client] in
      guard let client else { return nil }

      return try client.fetch(
        query: query,
        fetchBehavior: $0,
        requestConfiguration: $1
      )
    }

    self.cancelBlock = { [weak client] (self) in
      guard let client else {
        return
      }

      client.store.unsubscribe(self.subscriptionToken)
      Task.detached {
        await self.doOnActor { (self) in
          self.cancelled = true
        }
      }
    }

    self.subscriptionToken = await client.store.subscribe(self)
  }

  private func doOnActor(
    _ block: @escaping @Sendable (isolated GraphQLQueryWatcher) async throws -> Void
  ) async rethrows {
    try await block(self)
  }

  // MARK: - Fetch
  
  /// Triggers a fetch of the receiver's ``GraphQLQueryWatcher/query`` using a provided ``FetchBehavior``. If a fetch
  /// is currently in progress, it will be cancelled.
  ///
  /// - Parameters:
  ///   - fetchBehavior: The ``FetchBehavior`` to use for this request.
  ///   Determines if fetching will include cache/network fetches.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the fetch. Defaults to `nil`.
  ///   If `nil`, the ``ApolloClient/defaultRequestConfiguration`` of the receiver's `client` will be used.
  public func fetch(
    fetchBehavior: FetchBehavior,
    requestConfiguration: RequestConfiguration? = nil
  ) {
    QueryWatcherContext.$identifier.withValue(self.contextIdentifier) {
      self.lastFetch?.task.cancel()

      let fetchTask = Task {
        do {
          try Task.checkCancellation()

          guard let fetch = try self.fetchBlock(fetchBehavior, requestConfiguration) else {
            // Fetch returned nil because the client has been deinitialized.
            // Watcher is invalid and should be cancelled.
            self.cancel()
            return
          }

          for try await result in fetch {
            try Task.checkCancellation()

            if let dependentKeys = result.dependentKeys {
              self.dependentKeys = dependentKeys
            }
            self.didReceiveResult(result)
          }
        } catch is CancellationError {
          // Fetch cancellation. No-op
        } catch {
          self.didReceiveError(error)
        }
      }

      self.lastFetch = FetchContext(
        task: fetchTask,
        fetchBehavior: fetchBehavior,
        requestConfiguration: requestConfiguration
      )
    }
  }

  /// Triggers a fetch of the receiver's ``GraphQLQueryWatcher/query`` using a provided ``CachePolicy``. If a fetch
  /// is currently in progress, it will be cancelled.
  ///
  /// - Parameters:
  ///   - cachePolicy: A ``CachePolicy`` to use for this request.
  ///   Determines if the initial fetch will include cache/network fetches.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the fetch. Defaults to `nil`.
  ///   If `nil`, the ``ApolloClient/defaultRequestConfiguration`` of the receiver's `client` will be used.
  public func fetch(
    cachePolicy: CachePolicy.Query.SingleResponse,
    requestConfiguration: RequestConfiguration? = nil
  ) {
    self.fetch(fetchBehavior: cachePolicy.toFetchBehavior(), requestConfiguration: requestConfiguration)
  }

  /// Triggers a fetch of the receiver's ``GraphQLQueryWatcher/query`` using a provided ``CachePolicy``. If a fetch
  /// is currently in progress, it will be cancelled.
  ///
  /// - Parameters:
  ///   - cachePolicy: A ``CachePolicy`` to use for this request.
  ///   Determines if the initial fetch will include cache/network fetches.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the fetch. Defaults to `nil`.
  ///   If `nil`, the ``ApolloClient/defaultRequestConfiguration`` of the receiver's `client` will be used.
  public func fetch(
    cachePolicy: CachePolicy.Query.CacheOnly,
    requestConfiguration: RequestConfiguration? = nil
  ) {
    self.fetch(fetchBehavior: cachePolicy.toFetchBehavior(), requestConfiguration: requestConfiguration)
  }

  /// Triggers a fetch of the receiver's ``GraphQLQueryWatcher/query`` using a provided ``CachePolicy``. If a fetch
  /// is currently in progress, it will be cancelled.
  ///
  /// - Parameters:
  ///   - cachePolicy: A ``CachePolicy`` to use for this request.
  ///   Determines if the initial fetch will include cache/network fetches.
  ///   - requestConfiguration: A ``RequestConfiguration`` to use for the fetch. Defaults to `nil`.
  ///   If `nil`, the ``ApolloClient/defaultRequestConfiguration`` of the receiver's `client` will be used.
  public func fetch(
    cachePolicy: CachePolicy.Query.CacheAndNetwork,
    requestConfiguration: RequestConfiguration? = nil
  ) {
    self.fetch(fetchBehavior: cachePolicy.toFetchBehavior(), requestConfiguration: requestConfiguration)
  }

  // MARK: - Result Handling

  private func didReceiveResult(_ result: GraphQLResponse<Query>) {
    guard !self.cancelled else { return }
    resultHandler(.success(result))
  }

  private func didReceiveError(_ error: any Swift.Error) {
    guard !self.cancelled else { return }
    resultHandler(.failure(error))
  }

  /// Cancel any in progress fetching operations and unsubscribe from the store.
  public nonisolated consuming func cancel() {
    self.cancelBlock(self)
  }

  public nonisolated func store(
    _ store: ApolloStore,
    didChangeKeys changedKeys: Set<CacheKey>
  ) {
    if let incomingIdentifier = QueryWatcherContext.identifier,
      incomingIdentifier == self.contextIdentifier
    {
      // This is from changes to the keys made from the `fetch` method above,
      // changes will be returned through that and do not need to be returned
      // here as well.
      return
    }

    Task {
      await self.doOnActor { (self) in
        guard !self.cancelled else { return }
        guard let dependentKeys = self.dependentKeys else {
          // This query has nil dependent keys, so nothing that changed will affect it.
          return
        }

        let cacheReadFailed = {
          if self.refetchOnFailedUpdates && self.lastFetch?.fetchBehavior.networkFetch != .never {
            // If the cache fetch is not successful, for instance if the data is missing, refresh from the server.
            self.fetch(
              fetchBehavior: FetchBehavior.NetworkOnly,
              requestConfiguration: self.lastFetch?.requestConfiguration
            )
          }
        }

        if !dependentKeys.isDisjoint(with: changedKeys) {
          do {
            // First, attempt to reload the query from the cache directly, in order not to interrupt any
            // in-flight server-side fetch.
            guard let result = try await store.load(self.query) else {
              cacheReadFailed()
              return
            }
            
            self.dependentKeys = result.dependentKeys
            self.didReceiveResult(result)

          } catch {
            cacheReadFailed()
          }
        }
      }
    }
  }
}

// MARK: - Task Local Values

private enum QueryWatcherContext {
  @TaskLocal static var identifier: UUID?
}

// MARK: - Deprecation

extension GraphQLQueryWatcher {
  @available(*, deprecated)
  @_disfavoredOverload
  public init(
    client: ApolloClient,
    query: Query,
    refetchOnFailedUpdates: Bool = true,
    context: (any RequestContext)? = nil,
    callbackQueue: DispatchQueue = .main,
    resultHandler: @escaping GraphQLResultHandler<Query>
  ) async {
    await self.init(
      client: client,
      query: query,
      refetchOnFailedUpdates: refetchOnFailedUpdates,
      resultHandler: resultHandler
    )
  }

  @available(*, deprecated, renamed: "fetch(fetchBehavior:)")
  public func refetch(cachePolicy: CachePolicy.Query.SingleResponse = .cacheFirst) {
    fetch(fetchBehavior: cachePolicy.toFetchBehavior())
  }

  @available(*, deprecated, renamed: "fetch(fetchBehavior:)")
  public func refetch(cachePolicy: CachePolicy_v1 = .returnCacheDataElseFetch) {
    fetch(fetchBehavior: cachePolicy.toFetchBehavior())
  }

}

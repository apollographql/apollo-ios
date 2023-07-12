#if !COCOAPODS
import ApolloAPI
#endif
import Dispatch

/// Handles pagination in the queue by managing multiple query watchers.
public final class GraphQLPaginatedQueryWatcher<Strategy: PaginationStrategy> {
  public typealias Page = Strategy.NextPageConstructor.Page
  private typealias ResultHandler = (Result<GraphQLResult<Strategy.Query.Data>, Error>) -> Void

  private let client: any ApolloClientProtocol
  private var watchers: [GraphQLQueryWatcher<Strategy.Query>] = []
  private var callbackQueue: DispatchQueue
  let strategy: Strategy

  /// Designated initalizer
  /// - Parameters:
  ///   - client: the Apollo client
  ///   - callbackQueue: The `DispatchQueue` that results are returned on.
  ///   - strategy: The `PaginationStrategy` that this watcher employs.
  ///   - initialQuery: The `Query` that is being watched.
  public init(
    client: ApolloClientProtocol,
    callbackQueue: DispatchQueue = .main,
    strategy: Strategy,
    initialQuery: Strategy.Query
  ) {
    self.callbackQueue = callbackQueue
    self.client = client
    self.strategy = strategy
    let initialWatcher = GraphQLQueryWatcher(
      client: client,
      query: initialQuery,
      callbackQueue: callbackQueue,
      resultHandler: strategy.onWatchResult(result:)
    )
    watchers = [initialWatcher]
  }

  /// Fetch the first page
  /// NOTE: Does not refresh subsequent pages nor remove them from the return value.
  public func fetch(cachePolicy: CachePolicy = .returnCacheDataAndFetch) {
    watchers.first?.fetch(cachePolicy: cachePolicy)
  }

  /// Fetches the first page and purges all data from subsequent pages.
  public func refetch(cachePolicy: CachePolicy = .fetchIgnoringCacheData) {
    // Reset mapping of data and order of data
    strategy.reset()
    // Remove and cancel all watchers aside from the first page
    guard let initialWatcher = watchers.first else { return }
    let subsequentWatchers = watchers.dropFirst()
    subsequentWatchers.forEach { $0.cancel() }
    watchers = [initialWatcher]
    initialWatcher.refetch(cachePolicy: cachePolicy)
  }

  /// Fetches the next page
  @discardableResult public func fetchMore(
    cachePolicy: CachePolicy = .fetchIgnoringCacheData,
    completion: (() -> Void)? = nil
  ) -> Bool {
    guard strategy.canFetchNextPage(),
          let currentPage = strategy.currentPage
    else { return false }
    let nextPageQuery = strategy.nextPageStrategy.createNextPageQuery(page: currentPage)

    let nextPageWatcher = client.watch(
      query: nextPageQuery,
      cachePolicy: cachePolicy,
      callbackQueue: callbackQueue
    ) { [weak self] result in
      self?.strategy.onWatchResult(result: result)
      completion?()
    }
    watchers.append(nextPageWatcher)

    return true
  }

  /// Refetches data for a given page.
  /// NOTE: Does not refresh previous or subsequent pages nor remove them from the return value.
  public func refresh(page: Page?, cachePolicy: CachePolicy = .returnCacheDataAndFetch) {
    guard let page else {
      // Fetch first page
      return fetch(cachePolicy: cachePolicy)
    }
    guard let index = strategy.pages.firstIndex(where: { $0 == page }),
          watchers.count > index
    else { return }
    watchers[index].fetch(cachePolicy: cachePolicy)
  }

  /// Cancel any in progress fetching operations and unsubscribe from the store.
  public func cancel() {
    watchers.forEach { $0.cancel() }
  }

  deinit {
    cancel()
  }
}

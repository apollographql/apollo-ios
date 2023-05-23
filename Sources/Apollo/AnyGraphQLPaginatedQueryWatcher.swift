/// A type-erased `GraphQLPaginatedQueryWatcher`
public class AnyGraphQLPaginatedQueryWatcher: PaginatedQueryWatcherType {
  private let _fetch: (CachePolicy) -> Void
  private let _refetch: (CachePolicy) -> Void
  private let _fetchMore: (CachePolicy, (() -> Void)?) -> Bool
  private let _refresh: (Page?, CachePolicy) -> Void
  private let _cancel: () -> Void

  public init<W: GraphQLPaginatedQueryWatcher<S>, S>(watcher: W) {
    self._fetch = { policy in watcher.fetch(cachePolicy: policy) }
    self._refetch = { policy in watcher.refetch(cachePolicy: policy) }
    self._fetchMore = { policy, completion in watcher.fetchMore(cachePolicy: policy, completion: completion) }
    self._refresh = { page, policy in watcher.refresh(page: page, cachePolicy: policy) }
    self._cancel = { watcher.cancel() }
  }

  public func fetch(cachePolicy: CachePolicy = .returnCacheDataAndFetch) {
    _fetch(cachePolicy)
  }

  public func refetch(cachePolicy: CachePolicy = .fetchIgnoringCacheData) {
    _refetch(cachePolicy)
  }

  @discardableResult public func fetchMore(cachePolicy: CachePolicy = .fetchIgnoringCacheData, completion: (() -> Void)? = nil) -> Bool {
    _fetchMore(cachePolicy, completion)
  }

  public func refresh(page: Page?, cachePolicy: CachePolicy = .returnCacheDataAndFetch) {
    _refresh(page, cachePolicy)
  }

  public func cancel() {
    _cancel()
  }
}

public extension GraphQLPaginatedQueryWatcher {
  /// Transforms the `GraphQLPaginatedQueryWatcher` into `AnyGraphQLPaginatedQueryWatcher`
  /// - Returns: `AnyGraphQLPaginatedQueryWatcher`
  func eraseToAnyWatcher() -> AnyGraphQLPaginatedQueryWatcher {
    .init(watcher: self)
  }
}

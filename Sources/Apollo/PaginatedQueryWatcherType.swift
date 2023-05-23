/// The query by which a watcher is defined.
public protocol PaginatedQueryWatcherType: Cancellable {
  /// Fetch the first page without resetting data
  /// - Parameter cachePolicy: A `CachePolicy` that governs how this data is fetched and stored.
  func fetch(cachePolicy: CachePolicy)

  /// Fetches the first page while resetting all data for subsequent pages.
  /// - Parameter cachePolicy: A `CachePolicy` that governs how this data is fetched and stored.
  func refetch(cachePolicy: CachePolicy)

  /// Fetches the next page using the existing `PaginationStrategy`.
  /// - Parameters:
  ///   - cachePolicy: A `CachePolicy` that governs how this data is fetched and stored.
  ///   - completion: An optional callback block triggered after the fetch has completed.
  /// - Returns: Whether or not there is more data present in the next page.
  func fetchMore(cachePolicy: CachePolicy, completion: (() -> Void)?) -> Bool

  /// Re-fetches a given page.
  /// - Parameters:
  ///   - page: The `Page` to refetch.
  ///   - cachePolicy: A `CachePolicy` that governs how this data is fetched and stored.
  func refresh(page: Page?, cachePolicy: CachePolicy)
}

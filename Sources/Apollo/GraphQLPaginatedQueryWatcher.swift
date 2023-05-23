#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

/// Handles pagination in the queue by managing multiple query watchers.
public final class GraphQLPaginatedQueryWatcher<Strategy: PaginationStrategy>: PaginatedQueryWatcherType {
  /// Given a page, create a query of the type this watcher is responsible for
  public typealias CreatePageQuery = (Page) -> Strategy.Query?

  private typealias ResultHandler = (Result<GraphQLResult<Strategy.Query.Data>, Error>) -> Void

  private let client: any ApolloClientProtocol
  private var watchers: [GraphQLQueryWatcher<Strategy.Query>] = []
  private let createPageQuery: CreatePageQuery
  private var modelMap: [Cursor?: Strategy.Output] = [:]
  private var cursorOrder: [Cursor?] = []
  private var resultHandler: ResultHandler?
  private var callbackQueue: DispatchQueue
  private let mergeStrategy: Strategy
  private var mostRecentModel: Strategy.Output?

  /// The last extracted `Page` from the network response.
  /// "last" in this instance refers to pagination order, not most recent.
  public private(set) var currentPage: Page? {
    didSet {
      guard let currentPage else { return }
      pages.append(currentPage)
    }
  }

  /// All fetched pages
  public private(set) var pages: [Page?] = [nil]
  /// Designated Initializer
  /// - Parameters:
  ///   - client: The client protocol to pass in
  ///   - inititalCachePolicy: The preferred cache policy for the initlal page. Defaults to `returnCacheDataAndFetch`.
  ///   - callbackQueue: The queue for response callbacks.
  ///   - mergeStrategy: The merge strategy (such as `SimplePaginationStrategy` or `CustomPaginationStrategy`) by which this class operates.
  ///   - query: The query to watch
  ///   - createPageQuery: A function which creates a new `Query` given some pagination information.
  public init(
    client: ApolloClientProtocol,
    inititalCachePolicy: CachePolicy = .returnCacheDataAndFetch,
    callbackQueue: DispatchQueue = .main,
    mergeStrategy: Strategy,
    query: Strategy.Query,
    createPageQuery: @escaping CreatePageQuery
  ) {
    self.callbackQueue = callbackQueue
    self.client = client
    self.mergeStrategy = mergeStrategy
    self.createPageQuery = createPageQuery

    let resultHandler: ResultHandler = { [weak self] result in
      guard let self else { return }
      switch result {
      case .failure(let error):
        guard !error.wasCancelled else { return }
        // Forward all errors aside from network cancellation errors
        mergeStrategy.resultHandler(result: .failure(error), source: nil)
      case .success(let graphQLResult):
        guard let data = graphQLResult.data,
              let (transformedModel, page) = mergeStrategy.transform(data: data),
              let transformedModel
        else { return }
        // Store in the model map and update page information
        self.modelMap[page?.endCursor] = transformedModel
        if !self.cursorOrder.contains(page?.endCursor) {
          self.cursorOrder.append(page?.endCursor)
        }
        if let index = self.pages.firstIndex(of: page) {
          self.pages[index] = page
        } else {
          self.currentPage = page
        }
        // Create output model and update the caller if it's new
        let model = mergeStrategy.mergePageResults(response: .init(
          allResponses: self.cursorOrder.compactMap { [weak self] cursor in
            self?.modelMap[cursor]
          },
          mostRecent: transformedModel,
          source: graphQLResult.source
        ))
        // Make sure we only notify the caller once of an update
        guard model != self.mostRecentModel else { return }
        mergeStrategy.resultHandler(result: .success(model), source: graphQLResult.source)
        self.mostRecentModel = model
      }
    }

    self.resultHandler = resultHandler
    let initialWatcher = GraphQLQueryWatcher(
      client: client,
      query: query,
      callbackQueue: callbackQueue,
      resultHandler: resultHandler
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
    modelMap.removeAll()
    cursorOrder.removeAll()
    currentPage = nil
    pages.removeAll()
    mostRecentModel = nil
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
    guard let currentPage,
          currentPage.hasNextPage,
          let nextPageQuery = createPageQuery(currentPage),
          let resultHandler
    else { return false }

    let nextPageWatcher = client.watch(
      query: nextPageQuery,
      cachePolicy: cachePolicy,
      callbackQueue: callbackQueue
    ) { result in
      resultHandler(result)
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
    guard let index = pages.firstIndex(where: { $0?.endCursor == page.endCursor }),
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

private extension Error {
  var wasCancelled: Bool {
    if let apolloError = self as? URLSessionClient.URLSessionClientError,
       case let .networkError(data: _, response: _, underlying: underlying) = apolloError {
      return underlying.wasCancelled
    }

    return (self as NSError).code == NSURLErrorCancelled
  }
}

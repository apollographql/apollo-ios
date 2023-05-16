#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

public typealias Cursor = String
public struct Page: Equatable {
  let hasNextPage: Bool
  let endCursor: Cursor?

  public init(hasNextPage: Bool, endCursor: Cursor?) {
    self.hasNextPage = hasNextPage
    self.endCursor = endCursor
  }
}

/// Handles pagination in the queue by managing multiple query watchers.
final class GraphQLPaginatedQueryWatcher<Query: GraphQLQuery, T>: Cancellable {
  /// Given a page, create a query of the type this watcher is responsible for
  public typealias CreatePageQuery = (Page) -> Query?

  private typealias ResultHandler = (Result<GraphQLResult<Query.Data>, Error>) -> Void

  private let client: any ApolloClientProtocol

  private var watchers: [GraphQLQueryWatcher<Query>] = []

  private let createPageQuery: CreatePageQuery

  private var modelMap: [Cursor?: T] = [:]
  private var cursorOrder: [Cursor?] = []

  private var resultHandler: ResultHandler?
  private var callbackQueue: DispatchQueue
  public private(set) var currentPage: Page? {
    didSet {
      guard let currentPage else { return }
      pages.append(currentPage)
    }
  }
  public private(set) var pages: [Page?] = [nil]
  private let mergeStrategy: PaginationMergeStrategy<Query, T>

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - client: The client protocol to pass in
  ///   - inititalCachePolicy: The preferred cache policy for the initlal page. Defaults to `returnCacheDataAndFetch`.
  ///   - callbackQueue: The queue for response callbacks.
  ///   - query: The query to watch
  ///   - createPageQuery: A function which creates a new `Query` given some pagination information.
  ///   - transform: Transforms the `Query.Data` to the intended model and extracts the `Page` from the `Data`.
  ///   - nextPageTransform: A function which combines extant data with the new data from the next page
  ///   - onReceiveResults: The callback function which returns changes or an error.
  public init(
    client: ApolloClientProtocol,
    inititalCachePolicy: CachePolicy = .returnCacheDataAndFetch,
    callbackQueue: DispatchQueue = .main,
    mergeStrategy: PaginationMergeStrategy<Query, T>,
    query: Query,
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
        mergeStrategy.resultHandler(result: .failure(error))
      case .success(let graphQLResult):
        guard let data = graphQLResult.data,
              let (transformedModel, page) = mergeStrategy.transform(data: data),
              let transformedModel
        else { return }
        modelMap[page?.endCursor] = transformedModel
        if !cursorOrder.contains(page?.endCursor) {
          cursorOrder.append(page?.endCursor)
        }
        let model = mergeStrategy.mergePageResults(response: .init(
          allResponses: cursorOrder.compactMap { [weak self] cursor in
            self?.modelMap[cursor]
          },
          mostRecent: transformedModel,
          source: graphQLResult.source
        ))
        self.currentPage = page
        mergeStrategy.resultHandler(result: .success(model))
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
    // Remove and cancel all watchers aside from the first page
    guard let initialWatcher = watchers.first else { return }
    let subsequentWatchers = watchers.dropFirst()
    subsequentWatchers.forEach { $0.cancel() }
    watchers = [initialWatcher]
    initialWatcher.refetch(cachePolicy: cachePolicy)
  }

  /// Fetches the next page
  @discardableResult public func fetchMore(cachePolicy: CachePolicy = .fetchIgnoringCacheData) -> Bool {
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

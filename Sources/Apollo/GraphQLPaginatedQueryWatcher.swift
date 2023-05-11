#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

public typealias Cursor = String

/// Handles pagination in the queue by managing multiple query watchers.
final class GraphQLPaginatedQueryWatcher<Query: GraphQLQuery, T>: Cancellable {

  public struct Page {
    let hasNextPage: Bool
    let endCursor: Cursor?
  }

  /// Given a page, create a query of the type this watcher is responsible for
  public typealias CreatePageQuery = (Page) -> Query?

  private typealias ResultHandler = (Result<GraphQLResult<Query.Data>, Error>) -> Void

  private let client: any ApolloClientProtocol

  private var initialWatcher: GraphQLQueryWatcher<Query>?
  private var subsequentWatchers: [GraphQLQueryWatcher<Query>] = []

  private let createPageQuery: CreatePageQuery
  private let nextPageTransform: (T?, T) -> T

  private var model: T? // 🚗
  private var resultHandler: ResultHandler?
  private var callbackQueue: DispatchQueue
  private var page: Page?

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
    query: Query,
    createPageQuery: @escaping CreatePageQuery,
    transform: @escaping (Query.Data) -> (T?, Page?)?,
    nextPageTransform: @escaping (T?, T) -> T,
    onReceiveResults: @escaping (Result<T, Error>) -> Void
  ) {
    self.callbackQueue = callbackQueue
    self.client = client
    self.createPageQuery = createPageQuery
    self.nextPageTransform = nextPageTransform

    let resultHandler: ResultHandler = { [weak self] result in
      guard let self else { return }
      switch result {
      case .failure(let error):
        guard !error.wasCancelled else { return }
        // Forward all errors aside from network cancellation errors
        onReceiveResults(.failure(error))
      case .success(let graphQLResult):
        guard let data = graphQLResult.data,
              let (transformedModel, page) = transform(data),
              let transformedModel
        else { return }
        let model = nextPageTransform(self.model, transformedModel)
        self.model = model
        self.page = page
        onReceiveResults(.success(model))
      }
    }

    self.resultHandler = resultHandler
    initialWatcher = client.watch(
      query: query,
      cachePolicy: .returnCacheDataAndFetch,
      callbackQueue: callbackQueue,
      resultHandler: resultHandler
    )
  }

  public func fetch() {
    model = nil
    initialWatcher?.refetch()
    cancelSubsequentWatchers()
  }

  @discardableResult
  public func fetchMore() -> Bool {
    guard let page,
          page.hasNextPage,
          let nextPageQuery = createPageQuery(page),
          let resultHandler
    else { return false }

    let nextPageWatcher = client.watch(
      query: nextPageQuery,
      cachePolicy: .fetchIgnoringCacheData,
      callbackQueue: callbackQueue
    ) { result in
      resultHandler(result)
    }
    subsequentWatchers.append(nextPageWatcher)

    return true
  }

  public func cancel() {
    initialWatcher?.cancel()
    cancelSubsequentWatchers()
  }

  private func cancelSubsequentWatchers() {
    subsequentWatchers.forEach { $0.cancel() }
    subsequentWatchers.removeAll()
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

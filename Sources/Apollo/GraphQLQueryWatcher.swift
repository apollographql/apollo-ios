import Dispatch

/// A `GraphQLQueryWatcher` is responsible for watching the store, and calling the result handler with a new result whenever any of the data the previous result depends on changes.
///
/// NOTE: The store retains the watcher while subscribed. You must call `cancel()` on your query watcher when you no longer need results. Failure to call `cancel()` before releasing your reference to the returned watcher will result in a memory leak.
public final class GraphQLQueryWatcher<Query: GraphQLQuery>: Cancellable, ApolloStoreSubscriber {
  weak var client: ApolloClientProtocol?
  public let query: Query
  let resultHandler: GraphQLResultHandler<Query.Data>

  private var context = 0

  private weak var fetching: Cancellable?

  private var dependentKeys: Set<CacheKey>?

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - client: The client protocol to pass in
  ///   - query: The query to watch
  ///   - resultHandler: The result handler to call with changes.
  public init(client: ApolloClientProtocol,
              query: Query,
              resultHandler: @escaping GraphQLResultHandler<Query.Data>) {
    self.client = client
    self.query = query
    self.resultHandler = resultHandler

    client.store.subscribe(self)
  }

  /// Refetch a query from the server.
  public func refetch() {
    fetch(cachePolicy: .fetchIgnoringCacheData)
  }

  func fetch(cachePolicy: CachePolicy) {
    // Cancel anything already in flight before starting a new fetch
    fetching?.cancel()
    fetching = client?.fetch(query: query, cachePolicy: cachePolicy, context: &context, queue: .main) { [weak self] result in
      guard let `self` = self else { return }

      switch result {
      case .success(let graphQLResult):
        self.dependentKeys = graphQLResult.dependentKeys
      case .failure:
        break
      }

      self.resultHandler(result)
    }
  }

  /// Cancel any in progress fetching operations and unsubscribe from the store.
  public func cancel() {
    fetching?.cancel()
    client?.store.unsubscribe(self)
  }

  func store(_ store: ApolloStore,
             didChangeKeys changedKeys: Set<CacheKey>,
             context: UnsafeMutableRawPointer?) {
    if context == &self.context { return }

    guard let dependentKeys = dependentKeys else { return }

    if !dependentKeys.isDisjoint(with: changedKeys) {
      fetch(cachePolicy: .returnCacheDataElseFetch)
    }
  }
}

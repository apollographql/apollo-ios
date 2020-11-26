import Foundation
#if !COCOAPODS
import ApolloCore
#endif

/// A `GraphQLQueryWatcher` is responsible for watching the store, and calling the result handler with a new result whenever any of the data the previous result depends on changes.
///
/// NOTE: The store retains the watcher while subscribed. You must call `cancel()` on your query watcher when you no longer need results. Failure to call `cancel()` before releasing your reference to the returned watcher will result in a memory leak.
public final class GraphQLQueryWatcher<Query: GraphQLQuery>: Cancellable, ApolloStoreSubscriber {
  weak var client: ApolloClientProtocol?
  public let query: Query
  let resultHandler: GraphQLResultHandler<Query.Data>

  private let contextIdentifier = UUID()

  private var fetching: Atomic<Cancellable?> = Atomic(nil)

  private var dependentKeys: Atomic<Set<CacheKey>?> = Atomic(nil)

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

  // Watchers always call result handlers on the main queue.
  private let callbackQueue: DispatchQueue = .main

  func fetch(cachePolicy: CachePolicy) {
    fetching.mutate {
      // Cancel anything already in flight before starting a new fetch
      $0?.cancel()
      $0 = client?.fetch(query: query, cachePolicy: cachePolicy, contextIdentifier: self.contextIdentifier, queue: callbackQueue) { [weak self] result in
        guard let self = self else { return }

        switch result {
        case .success(let graphQLResult):
          self.dependentKeys.mutate {
            $0 = graphQLResult.dependentKeys
          }
        case .failure:
          break
        }

        self.resultHandler(result)
      }
    }
  }

  /// Cancel any in progress fetching operations and unsubscribe from the store.
  public func cancel() {
    fetching.value?.cancel()
    client?.store.unsubscribe(self)
  }

  func store(_ store: ApolloStore,
             didChangeKeys changedKeys: Set<CacheKey>,
             contextIdentifier: UUID?) {
    if
      let incomingIdentifier = contextIdentifier,
      incomingIdentifier == self.contextIdentifier {
        // This is from changes to the keys made from the `fetch` method above,
        // changes will be returned through that and do not need to be returned
        // here as well.
        return
    }
    
    guard let dependentKeys = self.dependentKeys.value else {
      // This query has nil dependent keys, so nothing that changed will affect it.
      return
    }
    
    if !dependentKeys.isDisjoint(with: changedKeys) {
      // First, attempt to reload the query from the cache directly, in order not to interrupt any in-flight server-side fetch.
      store.load(query: self.query) { [weak self] result in
        guard let self = self else { return }
        
        switch result {
        case .success(let graphQLResult):
          self.callbackQueue.async { [weak self] in
            guard let self = self else {
              return
            }
            
            self.dependentKeys.mutate {
              $0 = graphQLResult.dependentKeys
            }
            self.resultHandler(result)
          }
        case .failure:
          // If the cache fetch is not successful, for instance if the data is missing, refresh from the server.
          self.fetch(cachePolicy: .fetchIgnoringCacheData)
        }
      }
    }
  }
}

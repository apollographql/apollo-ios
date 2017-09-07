import Dispatch

/// A `GraphQLQueryWatcher` is responsible for watching the store, and calling the result handler with a new result whenever any of the data the previous result depends on changes.
public final class GraphQLQueryWatcher<Query: GraphQLQuery>: Cancellable, ApolloStoreSubscriber {
  weak var client: ApolloClient?
  let query: Query
  let handlerQueue: DispatchQueue
  let resultHandler: OperationResultHandler<Query>
  
  private var context = 0
  
  private weak var fetching: Cancellable?
  
  private var dependentKeys: Set<CacheKey>?
  
  init(client: ApolloClient, query: Query, handlerQueue: DispatchQueue, resultHandler: @escaping OperationResultHandler<Query>) {
    self.client = client
    self.query = query
    self.handlerQueue = handlerQueue
    self.resultHandler = resultHandler
    
    client.store.subscribe(self)
  }
  
  /// Refetch a query from the server.
  public func refetch() {
    fetch(cachePolicy: .fetchIgnoringCacheData)
  }
  
  func fetch(cachePolicy: CachePolicy) {
    fetching = client?._fetch(query: query, cachePolicy: cachePolicy, context: &context, queue: handlerQueue) { (result, error) in
      self.dependentKeys = result?.dependentKeys
      self.resultHandler(result, error)
    }
  }
  
  /// Cancel any in progress fetching operations and unsubscribe from the store.
  public func cancel() {
    fetching?.cancel()
    client?.store.unsubscribe(self)
  }
  
  func store(_ store: ApolloStore, didChangeKeys changedKeys: Set<CacheKey>, context: UnsafeMutableRawPointer?) {
    if context == &self.context { return }
    
    guard let dependentKeys = dependentKeys else { return }
    
    if !dependentKeys.isDisjoint(with: changedKeys) {
      fetch(cachePolicy: .returnCacheDataElseFetch)
    }
  }
}

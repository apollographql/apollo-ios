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
  
  public func refetch() {
    fetch(cachePolicy: .fetchIgnoringCacheData)
  }
  
  func fetch(cachePolicy: CachePolicy) {
    fetching = client?.fetch(query: query, cachePolicy: cachePolicy, context: &context, handlerQueue: handlerQueue) { (result, error) in
      self.dependentKeys = result?.dependentKeys
      self.resultHandler(result, error)
    }
  }
  
  public func cancel() {
    fetching?.cancel()
    client?.store.unsubscribe(self)
  }
  
  func store(_ store: ApolloStore, didChangeKeys changedKeys: Set<CacheKey>, context: UnsafeMutableRawPointer?) {
    guard let client = client else { return }
    
    if context == &self.context { return }
    
    print("changedKeys: \(changedKeys)")
        
    if let dependentKeys = dependentKeys, dependentKeys.isDisjoint(with: changedKeys) {
      return
    }
    
    store.load(query: query, cacheKeyForObject: client.cacheKeyForObject) { (result, error) in
      self.handlerQueue.async {
        self.dependentKeys = result?.dependentKeys
        self.resultHandler(result, error)
      }
    }
  }
}

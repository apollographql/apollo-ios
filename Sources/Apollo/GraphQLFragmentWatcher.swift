
public final class GraphQLFragmentWatcher<Fragment: GraphQLFragment>: ApolloStoreSubscriber {
  public typealias FragmentResultHandler = (_ result: GraphQLResult<Fragment>?, _ error: Error?) -> Void
  
  weak var client: ApolloClient?
  let cacheKey: CacheKey
  let handlerQueue: DispatchQueue
  let resultHandler: FragmentResultHandler
  
  private var context = 0
  private weak var fetching: Cancellable?
  private var dependentKeys: Set<CacheKey>?
  
  init(
    client: ApolloClient,
    forType ofFragment: Fragment.Type,
    cacheKey: CacheKey,
    handlerQueue: DispatchQueue,
    resultHandler: @escaping FragmentResultHandler
  ) {
    self.client = client
    self.cacheKey = cacheKey
    self.handlerQueue = handlerQueue
    self.resultHandler = resultHandler
    
    client.store.subscribe(self)
  }
  
  func fetch() {
    client?.store.withinReadTransaction { transaction in
      let mapper = GraphQLSelectionSetMapper<Fragment>()
      let dependencyTracker = GraphQLDependencyTracker()
      
      return try transaction.execute(
        selections: Fragment.selections,
        onObjectWithKey: self.cacheKey,
        variables: [:],
        accumulator: zip(mapper, dependencyTracker)
      )
    }.andThen { [weak self] (data: Fragment, dependentKeys: Set<CacheKey>) in
      guard let `self` = self else { return }
      self.dependentKeys = dependentKeys
      self.resultHandler(GraphQLResult(data: data, errors: nil, source: .cache, dependentKeys: dependentKeys), nil)
    }
  }
  
  func store(_ store: ApolloStore, didChangeKeys changedKeys: Set<CacheKey>, context: UnsafeMutableRawPointer?) {
    if context == &self.context { return }
    
    guard let dependentKeys = dependentKeys else { return }
    if !dependentKeys.isDisjoint(with: changedKeys) {
      fetch()
    }
  }
  
  /// Cancel any in progress fetching operations and unsubscribe from the store.
  public func cancel() {
    fetching?.cancel()
    client?.store.unsubscribe(self)
  }
}

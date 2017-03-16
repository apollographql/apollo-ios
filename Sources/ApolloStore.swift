func rootKey<Operation: GraphQLOperation>(forOperation operation: Operation) -> CacheKey {
  switch operation {
  case is GraphQLQuery:
    return "QUERY_ROOT"
  case is GraphQLMutation:
    return "MUTATION_ROOT"
  default:
    preconditionFailure("Unknown operation type")
  }
}

/// A function that returns a cache key for a particular result object. If it returns `nil`, a default cache key based on the field path will be used.
public typealias CacheKeyForObject = (_ object: JSONObject) -> JSONValue?

protocol ApolloStoreSubscriber: class {
  func store(_ store: ApolloStore, didChangeKeys changedKeys: Set<CacheKey>, context: UnsafeMutableRawPointer?)
}

/// The `ApolloStore` class acts as a local cache for normalized GraphQL results.
public final class ApolloStore {
  public var cacheKeyForObject: CacheKeyForObject?

  private let queue: DispatchQueue
  
  private let cache: NormalizedCache

  // We need a separate read/write lock for cache access because cache operations are
  // asynchronous and we don't want to block the dispatch threads
  private let cacheLock = ReadWriteLock()
  
  private var subscribers: [ApolloStoreSubscriber] = []
  
  public init(cache: NormalizedCache) {
    self.cache = cache
    queue = DispatchQueue(label: "com.apollographql.ApolloStore", attributes: .concurrent)
  }
  
  convenience init(records: RecordSet = RecordSet()) {
    self.init(cache: InMemoryNormalizedCache(records: records))
  }
  
  func publish(records: RecordSet, context: UnsafeMutableRawPointer?) {
    queue.async(flags: .barrier) {
      self.cacheLock.withWriteLock {
        self.cache.merge(records: records)
      }.andThen { changedKeys in
        for subscriber in self.subscribers {
          subscriber.store(self, didChangeKeys: changedKeys, context: context)
        }
      }.catch { error in
        preconditionFailure(String(describing: error))
      }
    }
  }
  
  func subscribe(_ subscriber: ApolloStoreSubscriber) {
    queue.async(flags: .barrier) {
      self.subscribers.append(subscriber)
    }
  }
  
  func unsubscribe(_ subscriber: ApolloStoreSubscriber) {
    queue.async(flags: .barrier) {
      self.subscribers = self.subscribers.filter({ $0 !== subscriber })
    }
  }
  
  func load<Query: GraphQLQuery>(query: Query, resultHandler: @escaping OperationResultHandler<Query>) {
    queue.async {
      self.cacheLock.lockForReading()
      
      let loader: DataLoader<CacheKey, Record?>
      loader = DataLoader(self.cache.loadRecords)
      
      let rootKey = Apollo.rootKey(forOperation: query)
      
      loader[rootKey].flatMap { rootRecord in
        let rootObject = rootRecord?.fields
        
        func complete(value: Any?) -> Promise<JSONValue?> {
          if let reference = value as? Reference {
            return loader[reference.key].map { $0?.fields }
          } else if let array = value as? Array<Any?> {
            let completedValues = array.map(complete)
            // Make sure to dispatch on a global queue and not on the local queue,
            // because that could result in a deadlock (if someone is waiting for the write lock).
            return whenAll(completedValues, notifyOn: DispatchQueue.global()).map { $0 }
          } else {
            return Promise(fulfilled: value)
          }
        }
        
        let executor = GraphQLExecutor { object, info in
          let value = (object ?? rootObject)?[info.cacheKeyForField]
          return complete(value: value)
        }
        
        executor.dispatchDataLoads = loader.dispatch
        executor.cacheKeyForObject = self.cacheKeyForObject
        
        let mapper = GraphQLResultMapper<Query.Data>()
        let dependencyTracker = GraphQLDependencyTracker()
        
        return try executor.execute(selectionSet: Query.selectionSet, rootKey: rootKey, variables: query.variables, accumulator: zip(mapper, dependencyTracker))
      }.andThen { (data: Query.Data, dependentKeys: Set<CacheKey>) in
        resultHandler(GraphQLResult(data: data, errors: nil, dependentKeys: dependentKeys), nil)
      }.catch { error in
        resultHandler(nil, error)
      }.finally {
        self.cacheLock.unlock()
      }
      
      loader.dispatch()
    }
  }
}

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

protocol ApolloStoreSubscriber: class {
  func store(_ store: ApolloStore, didChangeKeys changedKeys: Set<CacheKey>, context: UnsafeMutableRawPointer?)
}

/// The `ApolloStore` class acts as a local cache for normalized GraphQL results.
public final class ApolloStore {  
  private let queue: DispatchQueue
  private let lock = ReadWriteLock()
  
  private let cache: NormalizedCache
  private var subscribers: [ApolloStoreSubscriber] = []
  
  public init(cache: NormalizedCache) {
    self.cache = cache
    queue = DispatchQueue(label: "com.apollographql.ApolloStore", attributes: .concurrent)
  }
  
  convenience init(records: RecordSet = RecordSet()) {
    self.init(cache: InMemoryCache(records: records))
  }
  
  func publish(records: RecordSet, context: UnsafeMutableRawPointer?) {
    queue.async(flags: .barrier) {
      let changedKeys = self.lock.withWriteLock {
        self.cache.merge(records: records)
      }
      
      for subscriber in self.subscribers {
        subscriber.store(self, didChangeKeys: changedKeys, context: context)
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
  
  func load<Query: GraphQLQuery>(query: Query, cacheKeyForObject: CacheKeyForObject?, resultHandler: @escaping OperationResultHandler<Query>) {
    queue.async {
      self.lock.lockForReading()
      
      let rootKey = Apollo.rootKey(forOperation: query)
      
      self.cache.loadRecord(forKey: rootKey).flatMap { rootRecord in
        let rootObject = rootRecord?.fields
        
        let executor = GraphQLExecutor { object, info in
          let value = (object ?? rootObject)?[info.cacheKeyForField]
          return self.complete(value: value)
        }
        
        executor.cacheKeyForObject = cacheKeyForObject
        
        let mapper = GraphQLResultMapper<Query.Data>()
        let dependencyTracker = GraphQLDependencyTracker()
        
        return try executor.execute(selectionSet: Query.selectionSet, rootKey: rootKey, variables: query.variables, accumulator: zip(mapper, dependencyTracker))
      }.andThen { (data: Query.Data, dependentKeys: Set<CacheKey>) in
        resultHandler(GraphQLResult(data: data, errors: nil, dependentKeys: dependentKeys), nil)
      }.catch { error in
        resultHandler(nil, error)
      }.finally {
        self.lock.unlock()
      }
    }
  }
  
  private func complete(value: Any?) -> Promise<JSONValue?> {
    if let reference = value as? Reference {
      return self.cache.loadRecord(forKey: reference.key).map { $0?.fields }
    } else if let array = value as? Array<Any?> {
      let completedValues = array.map(complete)
      // Make sure to dispatch on a global queue, and not on the serial queue
      // because that would result in a deadlock.
      return whenAll(completedValues, notifyOn: DispatchQueue.global()).map { $0 }
    } else {
      return Promise(fulfilled: value)
    }
  }
}

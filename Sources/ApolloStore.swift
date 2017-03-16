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
  
  func withinReadTransaction<T>(_ body: @escaping (ReadTransaction) throws -> Promise<T>) -> Promise<T> {
    return Promise<ReadTransaction> { fulfill, reject in
      self.queue.async {
        self.cacheLock.lockForReading()
        
        let loader: DataLoader<CacheKey, Record?>
        loader = DataLoader(self.cache.loadRecords)
        
        fulfill(ReadTransaction(loader: loader, cacheKeyForObject: self.cacheKeyForObject))
      }
    }.flatMap(body)
     .finally {
      self.cacheLock.unlock()
    }
  }
  
  func load<Query: GraphQLQuery>(query: Query) -> Promise<GraphQLResult<Query.Data>> {
    return withinReadTransaction { transaction in
      let mapper = GraphQLResultMapper<Query.Data>()
      let dependencyTracker = GraphQLDependencyTracker()
      
      return try transaction.execute(selectionSet: Query.selectionSet, onObjectWithKey: rootKey(forOperation: query), variables: query.variables, accumulator: zip(mapper, dependencyTracker))
    }.map { (data: Query.Data, dependentKeys: Set<CacheKey>) in
      GraphQLResult(data: data, errors: nil, dependentKeys: dependentKeys)
    }
  }
  
  func load<Query: GraphQLQuery>(query: Query, resultHandler: @escaping OperationResultHandler<Query>) {
    load(query: query).andThen { result in
      resultHandler(result, nil)
    }.catch { error in
      resultHandler(nil, error)
    }
  }
  
  public class ReadTransaction {
    private let loader: DataLoader<CacheKey, Record?>
    private var executor: GraphQLExecutor!
    
    init(loader: DataLoader<CacheKey, Record?>, cacheKeyForObject: CacheKeyForObject?) {
      self.loader = loader
      
      executor = GraphQLExecutor { object, info in
        let value = object?[info.cacheKeyForField]
        return self.complete(value: value)
      }
      
      executor.dispatchDataLoads = loader.dispatch
      executor.cacheKeyForObject = cacheKeyForObject
    }
    
    private final func complete(value: Any?) -> Promise<JSONValue?> {
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
    
    final func execute<Accumulator: GraphQLResultAccumulator>(selectionSet: [Selection], onObjectWithKey key: CacheKey, variables: GraphQLMap?, accumulator: Accumulator) throws -> Promise<Accumulator.FinalResult> {
      return loadObject(forKey: key).flatMap { object in
        try self.executor.execute(selectionSet: selectionSet, on: object, withKey: key, variables: variables, accumulator: accumulator)
      }
    }
    
    private final func loadObject(forKey key: CacheKey) -> Promise<JSONObject> {
      defer { loader.dispatch() }
      
      return loader[key].map { record in
        guard let object = record?.fields else { throw JSONDecodingError.missingValue }
        return object
      }
    }
  }
}

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
  
  func publish(records: RecordSet, context: UnsafeMutableRawPointer? = nil) -> Promise<Void> {
    return Promise<Void> { fulfill, reject in
      queue.async(flags: .barrier) {
        self.cacheLock.withWriteLock {
          self.cache.merge(records: records)
        }.andThen { changedKeys in
          for subscriber in self.subscribers {
            subscriber.store(self, didChangeKeys: changedKeys, context: context)
          }
          fulfill()
        }
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
  
  public func withinReadTransaction<T>(_ body: @escaping (ReadTransaction) throws -> Promise<T>) -> Promise<T> {
    return Promise<ReadTransaction> { fulfill, reject in
      self.queue.async {
        self.cacheLock.lockForReading()
        
        fulfill(ReadTransaction(cache: self.cache, cacheKeyForObject: self.cacheKeyForObject))
      }
    }.flatMap(body)
     .finally {
      self.cacheLock.unlock()
    }
  }
  
  public func withinReadTransaction<T>(_ body: @escaping (ReadTransaction) throws -> T) -> Promise<T> {
    return withinReadTransaction {
      Promise(fulfilled: try body($0))
    }
  }
  
  public func withinReadWriteTransaction<T>(_ body: @escaping (ReadWriteTransaction) throws -> Promise<T>) -> Promise<T> {
    return Promise<ReadWriteTransaction> { fulfill, reject in
      self.queue.async(flags: .barrier) {
        self.cacheLock.lockForWriting()
        
        fulfill(ReadWriteTransaction(cache: self.cache, cacheKeyForObject: self.cacheKeyForObject))
      }
    }.flatMap(body)
     .finally {
      self.cacheLock.unlock()
    }
  }
  
  public func withinReadWriteTransaction<T>(_ body: @escaping (ReadWriteTransaction) throws -> T) -> Promise<T> {
    return withinReadWriteTransaction {
      Promise(fulfilled: try body($0))
    }
  }
  
  func load<Query: GraphQLQuery>(query: Query) -> Promise<GraphQLResult<Query.Data>> {
    return withinReadTransaction { transaction in
      let mapper = GraphQLSelectionSetMapper<Query.Data>()
      let dependencyTracker = GraphQLDependencyTracker()
      
      return try transaction.execute(selections: Query.Data.selections, onObjectWithKey: rootKey(forOperation: query), variables: query.variables, accumulator: zip(mapper, dependencyTracker))
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
    fileprivate let cache: NormalizedCache
    fileprivate let cacheKeyForObject: CacheKeyForObject?
    
    fileprivate lazy var loader: DataLoader<CacheKey, Record?> = DataLoader(self.cache.loadRecords)
    
    fileprivate lazy var executor: GraphQLExecutor = {
      let executor = GraphQLExecutor { object, info in
        let value = object[info.cacheKeyForField]
        return self.complete(value: value)
      }
      
      executor.dispatchDataLoads = self.loader.dispatch
      executor.cacheKeyForObject = self.cacheKeyForObject
      return executor
    }()
    
    init(cache: NormalizedCache, cacheKeyForObject: CacheKeyForObject?) {
      self.cache = cache
      self.cacheKeyForObject = cacheKeyForObject
    }
    
    public func read<Query: GraphQLQuery>(query: Query) throws -> Query.Data {
      return try readSelectionSet(ofType: Query.Data.self, withKey: rootKey(forOperation: query), variables: query.variables)
    }
    
    public func readFragment<Fragment: GraphQLFragment>(ofType fragmentType: Fragment.Type, withKey key: CacheKey, variables: GraphQLMap? = nil) throws -> Fragment {
      return try readSelectionSet(ofType: Fragment.self, withKey: key, variables: variables)
    }
    
    public func readSelectionSet<SelectionSet: GraphQLSelectionSet>(ofType selectionSetType: SelectionSet.Type, withKey key: CacheKey, variables: GraphQLMap? = nil) throws -> SelectionSet {
      let mapper = GraphQLSelectionSetMapper<SelectionSet>()
      return try execute(selections: selectionSetType.selections, onObjectWithKey: key, variables: variables, accumulator: mapper).await()
    }
    
    public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
      return cache.loadRecords(forKeys: keys)
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
    
    final func execute<Accumulator: GraphQLResultAccumulator>(selections: [Selection], onObjectWithKey key: CacheKey, variables: GraphQLMap?, accumulator: Accumulator) throws -> Promise<Accumulator.FinalResult> {
      return loadObject(forKey: key).flatMap { object in
        try self.executor.execute(selections: selections, on: object, withKey: key, variables: variables, accumulator: accumulator)
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
  
  public final class ReadWriteTransaction: ReadTransaction {
    public func update<Query: GraphQLQuery>(query: Query, _ body: (inout Query.Data) throws -> Void) throws {
      var data = try read(query: query)
      try body(&data)
      try write(data: data, forQuery: query)
    }
    
    public func updateFragment<Fragment: GraphQLFragment>(ofType fragmentType: Fragment.Type, withKey key: CacheKey, variables: GraphQLMap? = nil, _ body: (inout Fragment) throws -> Void) throws {
      var fragment = try readFragment(ofType: fragmentType, withKey: key, variables: variables)
      try body(&fragment)
      try write(fragment: fragment, withKey: key, variables: variables)
    }
    
    public func updateSelectionSet<SelectionSet: GraphQLSelectionSet>(ofType selectionSetType: SelectionSet.Type, withKey key: CacheKey, variables: GraphQLMap? = nil, _ body: (inout SelectionSet) throws -> Void) throws {
      var selectionSet = try readSelectionSet(ofType: selectionSetType, withKey: key, variables: variables)
      try body(&selectionSet)
      try write(selectionSet: selectionSet, withKey: key, variables: variables)
    }
    
    public func write<Query: GraphQLQuery>(data: Query.Data, forQuery query: Query) throws {
      try write(selectionSet: data, withKey: rootKey(forOperation: query), variables: query.variables)
    }
    
    public func write(fragment: GraphQLFragment, withKey key: CacheKey, variables: GraphQLMap? = nil) throws {
      try write(selectionSet: fragment, withKey: key, variables: variables)
    }
    
    public func write(selectionSet: GraphQLSelectionSet, withKey key: CacheKey, variables: GraphQLMap? = nil) throws {
      try write(object: selectionSet.jsonObject, forSelectionSet: type(of: selectionSet), withKey: key, variables: variables)
    }
    
    private func write(object: JSONObject, forSelectionSet selectionSet: GraphQLSelectionSet.Type, withKey key: CacheKey, variables: GraphQLMap?) throws {
      let normalizer = GraphQLResultNormalizer()
      try self.executor.execute(selections: selectionSet.selections, on: object, withKey: key, variables: variables, accumulator: normalizer)
      .flatMap {
        self.cache.merge(records: $0).map { _ in }
      }.await()
    }
  }
}

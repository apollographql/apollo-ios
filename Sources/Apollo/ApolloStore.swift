import Dispatch

/// A function that returns a cache key for a particular result object. If it returns `nil`, a default cache key based on the field path will be used.
public typealias CacheKeyForObject = (_ object: JSONObject) -> JSONValue?
public typealias DidChangeKeysFunc = (Set<CacheKey>, UnsafeMutableRawPointer?) -> Void

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

  fileprivate func didChangeKeys(_ changedKeys: Set<CacheKey>, context: UnsafeMutableRawPointer?) {
    for subscriber in self.subscribers {
      subscriber.store(self, didChangeKeys: changedKeys, context: context)
    }
  }

  func clearCache() -> Promise<Void> {
    return Promise<Void> { fulfill, reject in
      queue.async(flags: .barrier) {
        self.cacheLock.withWriteLock {
          self.cache.clear()
        }.andThen {
          fulfill(())
        }
      }
    }
  }

  func publish(records: RecordSet, context: UnsafeMutableRawPointer? = nil) -> Promise<Void> {
    return Promise<Void> { fulfill, reject in
      queue.async(flags: .barrier) {
        self.cacheLock.withWriteLock {
          self.cache.merge(records: records)
        }.andThen { changedKeys in
          self.didChangeKeys(changedKeys, context: context)
          fulfill(())
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
        fulfill(ReadWriteTransaction(cache: self.cache, cacheKeyForObject: self.cacheKeyForObject, updateChangedKeysFunc: self.didChangeKeys))
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

      return try transaction.execute(selections: Query.Data.selections, onObjectWithKey: Query.rootCacheKey, variables: query.variables, accumulator: zip(mapper, dependencyTracker))
    }.map { (data: Query.Data, dependentKeys: Set<CacheKey>) in
      GraphQLResult(data: data, errors: nil, source:.cache, dependentKeys: dependentKeys)
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

    fileprivate func makeExecutor() -> GraphQLExecutor {
      let executor = GraphQLExecutor { object, info in
        let value = object[info.cacheKeyForField]
        return self.complete(value: value)
      }

      executor.dispatchDataLoads = self.loader.dispatch
      executor.cacheKeyForObject = self.cacheKeyForObject
      return executor
    }

    init(cache: NormalizedCache, cacheKeyForObject: CacheKeyForObject?) {
      self.cache = cache
      self.cacheKeyForObject = cacheKeyForObject
    }

    public func read<Query: GraphQLQuery>(query: Query) throws -> Query.Data {
      return try readObject(ofType: Query.Data.self, withKey: Query.rootCacheKey, variables: query.variables)
    }

    public func readObject<SelectionSet: GraphQLSelectionSet>(ofType type: SelectionSet.Type, withKey key: CacheKey, variables: GraphQLMap? = nil) throws -> SelectionSet {
      let mapper = GraphQLSelectionSetMapper<SelectionSet>()
      return try execute(selections: type.selections, onObjectWithKey: key, variables: variables, accumulator: mapper).await()
    }

    public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
      return cache.loadRecords(forKeys: keys)
    }

    private final func complete(value: Any?) -> ResultOrPromise<JSONValue?> {
      if let reference = value as? Reference {
        return .promise(loader[reference.key].map { $0?.fields })
      } else if let array = value as? Array<Any?> {
        let completedValues = array.map(complete)
        // Make sure to dispatch on a global queue and not on the local queue,
        // because that could result in a deadlock (if someone is waiting for the write lock).
        return whenAll(completedValues, notifyOn: .global()).map { $0 }
      } else {
        return .result(.success(value))
      }
    }

    final func execute<Accumulator: GraphQLResultAccumulator>(selections: [GraphQLSelection], onObjectWithKey key: CacheKey, variables: GraphQLMap?, accumulator: Accumulator) throws -> Promise<Accumulator.FinalResult> {
      return loadObject(forKey: key).flatMap { object in
        try self.makeExecutor().execute(selections: selections, on: object, withKey: key, variables: variables, accumulator: accumulator)
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

    fileprivate var updateChangedKeysFunc: DidChangeKeysFunc?

    init(cache: NormalizedCache, cacheKeyForObject: CacheKeyForObject?, updateChangedKeysFunc: @escaping DidChangeKeysFunc) {
        self.updateChangedKeysFunc = updateChangedKeysFunc
        super.init(cache: cache, cacheKeyForObject: cacheKeyForObject)
    }

    public func update<Query: GraphQLQuery>(query: Query, _ body: (inout Query.Data) throws -> Void) throws {
      var data = try read(query: query)
      try body(&data)
      try write(data: data, forQuery: query)
    }

    public func updateObject<SelectionSet: GraphQLSelectionSet>(ofType type: SelectionSet.Type, withKey key: CacheKey, variables: GraphQLMap? = nil, _ body: (inout SelectionSet) throws -> Void) throws {
      var object = try readObject(ofType: type, withKey: key, variables: variables)
      try body(&object)
      try write(object: object, withKey: key, variables: variables)
    }

    public func write<Query: GraphQLQuery>(data: Query.Data, forQuery query: Query) throws {
      try write(object: data, withKey: Query.rootCacheKey, variables: query.variables)
    }

    public func write(object: GraphQLSelectionSet, withKey key: CacheKey, variables: GraphQLMap? = nil) throws {
      try write(object: object.jsonObject, forSelections: type(of: object).selections, withKey: key, variables: variables)
    }

    private func write(object: JSONObject, forSelections selections: [GraphQLSelection], withKey key: CacheKey, variables: GraphQLMap?) throws {
      let normalizer = GraphQLResultNormalizer()
      try self.makeExecutor().execute(selections: selections, on: object, withKey: key, variables: variables, accumulator: normalizer)
      .flatMap {
        self.cache.merge(records: $0)
      }.andThen { changedKeys in
        if let didChangeKeysFunc = self.updateChangedKeysFunc {
            didChangeKeysFunc(changedKeys, nil)
        }
      }.await()
    }
  }
}

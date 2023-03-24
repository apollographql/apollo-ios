import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

public typealias DidChangeKeysFunc = (Set<CacheKey>, UUID?) -> Void

protocol ApolloStoreSubscriber: AnyObject {
  
  /// A callback that can be received by subscribers when keys are changed within the database
  ///
  /// - Parameters:
  ///   - store: The store which made the changes
  ///   - changedKeys: The list of changed keys
  ///   - contextIdentifier: [optional] A unique identifier for the request that kicked off this change, to assist in de-duping cache hits for watchers.
  func store(_ store: ApolloStore,
             didChangeKeys changedKeys: Set<CacheKey>,
             contextIdentifier: UUID?)
}

/// The `ApolloStore` class acts as a local cache for normalized GraphQL results.
public class ApolloStore {
  private let cache: NormalizedCache
  private let queue: DispatchQueue

  private var subscribers: [ApolloStoreSubscriber] = []

  /// Designated initializer
  /// - Parameters:
  ///   - cache: An instance of `normalizedCache` to use to cache results.
  ///            Defaults to an `InMemoryNormalizedCache`.
  public init(cache: NormalizedCache = InMemoryNormalizedCache()) {
    self.cache = cache
    self.queue = DispatchQueue(label: "com.apollographql.ApolloStore", attributes: .concurrent)
  }

  fileprivate func didChangeKeys(_ changedKeys: Set<CacheKey>, identifier: UUID?) {
    for subscriber in self.subscribers {
      subscriber.store(self, didChangeKeys: changedKeys, contextIdentifier: identifier)
    }
  }

  /// Clears the instance of the cache. Note that a cache can be shared across multiple `ApolloClient` objects, so clearing that underlying cache will clear it for all clients.
  ///
  /// - Parameters:
  ///   - callbackQueue: The queue to call the completion block on. Defaults to `DispatchQueue.main`.
  ///   - completion: [optional] A completion block to be called after records are merged into the cache.
  public func clearCache(callbackQueue: DispatchQueue = .main, completion: ((Result<Void, Swift.Error>) -> Void)? = nil) {
    queue.async(flags: .barrier) {
      let result = Result { try self.cache.clear() }
      DispatchQueue.returnResultAsyncIfNeeded(
        on: callbackQueue,
        action: completion,
        result: result
      )
    }
  }

  /// Merges a `RecordSet` into the normalized cache.
  /// - Parameters:
  ///   - records: The records to be merged into the cache.
  ///   - identifier: [optional] A unique identifier for the request that kicked off this change,
  ///                 to assist in de-duping cache hits for watchers.
  ///   - callbackQueue: The queue to call the completion block on. Defaults to `DispatchQueue.main`.
  ///   - completion: [optional] A completion block to be called after records are merged into the cache.
  public func publish(records: RecordSet, identifier: UUID? = nil, callbackQueue: DispatchQueue = .main, completion: ((Result<Void, Swift.Error>) -> Void)? = nil) {
    queue.async(flags: .barrier) {
      do {
        let changedKeys = try self.cache.merge(records: records)
        self.didChangeKeys(changedKeys, identifier: identifier)
        DispatchQueue.returnResultAsyncIfNeeded(
          on: callbackQueue,
          action: completion,
          result: .success(())
        )
      } catch {
        DispatchQueue.returnResultAsyncIfNeeded(
          on: callbackQueue,
          action: completion,
          result: .failure(error)
        )
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

  /// Performs an operation within a read transaction
  ///
  /// - Parameters:
  ///   - body: The body of the operation to perform.
  ///   - callbackQueue: [optional] The callback queue to use to perform the completion block on. Will perform on the current queue if not provided. Defaults to nil.
  ///   - completion: [optional] The completion block to perform when the read transaction completes. Defaults to nil.
  public func withinReadTransaction<T>(
    _ body: @escaping (ReadTransaction) throws -> T,
    callbackQueue: DispatchQueue? = nil,
    completion: ((Result<T, Swift.Error>) -> Void)? = nil
  ) {
    self.queue.async {
      do {
        let returnValue = try body(ReadTransaction(store: self))
        
        DispatchQueue.returnResultAsyncIfNeeded(
          on: callbackQueue,
          action: completion,
          result: .success(returnValue)
        )
      } catch {
        DispatchQueue.returnResultAsyncIfNeeded(
          on: callbackQueue,
          action: completion,
          result: .failure(error)
        )
      }
    }
  }
  
  /// Performs an operation within a read-write transaction
  ///
  /// - Parameters:
  ///   - body: The body of the operation to perform
  ///   - callbackQueue: [optional] a callback queue to perform the action on. Will perform on the current queue if not provided. Defaults to nil.
  ///   - completion: [optional] a completion block to fire when the read-write transaction completes. Defaults to nil.
  public func withinReadWriteTransaction<T>(
    _ body: @escaping (ReadWriteTransaction) throws -> T,
    callbackQueue: DispatchQueue? = nil,
    completion: ((Result<T, Swift.Error>) -> Void)? = nil
  ) {
    self.queue.async(flags: .barrier) {
      do {
        let returnValue = try body(ReadWriteTransaction(store: self))
        
        DispatchQueue.returnResultAsyncIfNeeded(
          on: callbackQueue,
          action: completion,
          result: .success(returnValue)
        )
      } catch {
        DispatchQueue.returnResultAsyncIfNeeded(
          on: callbackQueue,
          action: completion,
          result: .failure(error)
        )
      }
    }
  }

  /// Loads the results for the given query from the cache.
  ///
  /// - Parameters:
  ///   - query: The query to load results for
  ///   - resultHandler: The completion handler to execute on success or error
  public func load<Operation: GraphQLOperation>(
    _ operation: Operation,
    callbackQueue: DispatchQueue? = nil,
    resultHandler: @escaping GraphQLResultHandler<Operation.Data>
  ) {
    withinReadTransaction({ transaction in
      let (data, dependentKeys) = try transaction.readObject(
        ofType: Operation.Data.self,
        withKey: CacheReference.rootCacheReference(for: Operation.operationType).key,
        variables: operation.__variables,
        accumulator: zip(GraphQLSelectionSetMapper<Operation.Data>(),
                         GraphQLDependencyTracker())
      )
      
      return GraphQLResult(
        data: data,
        extensions: nil,
        errors: nil,
        source:.cache,
        dependentKeys: dependentKeys
      )
    }, callbackQueue: callbackQueue, completion: resultHandler)
  }

  public enum Error: Swift.Error {
    case notWithinReadTransaction
  }

  public class ReadTransaction {
    fileprivate let cache: NormalizedCache

    fileprivate lazy var loader: DataLoader<CacheKey, Record> = DataLoader(self.cache.loadRecords)
    fileprivate lazy var executor = GraphQLExecutor { object, info in
      return object[info.cacheKeyForField]
    } resolveReference: { [weak self] reference in
      guard let self = self else {
        return .immediate(.failure(ApolloStore.Error.notWithinReadTransaction))
      }
      return self.loadObject(forKey: reference.key)
    }

    fileprivate init(store: ApolloStore) {
      self.cache = store.cache
    }

    public func read<Query: GraphQLQuery>(query: Query) throws -> Query.Data {
      return try readObject(
        ofType: Query.Data.self,
        withKey: CacheReference.rootCacheReference(for: Query.operationType).key,
        variables: query.__variables
      )
    }

    public func readObject<SelectionSet: RootSelectionSet>(
      ofType type: SelectionSet.Type,
      withKey key: CacheKey,
      variables: GraphQLOperation.Variables? = nil
    ) throws -> SelectionSet {
      return try self.readObject(
        ofType: type,
        withKey: key,
        variables: variables,
        accumulator: GraphQLSelectionSetMapper<SelectionSet>()
      )
    }

    func readObject<SelectionSet: RootSelectionSet, Accumulator: GraphQLResultAccumulator>(
      ofType type: SelectionSet.Type,
      withKey key: CacheKey,
      variables: GraphQLOperation.Variables? = nil,
      accumulator: Accumulator
    ) throws -> Accumulator.FinalResult {
      let object = try loadObject(forKey: key).get()

      return try executor.execute(
        selectionSet: type,
        on: object,
        withRootCacheReference: CacheReference(key),
        variables: variables,
        accumulator: accumulator
      )
    }
    
    fileprivate final func loadObject(forKey key: CacheKey) -> PossiblyDeferred<JSONObject> {
      self.loader[key].map { record in
        guard let record = record else { throw JSONDecodingError.missingValue }
        return record.fields
      }
    }
  }

  public final class ReadWriteTransaction: ReadTransaction {

    fileprivate var updateChangedKeysFunc: DidChangeKeysFunc?

    override init(store: ApolloStore) {
      self.updateChangedKeysFunc = store.didChangeKeys
      super.init(store: store)
    }

    public func update<CacheMutation: LocalCacheMutation>(
      _ cacheMutation: CacheMutation,
      _ body: (inout CacheMutation.Data) throws -> Void
    ) throws {
      try updateObject(
        ofType: CacheMutation.Data.self,
        withKey: CacheReference.rootCacheReference(for: CacheMutation.operationType).key,
        variables: cacheMutation.__variables,
        body
      )
    }

    public func updateObject<SelectionSet: MutableRootSelectionSet>(
      ofType type: SelectionSet.Type,
      withKey key: CacheKey,
      variables: GraphQLOperation.Variables? = nil,
      _ body: (inout SelectionSet) throws -> Void
    ) throws {
      var object = try readObject(
        ofType: type,
        withKey: key,
        variables: variables,
        accumulator: GraphQLSelectionSetMapper<SelectionSet>(
          stripNullValues: false,
          allowMissingValuesForOptionalFields: true
        )
      )

      try body(&object)
      try write(selectionSet: object, withKey: key, variables: variables)
    }

    public func write<CacheMutation: LocalCacheMutation>(
      data: CacheMutation.Data,
      for cacheMutation: CacheMutation
    ) throws {
      try write(selectionSet: data,
                withKey: CacheReference.rootCacheReference(for: CacheMutation.operationType).key,
                variables: cacheMutation.__variables)
    }

    public func write<Operation: GraphQLOperation>(
      data: Operation.Data,
      for operation: Operation
    ) throws {
      try write(selectionSet: data,
                withKey: CacheReference.rootCacheReference(for: Operation.operationType).key,
                variables: operation.__variables)
    }

    public func write<SelectionSet: RootSelectionSet>(
      selectionSet: SelectionSet,
      withKey key: CacheKey,
      variables: GraphQLOperation.Variables? = nil
    ) throws {
      let normalizer = ResultNormalizerFactory.selectionSetDataNormalizer()

      let executor = GraphQLExecutor(
        fieldCollector: CustomCacheDataWritingFieldSelectionCollector(),
        fieldResolver: { object, info in
          return object[info.responseKeyForField]
        }
      )

      let records = try executor.execute(
        selectionSet: SelectionSet.self,
        on: selectionSet.__data._data,
        withRootCacheReference: CacheReference(key),
        variables: variables,
        accumulator: normalizer
      )

      let changedKeys = try self.cache.merge(records: records)

      // Remove cached records, so subsequent reads
      // within the same transaction will reload the updated value.
      loader.removeAll()

      if let didChangeKeysFunc = self.updateChangedKeysFunc {
        didChangeKeysFunc(changedKeys, nil)
      }
    }
    
    /// Removes the object for the specified cache key. Does not cascade
    /// or allow removal of only certain fields. Does nothing if an object
    /// does not exist for the given key.
    ///
    /// - Parameters:
    ///   - key: The cache key to remove the object for
    public func removeObject(for key: CacheKey) throws {
      try self.cache.removeRecord(for: key)
    }

    /// Removes records with keys that match the specified pattern. This method will only
    /// remove whole records, it does not perform cascading deletes. This means only the
    /// records with matched keys will be removed, and not any references to them. Key
    /// matching is case-insensitive.
    ///
    /// If you attempt to pass a cache path for a single field, this method will do nothing
    /// since it won't be able to locate a record to remove based on that path.
    ///
    /// - Note: This method can be very slow depending on the number of records in the cache.
    /// It is recommended that this method be called in a background queue.
    ///
    /// - Parameters:
    ///   - pattern: The pattern that will be applied to find matching keys.
    public func removeObjects(matching pattern: CacheKey) throws {
      try self.cache.removeRecords(matching: pattern)
    }

  }
}

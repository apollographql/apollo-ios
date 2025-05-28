import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

public typealias DidChangeKeysFunc = (Set<CacheKey>) -> Void

/// The `ApolloStoreSubscriber` provides a means to observe changes to items in the ApolloStore.
/// This protocol is available for advanced use cases only. Most users will prefer using `ApolloClient.watch(query:)`.
public protocol ApolloStoreSubscriber: AnyObject, Sendable {
  
  /// A callback that can be received by subscribers when keys are changed within the database
  ///
  /// - Parameters:
  ///   - store: The store which made the changes
  ///   - changedKeys: The list of changed keys
  func store(_ store: ApolloStore, didChangeKeys changedKeys: Set<CacheKey>)
}

/// The `ApolloStore` class acts as a local cache for normalized GraphQL results.
#warning("TODO: Docs. ReaderWriter usage; why you should not share a cache with 2 stores, etc.")
public final class ApolloStore: Sendable {
  private let readerWriterLock = ReaderWriter()

  /// The `NormalizedCache` itself is not thread-safe. Access to the cache by a single store is made
  /// thread-safe by using a `ReaderWriter`. All access to the cache must be done within the
  /// `readerWriterLock`.
  /// For cache writes/removes, use a `readerWriterLock.write { }` block. For read only access,
  /// you can use a `readerWriterLock.read { }` block.
  nonisolated(unsafe) private let cache: any NormalizedCache

  /// In order to comply with `Sendable` requirements, this unsafe property should
  /// only be accessed within a `readerWriterLock.write { }` block.
  nonisolated(unsafe) private(set) var subscribers: [any ApolloStoreSubscriber] = []

  /// Designated initializer
  /// - Parameters:
  ///   - cache: An instance of `normalizedCache` to use to cache results.
  ///            Defaults to an `InMemoryNormalizedCache`.
  public init(cache: any NormalizedCache = InMemoryNormalizedCache()) {
    self.cache = cache
  }

  fileprivate func didChangeKeys(_ changedKeys: Set<CacheKey>) {
    for subscriber in self.subscribers {
      subscriber.store(self, didChangeKeys: changedKeys)
    }
  }

  /// Clears the instance of the cache.
  public func clearCache() async throws {
    try await readerWriterLock.write {
      try await self.cache.clear()
    }
  }

  /// Merges a `RecordSet` into the normalized cache.
  /// - Parameters:
  ///   - records: The records to be merged into the cache.
  public func publish(records: RecordSet) async throws {
    try await readerWriterLock.write {
      let changedKeys = try await self.cache.merge(records: records)
      self.didChangeKeys(changedKeys)
    }
  }

  /// Subscribes to notifications of ApolloStore content changes
  ///
  /// - Parameters:
  ///    - subscriber: A subscriber to receive content change notificatons. To avoid a retain cycle,
  ///                  ensure you call `unsubscribe` on this subscriber before it goes out of scope.
  public func subscribe(_ subscriber: any ApolloStoreSubscriber) {
    Task {
      await readerWriterLock.write {
        self.subscribers.append(subscriber)
      }
    }
  }

  /// Unsubscribes from notifications of ApolloStore content changes
  ///
  /// - Parameters:
  ///    - subscriber: A subscribe that has previously been added via `subscribe`. To avoid retain cycles,
  ///                  call `unsubscribe` on all active subscribers before they go out of scope.
  public func unsubscribe(_ subscriber: any ApolloStoreSubscriber) {
    Task {
      await readerWriterLock.write {
        self.subscribers = self.subscribers.filter({ $0 !== subscriber })
      }
    }
  }

  /// Performs an operation within a read transaction
  ///
  /// - Parameters:
  ///   - body: The body of the operation to perform.
  public func withinReadTransaction<T>(
    _ body: @Sendable (ReadTransaction) async throws -> T
  ) async throws -> T {
    var value: T!
    try await readerWriterLock.read {
      value = try await body(ReadTransaction(store: self))
    }
    return value
  }

  /// Performs an operation within a read-write transaction
  ///
  /// - Parameters:
  ///   - body: The body of the operation to perform
  public func withinReadWriteTransaction<T>(
    _ body: (ReadWriteTransaction) async throws -> T
  ) async rethrows -> T {
    var value: T!
    try await readerWriterLock.write {
      value = try await body(ReadWriteTransaction(store: self))
    }
    return value
  }

  /// Loads the results for the given operation from the cache.
  ///
  /// This function will throw an error on a cache miss.
  ///
  /// - Parameters:
  ///   - operation: The operation to load results for
  public func load<Operation: GraphQLOperation>(
    _ operation: Operation
  ) async throws -> GraphQLResult<Operation.Data> {
    try await withinReadTransaction { transaction in
      let (dataDict, dependentKeys) = try await transaction.readObject(
        ofType: Operation.Data.self,
        withKey: CacheReference.rootCacheReference(for: Operation.operationType).key,
        variables: operation.__variables,
        accumulator: zip(DataDictMapper(),
                         GraphQLDependencyTracker())
      )

      return GraphQLResult(
        data: Operation.Data(_dataDict: dataDict),
        extensions: nil,
        errors: nil,
        source:.cache,
        dependentKeys: dependentKeys
      )
    }
  }

  // MARK: -
  public enum Error: Swift.Error {
    case notWithinReadTransaction
  }

  // MARK: -
  #warning("""
  TODO: figure out how to prevent transaction from escaping closure scope.
  Maybe explicitly mark non-sendable: https://forums.swift.org/t/what-does-available-unavailable-sendable-actually-do/65218
  """)
  public class ReadTransaction {
    fileprivate let cache: any NormalizedCache
      
    fileprivate lazy var loader: DataLoader<CacheKey, Record> = DataLoader { [weak self] batchLoad in
      guard let self else { return [:] }
      return try await cache.loadRecords(forKeys: batchLoad)
    }

    fileprivate lazy var executor = GraphQLExecutor(
      executionSource: CacheDataExecutionSource(transaction: self)
    ) 

    fileprivate init(store: ApolloStore) {
      self.cache = store.cache
    }

    public func read<Query: GraphQLQuery>(query: Query) async throws -> Query.Data {
      return try await readObject(
        ofType: Query.Data.self,
        withKey: CacheReference.rootCacheReference(for: Query.operationType).key,
        variables: query.__variables
      )
    }

    public func readObject<SelectionSet: RootSelectionSet>(
      ofType type: SelectionSet.Type,
      withKey key: CacheKey,
      variables: GraphQLOperation.Variables? = nil
    ) async throws -> SelectionSet {
      let dataDict = try await self.readObject(
        ofType: type,
        withKey: key,
        variables: variables,
        accumulator: DataDictMapper()
      )
      return type.init(_dataDict: dataDict)
    }

    func readObject<SelectionSet: RootSelectionSet, Accumulator: GraphQLResultAccumulator>(
      ofType type: SelectionSet.Type,
      withKey key: CacheKey,
      variables: GraphQLOperation.Variables? = nil,
      accumulator: Accumulator
    ) async throws -> Accumulator.FinalResult {
      let object = try await loadObject(forKey: key).get()

      return try await executor.execute(
        selectionSet: type,
        on: object,
        withRootCacheReference: CacheReference(key),
        variables: variables,
        accumulator: accumulator
      )
    }
    
    final func loadObject(forKey key: CacheKey) -> PossiblyDeferred<Record> {
      self.loader[key].map { record in
        guard let record = record else { throw JSONDecodingError.missingValue }
        return record
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
    ) async throws {
      try await updateObject(
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
    ) async throws {
      let dataDict = try await readObject(
        ofType: type,
        withKey: key,
        variables: variables,
        accumulator: DataDictMapper(
          handleMissingValues: .allowForOptionalFields
        )
      )
      var object = SelectionSet(_dataDict: dataDict)

      try body(&object)
      try await write(selectionSet: object, withKey: key, variables: variables)
    }

    public func write<CacheMutation: LocalCacheMutation>(
      data: CacheMutation.Data,
      for cacheMutation: CacheMutation
    ) async throws {
      try await write(selectionSet: data,
                withKey: CacheReference.rootCacheReference(for: CacheMutation.operationType).key,
                variables: cacheMutation.__variables)
    }

    public func write<Operation: GraphQLOperation>(
      data: Operation.Data,
      for operation: Operation
    ) async throws {
      try await write(selectionSet: data,
                withKey: CacheReference.rootCacheReference(for: Operation.operationType).key,
                variables: operation.__variables)
    }

    public func write<SelectionSet: RootSelectionSet>(
      selectionSet: SelectionSet,
      withKey key: CacheKey,
      variables: GraphQLOperation.Variables? = nil
    ) async throws {
      let normalizer = ResultNormalizerFactory.selectionSetDataNormalizer()

      let executor = GraphQLExecutor(executionSource: SelectionSetModelExecutionSource())

      let records = try await executor.execute(
        selectionSet: SelectionSet.self,
        on: selectionSet.__data,
        withRootCacheReference: CacheReference(key),
        variables: variables,
        accumulator: normalizer
      )

      let changedKeys = try await self.cache.merge(records: records)

      // Remove cached records, so subsequent reads
      // within the same transaction will reload the updated value.
      loader.removeAll()

      if let didChangeKeysFunc = self.updateChangedKeysFunc {
        didChangeKeysFunc(changedKeys)
      }
    }
    
    /// Removes the object for the specified cache key. Does not cascade
    /// or allow removal of only certain fields. Does nothing if an object
    /// does not exist for the given key.
    ///
    /// - Parameters:
    ///   - key: The cache key to remove the object for
    public func removeObject(for key: CacheKey) async throws {
      try await self.cache.removeRecord(for: key)
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
    public func removeObjects(matching pattern: CacheKey) async throws {
      try await self.cache.removeRecords(matching: pattern)
    }

  }

  // MARK: - Deprecations

  /// Clears the instance of the cache.
  ///
  /// - Parameters:
  ///   - callbackQueue: The queue to call the completion block on. Defaults to `DispatchQueue.main`.
  ///   - completion: [optional] A completion block to be called after records are merged into the cache.
  @available(*, deprecated, renamed: "clearCache()")
  nonisolated public func clearCache(
    callbackQueue: DispatchQueue = .main,
    completion: (@Sendable (Result<Void, any Swift.Error>) -> Void)? = nil
  ) {
    performInTask(
      {
        try await self.clearCache()
      },
      callbackQueue: callbackQueue,
      completion: completion
    )
  }

  /// Merges a `RecordSet` into the normalized cache.
  /// - Parameters:
  ///   - records: The records to be merged into the cache.
  ///   - identifier: [optional] A unique identifier for the request that kicked off this change,
  ///                 to assist in de-duping cache hits for watchers.
  ///   - callbackQueue: The queue to call the completion block on.
  ///                    Defaults to `DispatchQueue.main`.
  ///   - completion: [optional] A completion block to call after records are merged into the cache.
  @available(*, deprecated, renamed: "publish(records:)")
  public func publish(
    records: RecordSet,
    identifier: UUID? = nil,
    callbackQueue: DispatchQueue = .main,
    completion: (@Sendable (Result<Void, any Swift.Error>) -> Void)? = nil
  ) {
    performInTask(
      {
        try await self.publish(records: records)
      },
      callbackQueue: callbackQueue,
      completion: completion
    )
  }

  /// Performs an operation within a read transaction
  ///
  /// - Parameters:
  ///   - body: The body of the operation to perform.
  ///   - callbackQueue: [optional] The callback queue to use to perform the completion block on.
  ///                    Will perform on the current queue if not provided. Defaults to nil.
  ///   - completion: [optional] The completion block to perform when the transaction completes.
  ///                 Defaults to nil.
  @available(*, deprecated, renamed: "withinReadTransaction(_:)")
  public func withinReadTransaction<T: Sendable>(
    _ body: @escaping @Sendable (ReadTransaction) async throws -> T,
    callbackQueue: DispatchQueue? = nil,
    completion: (@Sendable (Result<T, any Swift.Error>) -> Void)? = nil
  ) {
    performInTask(
      {
        try await self.withinReadTransaction(body)
      },
      callbackQueue: callbackQueue,
      completion: completion
    )
  }

  /// Performs an operation within a read-write transaction
  ///
  /// - Parameters:
  ///   - body: The body of the operation to perform
  ///   - callbackQueue: [optional] a callback queue to perform the action on.
  ///                    Will perform on the current queue if not provided. Defaults to nil.
  ///   - completion: [optional] a completion block to perform when the transaction completes.
  ///                 Defaults to nil.
  @available(*, deprecated, renamed: "withinReadWriteTransaction(_:)")
  public func withinReadWriteTransaction<T: Sendable>(
    _ body: @escaping @Sendable (ReadWriteTransaction) throws -> T,
    callbackQueue: DispatchQueue? = nil,
    completion: (@Sendable (Result<T, any Swift.Error>) -> Void)? = nil
  ) {
    performInTask(
      {
        try await self.withinReadWriteTransaction(body)
      },
      callbackQueue: callbackQueue,
      completion: completion
    )
  }

  /// Loads the results for the given query from the cache.
  ///
  /// - Parameters:
  ///   - query: The query to load results for
  ///   - resultHandler: The completion handler to execute on success or error
  @available(*, deprecated, renamed: "load(_:)")
  public func load<Operation: GraphQLOperation>(
    _ operation: Operation,
    callbackQueue: DispatchQueue? = nil,
    resultHandler: @escaping GraphQLResultHandler<Operation.Data>
  ) {
    performInTask(
      {
        try await self.load(operation)
      },
      callbackQueue: callbackQueue,
      completion: resultHandler
    )
  }

  @available(*, deprecated)
  private func performInTask<T: Sendable>(
    _ body: @escaping @Sendable () async throws -> T,
    callbackQueue: DispatchQueue?,
    completion: (@Sendable (Result<T, any Swift.Error>) -> Void)?
  ) {
    Task {
      let result: Result<T, any Swift.Error>

      do {
        let value = try await body()
        result = .success(value)
      } catch {
        result = .failure(error)
      }

      DispatchQueue.returnResultAsyncIfNeeded(
        on: callbackQueue,
        action: completion,
        result: result
      )
    }
  }
}

import Foundation

/// An enumeration of behaviors for clear operations on a given cache.
public enum CacheClearingPolicy: Equatable {
  /// Clears all records in the cache.
  case allRecords
  /// Clears all records whose key matches the provided glob pattern.
  ///
  /// For example `*pollo` will match both `Apollo` and `pollo`.
  case allMatchingKeyPattern(String)
  /// Clears the the first (oldest) records in the cache up to the given limit.
  case first(Int)
  /// Clears the the last (most recent) records in the cache up to the given limit.
  case last(Int)
}

public protocol NormalizedCache {

  /// Loads records corresponding to the given keys.
  ///
  /// - Parameters:
  ///   - keys: The cache keys to load data for
  ///   - callbackQueue: [optional] An alternate queue to fire the completion closure on. If nil, will fire on the current queue.
  ///   - completion: A completion closure to fire when the load has completed. If successful, will contain an array. Each index will contain either the record corresponding to the key at the same index in the passed-in array of cache keys, or nil if that record was not found.
  func loadRecords(forKeys keys: [CacheKey],
                   callbackQueue: DispatchQueue?,
                   completion: @escaping (Result<[Record?], Error>) -> Void)

  /// Merges a set of records into the cache.
  ///
  /// - Parameters:
  ///   - records: The set of records to merge.
  ///   - callbackQueue: [optional] An alternate queue to fire the completion closure on. If nil, will fire on the current queue.
  ///   - completion: A completion closure to fire when the merge has completed. If successful, will contain a set of keys corresponding to *fields* that have changed (i.e. QUERY_ROOT.Foo.myField). These are the same type of keys as are returned by RecordSet.merge(records:).
  func merge(records: RecordSet,
             callbackQueue: DispatchQueue?,
             completion: @escaping (Result<Set<CacheKey>, Error>) -> Void)

  /// Clears records from the cache according to the policy provided.
  /// - Parameters:
  ///   - policy: The policy to use in determining which records to clear.
  ///   - callbackQueue: An optional queue to execute the completion closure on.
  ///   - completion: An optional completion closure to execute when the cache clearing has completed.
  func clear(_ clearingPolicy: CacheClearingPolicy,
             callbackQueue: DispatchQueue?,
             completion: ((Result<Void, Error>) -> Void)?)

  /// Clears records from the cache synchronously according to the policy provided.
  /// - Parameter policy: The policy to use in determining which records to clear.
  func clearImmediately(_ clearingPolicy: CacheClearingPolicy) throws
}

extension NormalizedCache {
  /// Clears all records in the cache.
  /// - Parameters:
  ///   - callbackQueue: An optional queue to execute the completion closure on.
  ///   - completion: An optional completion closure to execute when the cache clearing has completed.
  public func clear(callbackQueue: DispatchQueue? = nil, completion: ((Result<Void, Error>) -> Void)? = nil) {
    self.clear(.allRecords, callbackQueue: callbackQueue, completion: completion)
  }

  /// Clears all records in the cache synchronously.
  public func clearImmediately() throws {
    try self.clearImmediately(.allRecords)
  }
}

import Foundation

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

  // Clears all records
  ///
  /// - Parameters:
  ///   - callbackQueue: [optional] An alternate queue to fire the completion closure on. If nil, will fire on the current queue.
  ///   - completion: [optional] A completion closure to fire when the clear function has completed.
  func clear(callbackQueue: DispatchQueue?,
             completion: ((Result<Void, Error>) -> Void)?)
}

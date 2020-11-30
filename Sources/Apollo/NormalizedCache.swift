import Foundation

public protocol NormalizedCache {
  
  /// Loads records corresponding to the given keys.
  ///
  /// - Parameters:
  ///   - key: The cache keys to load data for
  /// - Returns: A dictionary of cache keys to records containing the records that have been found.
  func loadRecords(forKeys keys: Set<CacheKey>) throws -> [CacheKey: Record]
    
  /// Merges a set of records into the cache.
  ///
  /// - Parameters:
  ///   - records: The set of records to merge.
  /// - Returns: A set of keys corresponding to *fields* that have changed (i.e. QUERY_ROOT.Foo.myField). These are the same type of keys as are returned by RecordSet.merge(records:).
  func merge(records: RecordSet) throws -> Set<CacheKey>
  
  /// Clears all records.
  func clear() throws
}

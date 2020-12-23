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

  /// Removes a record for the specified key. This method will only
  /// remove whole records, not individual fields.
  ///
  /// If you attempt to pass a cache key for a  single field, this
  /// method will do nothing since it won't be able to locate a
  /// record to remove based on that key.
  ///
  /// This method does not support cascading delete - it will only
  /// remove the record for the specified key, and not any references to it or from it.
  /// 
  /// - Parameters:
  ///   - key: The cache key to remove the record for
  func removeRecord(for key: CacheKey) throws
  
  /// Clears all records.
  func clear() throws
}

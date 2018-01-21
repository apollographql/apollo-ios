public protocol NormalizedCache {

  /// Loads records corresponding to the given keys.
  /// - returns: A promise that fulfills with an array, with each index containing either the
  ///            record corresponding to the key at that index or nil if not found.
  func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]>

  /// Merges a set of records into the cache.
  /// - returns: A promise that fulfills with a set of keys corresponding to *fields* that have
  ///            changed (i.e. QUERY_ROOT.Foo.myField). These are the same type of keys as are 
  ///            returned by RecordSet.merge(records:).
  func merge(records: RecordSet) -> Promise<Set<CacheKey>>

  // Clears all records
  func clear() -> Promise<Void>
}

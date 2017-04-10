public protocol NormalizedCache {
  // When no records are found for the given keys, this should fulfill with [nil]
  func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]>
  func merge(records: RecordSet) -> Promise<Set<CacheKey>>
}

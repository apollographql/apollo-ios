public protocol NormalizedCache {
  func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]>
  func merge(records: RecordSet) -> Promise<Set<CacheKey>>
}

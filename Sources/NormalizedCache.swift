public protocol NormalizedCache {
  func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]>
  func merge(records: RecordSet) -> Set<CacheKey>
}

final class InMemoryNormalizedCache: NormalizedCache {
  private var records: RecordSet
  
  init(records: RecordSet) {
    self.records = records
  }
  
  func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    let records = keys.map { self.records[$0] }
    return Promise(fulfilled: records)
  }
  
  func merge(records: RecordSet) -> Set<CacheKey> {
    return self.records.merge(records: records)
  }
}

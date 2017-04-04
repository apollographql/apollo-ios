final class InMemoryNormalizedCache: NormalizedCache {
  private var records: RecordSet

  init(records: RecordSet) {
    self.records = records
  }

  func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    let records = keys.map { self.records[$0] }
    return Promise(fulfilled: records)
  }

  func merge(records: RecordSet) -> Promise<Set<CacheKey>> {
    return Promise(fulfilled: self.records.merge(records: records))
  }
}

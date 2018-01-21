public final class InMemoryNormalizedCache: NormalizedCache {
  private var records: RecordSet

  public init(records: RecordSet = RecordSet()) {
    self.records = records
  }

  public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    let records = keys.map { self.records[$0] }
    return Promise(fulfilled: records)
  }

  public func merge(records: RecordSet) -> Promise<Set<CacheKey>> {
    return Promise(fulfilled: self.records.merge(records: records))
  }

  public func clear() -> Promise<Void> {
    records.clear()
    return Promise(fulfilled: ())
  }
}

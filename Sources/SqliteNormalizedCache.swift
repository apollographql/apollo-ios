final class SqliteNormalizedCache: NormalizedCache {

  init(fileURL: URL) {
  }

  public func merge(records: RecordSet) -> Promise<Set<CacheKey>> {
    return Promise(fulfilled: Set())
  }

  public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    return Promise(fulfilled: [])
  }
}

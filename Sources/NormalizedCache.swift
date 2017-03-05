public protocol NormalizedCache {
  func loadRecord(forKey key: CacheKey) -> Promise<Record?>
  func merge(records: RecordSet) -> Set<CacheKey>
}

public final class InMemoryCache: NormalizedCache {
  private var records: RecordSet
  
  public init(records: RecordSet) {
    self.records = records
  }
  
  public func loadRecord(forKey key: CacheKey) -> Promise<Record?> {
    return Promise(fulfilled: records[key])
  }
  
  public func merge(records: RecordSet) -> Set<CacheKey> {
    return self.records.merge(records: records)
  }
}

public final class BatchedNormalizedCache: NormalizedCache {
  private var records: RecordSet
  private var loader: DataLoader<CacheKey, Record?>!
  
  public init(records: RecordSet) {
    self.records = records
    self.loader = DataLoader(loadRecords)
  }
  
  func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    let records = keys.map { self.records[$0] }
    return Promise(fulfilled: records)
  }
  
  public func loadRecord(forKey key: CacheKey) -> Promise<Record?> {
    return loader.load(key: key)
  }
  
  public func merge(records: RecordSet) -> Set<CacheKey> {
    return self.records.merge(records: records)
  }
}

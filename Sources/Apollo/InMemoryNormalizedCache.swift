import Foundation

public final class InMemoryNormalizedCache: NormalizedCache {
  private var records: RecordSet

  public init(records: RecordSet = RecordSet()) {
    self.records = records
  }

  public func loadRecords(forKeys keys: Set<CacheKey>) throws -> [CacheKey: Record] {
    return keys.reduce(into: [:]) { result, key in
      result[key] = records[key]
    }
  }

  public func removeRecord(for key: CacheKey) throws {
    records.removeRecord(for: key)
  }
  
  public func merge(records newRecords: RecordSet) throws -> Set<CacheKey> {
    return records.merge(records: newRecords)
  }

  public func clear() {
    records.clear()
  }
}

import SQLite
#if !COCOAPODS
import Apollo
#endif

public enum SQLiteNormalizedCacheError: Error {
  case invalidRecordEncoding(record: String)
  case invalidRecordShape(object: Any)
  case invalidRecordValue(value: Any)
}

public final class SQLiteNormalizedCache {
  
  private let db: Connection
  private let records = Table("records")
  private let id = Expression<Int64>("_id")
  private let key = Expression<CacheKey>("key")
  private let record = Expression<String>("record")
  private let shouldVacuumOnClear: Bool

  public init(fileURL: URL, shouldVacuumOnClear: Bool = false) throws {
    self.shouldVacuumOnClear = shouldVacuumOnClear
    self.db = try Connection(.uri(fileURL.absoluteString), readonly: false)
    try self.createTableIfNeeded()
  }

  private func recordCacheKey(forFieldCacheKey fieldCacheKey: CacheKey) -> CacheKey {
    var components = fieldCacheKey.components(separatedBy: ".")
    if components.count > 1 {
      components.removeLast()
    }
    return components.joined(separator: ".")
  }

  private func createTableIfNeeded() throws {
    try self.db.run(self.records.create(ifNotExists: true) { table in
      table.column(id, primaryKey: .autoincrement)
      table.column(key, unique: true)
      table.column(record)
    })
    try self.db.run(self.records.createIndex(key, unique: true, ifNotExists: true))
  }

  private func mergeRecords(records: RecordSet) throws -> Set<CacheKey> {
    var recordSet = RecordSet(records: try self.selectRecords(forKeys: records.keys))
    let changedFieldKeys = recordSet.merge(records: records)
    let changedRecordKeys = changedFieldKeys.map { self.recordCacheKey(forFieldCacheKey: $0) }
    for recordKey in Set(changedRecordKeys) {
      if let recordFields = recordSet[recordKey]?.fields {
        let recordData = try SQLiteSerialization.serialize(fields: recordFields)
        guard let recordString = String(data: recordData, encoding: .utf8) else {
          assertionFailure("Serialization should yield UTF-8 data")
          continue
        }
        try self.db.run(self.records.insert(or: .replace, self.key <- recordKey, self.record <- recordString))
      }
    }
    return Set(changedFieldKeys)
  }

  private func selectRecords(forKeys keys: [CacheKey]) throws -> [Record] {
    let query = self.records.filter(keys.contains(key))
    return try self.db.prepare(query).map { try parse(row: $0) }
  }

  private func clearRecords() throws {
    try self.db.run(records.delete())
    if self.shouldVacuumOnClear {
      try self.db.prepare("records VACUUM;").run()
    }
  }

  private func parse(row: Row) throws -> Record {
    let record = row[self.record]

    guard let recordData = record.data(using: .utf8) else {
      throw SQLiteNormalizedCacheError.invalidRecordEncoding(record: record)
    }

    let fields = try SQLiteSerialization.deserialize(data: recordData)
    return Record(key: row[key], fields)
  }
}

// MARK: - NormalizedCache conformance

extension SQLiteNormalizedCache: NormalizedCache {
  
  public func merge(records: RecordSet) -> Promise<Set<CacheKey>> {
    return Promise { try self.mergeRecords(records: records) }
  }
  
  public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    return Promise {
      let records = try self.selectRecords(forKeys: keys)
      let recordsOrNil: [Record?] = keys.map { key in
        if let recordIndex = records.firstIndex(where: { $0.key == key }) {
          return records[recordIndex]
        }
        return nil
      }
      return recordsOrNil
    }
  }
  
  public func clear() -> Promise<Void> {
    return Promise {
      return try self.clearRecords()
    }
  }
}

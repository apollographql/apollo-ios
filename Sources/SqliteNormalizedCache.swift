import SQLite

enum SqliteNormalizedCacheError: Error {
  case invalidRecordEncoding(record: String)
  case invalidRecordShape(record: String)
}

final class SqliteNormalizedCache: NormalizedCache {

//  init(fileURI: URL) throws {
//    db = try Connection(.uri(fileURI.absoluteString), readonly: false)
//    try createTableIfNeeded()
//  }

  // TODO: we shouldn't have this in-memory initializer here - just for testing
  init() throws {
    db = try Connection(readonly: false)
    try createTableIfNeeded()
  }

  public func merge(records: RecordSet) -> Promise<Set<CacheKey>> {
    return Promise<Set<CacheKey>> { fulfill, reject in
      do {
        var recordSet = RecordSet(records: try select(withKeys: records.keys))
        let changedKeys = recordSet.merge(records: records)
        // Shouldn't changedKeys contain full cache key (rather than just one level deep from QUERY_ROOT)?
        // (e.g. it has "QUERY_ROOT.hero" but it wouldn't have anything nested any further than that)
        // Also, shouldn't it rely on the passed-in cache key function rather than response shape path with periods?
        for changedKey in changedKeys {
          if let key = changedKey.components(separatedBy: ".").first,
            let recordFields = recordSet[key]?.fields
          {
            print("\tupdating record: \(recordFields)...")
            let recordData = try JSONSerializationFormat.serialize(value: recordFields)
            let recordString = String(data: recordData, encoding: .utf8)!
            let rowid = try db.run(self.records.insert(or: .replace, self.key <- key, self.record <- recordString))
            print("\t\ttrowid: \(rowid)")
          }
        }
        print("updated records: \(changedKeys)")
        fulfill(Set(changedKeys))
      }
      catch {
        print("failed updating records: \(error.localizedDescription)")
        reject(error)
      }
    }
  }

  public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    return Promise<[Record?]> { fulfill, reject in
      print("\n\nloading records: \(keys)...") // TODO: remove
      do {
        // TODO: one line
        let records = try select(withKeys: keys)
        fulfill(records)
        print("finished loading records")
      }
      catch {
        print("failed loading records: \(error.localizedDescription)")
        reject(error)
      }
    }
  }

  private let db: Connection
  private let records = Table("records")
  private let id = Expression<Int64>("_id")
  private let key = Expression<CacheKey>("key")
  private let record = Expression<String>("record")

  private func createTableIfNeeded() throws {
    try db.run(records.create(ifNotExists: true) { table in
      table.column(id, primaryKey: .autoincrement)
      table.column(key, unique: true)
      table.column(record)
    })
    try db.run(records.createIndex([key], unique: true, ifNotExists: true))
  }

  private func select(withKeys keys: [CacheKey]) throws -> [Record] {
    // TODO: revert
//    let query = records.filter(keys.contains(key))
//    return try db.prepare(query).map { try parse(row: $0) }
    let query = records
    for row in try db.prepare(records) {
      print("row: \(row)")
    }
    return []
  }

  private func parse(row: Row) throws -> Record {
    let record = row[self.record]

    // TODO: why don't we have to encode *into* utf8 when writing to db?
    guard let recordData = record.data(using: .utf8) else {
      throw SqliteNormalizedCacheError.invalidRecordEncoding(record: record)
    }

    guard let recordJSON = (try JSONSerializationFormat.deserialize(data: recordData)) as? JSONObject else {
      throw SqliteNormalizedCacheError.invalidRecordShape(record: record)
    }

    return Record(key: row[key], recordJSON)
  }
}

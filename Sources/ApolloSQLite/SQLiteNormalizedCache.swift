import Foundation
import SQLite
#if !COCOAPODS
import Apollo
#endif

public enum SQLiteNormalizedCacheError: Error {
  case invalidRecordEncoding(record: String)
  case invalidRecordShape(object: Any)
  case invalidRecordValue(value: Any)
}

/// A `NormalizedCache` implementation which uses a SQLite database to store data.
public final class SQLiteNormalizedCache {

  private let db: Connection
  private let records = Table("records")
  private let id = Expression<Int64>("_id")
  private let key = Expression<CacheKey>("key")
  private let record = Expression<String>("record")
  private let lastModifiedAt = Expression<Int64>("lastModifiedAt")
  private let version = Expression<Int64>("version")
  private let shouldVacuumOnClear: Bool

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - fileURL: The file URL to use for your database.
  ///   - shouldVacuumOnClear: If the database should also be `VACCUM`ed on clear to remove all traces of info. Defaults to `false` since this involves a performance hit, but this should be used if you are storing any Personally Identifiable Information in the cache.
  ///   - initialRecords: A set of records to initialize the database with.
  /// - Throws: Any errors attempting to open or create the database.
  public init(fileURL: URL, shouldVacuumOnClear: Bool = false, initialRecords: RecordSet? = nil) throws {
    self.shouldVacuumOnClear = shouldVacuumOnClear
    self.db = try Connection(.uri(fileURL.absoluteString), readonly: false)
    try self.setUpDatabase()

    if let initialRecords = initialRecords {
      for key in initialRecords.keys {
        guard let record = initialRecords[key] else {
          assertionFailure("No record was found for the existing key")
          return
        }
        guard let recordString = try record.record.asString() else {
          continue
        }
        try self.db.run(self.records.insert(
          or: .replace,
          self.key <- key,
          self.record <- recordString,
          self.lastModifiedAt <- record.lastModifiedAt
        ))
      }
    }
  }

  private func recordCacheKey(forFieldCacheKey fieldCacheKey: CacheKey) -> CacheKey {
    var components = fieldCacheKey.components(separatedBy: ".")
    if components.count > 1 {
      components.removeLast()
    }
    return components.joined(separator: ".")
  }

  private func setUpDatabase() throws {
    let currentVersion = try readSchemaVersion()

    try self.db.run(self.records.create(ifNotExists: true) { table in
      table.column(id, primaryKey: .autoincrement)
      table.column(key, unique: true)
      table.column(record)
    })
    try self.db.run(self.records.createIndex(key, unique: true, ifNotExists: true))

    if currentVersion < 1 {
      try self.db.run(self.records.addColumn(lastModifiedAt, defaultValue: 0))
    }
    try self.db.run("PRAGMA user_version = 1;")
  }

  private func mergeRecords(records: RecordSet) throws -> Set<CacheKey> {
    var recordSet = RecordSet(rows: try self.selectRows(forKeys: records.keys))
    let changedFieldKeys = recordSet.merge(records: records)
    let changedRecordKeys = changedFieldKeys.map { self.recordCacheKey(forFieldCacheKey: $0) }
    for recordKey in Set(changedRecordKeys) {
      if let record = recordSet[recordKey]?.record {
        guard let recordString = try record.asString() else {
          continue
        }
        try self.db.run(self.records.insert(
          or: .replace,
          self.key <- recordKey,
          self.record <- recordString,
          self.lastModifiedAt <- Date().milisecondsSince1970
        ))
      }
    }
    return Set(changedFieldKeys)
  }

  private func selectRows(forKeys keys: [CacheKey]) throws -> [RecordRow] {
    let query = self.records.filter(keys.contains(key))
    return try self.db.prepare(query).map { try parse(row: $0) }
  }

  private func clearRecords() throws {
    try self.db.run(records.delete())
    if self.shouldVacuumOnClear {
      try self.db.prepare("VACUUM;").run()
    }
  }

  private func parse(row: Row) throws -> RecordRow {
    let record = row[self.record]
    let lastModifiedAt = row[self.lastModifiedAt]

    guard let recordData = record.data(using: .utf8) else {
      throw SQLiteNormalizedCacheError.invalidRecordEncoding(record: record)
    }

    let fields = try SQLiteSerialization.deserialize(data: recordData)
    return RecordRow(
      record: Record(key: row[key], fields),
      lastModifiedAt: lastModifiedAt
    )
  }

  /// Returns the version of the database schema.
  func readSchemaVersion() throws -> Int64 {
    for record in try db.prepare("PRAGMA user_version") {
      if let value = record[0] as? Int64 {
        return value
      }
    }
    return -1
  }
}

// MARK: - NormalizedCache conformance

extension SQLiteNormalizedCache: NormalizedCache {

  public func merge(records: RecordSet,
                    callbackQueue: DispatchQueue?,
                    completion: @escaping (Swift.Result<Set<CacheKey>, Error>) -> Void) {
    let result: Swift.Result<Set<CacheKey>, Error>
    do {
      let records = try self.mergeRecords(records: records)
      result = .success(records)
    } catch {
      result = .failure(error)
    }

    DispatchQueue.apollo_returnResultAsyncIfNeeded(on: callbackQueue,
                                                   action: completion,
                                                   result: result)
  }

  public func loadRecords(forKeys keys: [CacheKey],
                          callbackQueue: DispatchQueue?,
                          completion: @escaping (Swift.Result<[RecordRow?], Error>) -> Void) {
    let result: Swift.Result<[RecordRow?], Error>
    do {
      let rows = try self.selectRows(forKeys: keys)
      let recordsOrNil: [RecordRow?] = keys.map { key in
        if let recordIndex = rows.firstIndex(where: { $0.record.key == key }) {
          return rows[recordIndex]
        }
        return nil
      }

      result = .success(recordsOrNil)
    } catch {
      result = .failure(error)
    }

    DispatchQueue.apollo_returnResultAsyncIfNeeded(on: callbackQueue,
                                                   action: completion,
                                                   result: result)
  }

  public func clear(callbackQueue: DispatchQueue?, completion: ((Swift.Result<Void, Error>) -> Void)?) {
    let result: Swift.Result<Void, Error>
    do {
      try self.clearRecords()
      result = .success(())
    } catch {
      result = .failure(error)
    }

    DispatchQueue.apollo_returnResultAsyncIfNeeded(on: callbackQueue,
                                                   action: completion,
                                                   result: result)
  }
}

extension Record {
  func asString() throws -> String? {
    let recordData = try SQLiteSerialization.serialize(fields: fields)
    guard let recordString = String(data: recordData, encoding: .utf8) else {
      assertionFailure("Serialization should yield UTF-8 data")
      return nil
    }
    return recordString
  }
}

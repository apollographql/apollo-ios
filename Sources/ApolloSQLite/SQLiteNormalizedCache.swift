import Foundation
import SQLite
#if !COCOAPODS
import Apollo
#endif

public enum SQLiteNormalizedCacheError: Error {
  case invalidRecordEncoding(record: String)
  case invalidRecordShape(object: Any)
}

/// A `NormalizedCache` implementation which uses a SQLite database to store data.
public final class SQLiteNormalizedCache {

  private let db: Connection
  private let records = Table("records")
  private let id = Expression<Int64>("_id")
  private let key = Expression<CacheKey>("key")
  private let record = Expression<String>("record")
  private let shouldVacuumOnClear: Bool

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - fileURL: The file URL to use for your database.
  ///   - shouldVacuumOnClear: If the database should also be `VACCUM`ed on clear to remove all traces of info. Defaults to `false` since this involves a performance hit, but this should be used if you are storing any Personally Identifiable Information in the cache.
  /// - Throws: Any errors attempting to open or create the database.
  public init(fileURL: URL, shouldVacuumOnClear: Bool = false) throws {
    self.shouldVacuumOnClear = shouldVacuumOnClear
    self.db = try Connection(.uri(fileURL.absoluteString), readonly: false)
    try self.createTableIfNeeded()
  }

  private func recordCacheKey(forFieldCacheKey fieldCacheKey: CacheKey) -> CacheKey {
    let components = fieldCacheKey.components(separatedBy: ".")
    var updatedComponents = [String]()
    if components.first?.contains("_ROOT") == true {
      for component in components {
        if updatedComponents.last?.last?.isNumber ?? false && component.first?.isNumber ?? false {
          updatedComponents[updatedComponents.count - 1].append(".\(component)")
        } else {
          updatedComponents.append(component)
        }
      }
    } else {
      updatedComponents = components
    }

    if updatedComponents.count > 1 {
      updatedComponents.removeLast()
    }
    return updatedComponents.joined(separator: ".")
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
      try self.db.prepare("VACUUM;").run()
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
                          completion: @escaping (Swift.Result<[Record?], Error>) -> Void) {
    let result: Swift.Result<[Record?], Error>
    do {
      let records = try self.selectRecords(forKeys: keys)
      let recordsOrNil: [Record?] = keys.map { key in
        if let recordIndex = records.firstIndex(where: { $0.key == key }) {
          return records[recordIndex]
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

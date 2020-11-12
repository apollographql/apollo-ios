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

  /// Creates a store that uses the provided SQLite file connection.
  /// - Parameters:
  ///   - db: The database connection to use.
  ///   - shouldVacuumOnClear: If the database file should compact "VACUUM" its storage when clearing records. This can be a potentially long operation.
  ///   Default is `false`. This SHOULD be set to `true` if you are storing any Personally Identifiable Information in the cache.
  /// - Throws: Any errors attempting to access the database.
  public init(db: Connection, compactFileOnClear shouldVacuumOnClear: Bool = false) throws {
    self.shouldVacuumOnClear = shouldVacuumOnClear
    self.db = db
    try self.createTableIfNeeded()
  }

  /// Creates a store that will establish its own connection to the SQLite file at the provided url.
  /// - Parameters:
  ///   - fileURL: The file URL to use for your database.
  ///   - shouldVacuumOnClear: If the database file should compact "VACUUM" its storage when clearing records. This can be a potentially long operation.
  ///   Default is `false`. This SHOULD be set to `true` if you are storing any Personally Identifiable Information in the cache.
  /// - Throws: Any errors attempting to open or create the database.
  convenience public init(fileURL: URL, compactFileOnClear shouldVacuumOnClear: Bool = false) throws {
    try self.init(
      db: try Connection(.uri(fileURL.absoluteString), readonly: false),
      compactFileOnClear: shouldVacuumOnClear
    )
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

  private func clearRecords(accordingTo policy: CacheClearingPolicy) throws {
    switch policy._value {
    case let .first(count):
      let firstKRecords = records.select(self.id).order(self.id.asc).limit(count)
      try self.db.run(firstKRecords.delete())

    case let .last(count):
      let lastKRecords = records.select(self.id).order(self.id.desc).limit(count)
      try self.db.run(lastKRecords.delete())

    case let .allMatchingKeyPattern(pattern):
      let matchingRecords = records.where(
        self.key.like(pattern.replacingOccurrences(of: "*", with: "%"))
      )
      try self.db.run(matchingRecords.delete())

    case .allRecords: fallthrough
    default:
      try self.db.run(records.delete())
    }

    guard self.shouldVacuumOnClear else { return }

    try self.db.prepare("VACUUM;").run()
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

    DispatchQueue.apollo.returnResultAsyncIfNeeded(on: callbackQueue,
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

    DispatchQueue.apollo.returnResultAsyncIfNeeded(on: callbackQueue,
                                                   action: completion,
                                                   result: result)
  }

  public func clear(
    _ clearingPolicy: CacheClearingPolicy,
    callbackQueue: DispatchQueue?,
    completion: ((Swift.Result<Void, Error>) -> Void)?
  ) {
    let result: Swift.Result<Void, Error>
    do {
      try self.clearRecords(accordingTo: clearingPolicy)
      result = .success(())
    } catch {
      result = .failure(error)
    }

    DispatchQueue.apollo.returnResultAsyncIfNeeded(on: callbackQueue,
                                                   action: completion,
                                                   result: result)
  }

  public func clearImmediately(_ clearingPolicy: CacheClearingPolicy) throws {
    try self.clearRecords(accordingTo: clearingPolicy)
  }
}

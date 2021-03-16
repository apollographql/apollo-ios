import Foundation
import SQLite
#if !COCOAPODS
import Apollo
#endif

public enum SQLiteNormalizedCacheError: Error {
  case invalidRecordEncoding(record: String)
  case invalidRecordShape(object: Any)
}

public final class SQLiteDotSwiftDatabase: SQLiteDatabase {
  private var db: Connection!
  
  private let records: Table
  private let keyColumn: Expression<CacheKey>
  private let recordColumn: Expression<String>
  
  public init(fileURL: URL) throws {
    self.records = Table(Self.tableName)
    self.keyColumn = Expression<CacheKey>(Self.keyColumnName)
    self.recordColumn = Expression<String>(Self.recordColumName)
    self.db = try Connection(.uri(fileURL.absoluteString), readonly: false)
  }
  
  public init(connection: Connection) {
    self.records = Table(Self.tableName)
    self.keyColumn = Expression<CacheKey>(Self.keyColumnName)
    self.recordColumn = Expression<String>(Self.recordColumName)
    self.db = connection
  }
  
  public func createRecordsTableIfNeeded() throws {    
    try self.db.run(self.records.create(ifNotExists: true) { table in
      table.column(Expression<Int64>(Self.idColumnName), primaryKey: .autoincrement)
      table.column(keyColumn, unique: true)
      table.column(Expression<String>(Self.recordColumName))
    })
    try self.db.run(self.records.createIndex(keyColumn, unique: true, ifNotExists: true))
  }
  
  public func selectRawRows(forKeys keys: Set<CacheKey>) throws -> [DatabaseRow] {
    let query = self.records.filter(keys.contains(keyColumn))
    return try self.db.prepare(query).map { row in
      let record = row[self.recordColumn]
      let key = row[self.keyColumn]
      
      return DatabaseRow(cacheKey: key, storedInfo: record)
    }
  }
  
  public func addOrUpdateRecordString(_ recordString: String, for cacheKey: CacheKey) throws {
    try self.db.run(self.records.insert(or: .replace, self.keyColumn <- cacheKey, self.recordColumn <- recordString))
  }
  
  public func deleteRecord(for cacheKey: CacheKey) throws {
    let query = self.records.filter(keyColumn == cacheKey)
    try self.db.run(query.delete())
  }
  
  public func clearDatabase(shouldVacuumOnClear: Bool) throws {
    try self.db.run(records.delete())
    if shouldVacuumOnClear {
      try self.db.prepare("VACUUM;").run()
    }
  }
}

/// A `NormalizedCache` implementation which uses a SQLite database to store data.
public final class SQLiteNormalizedCache {

  private let shouldVacuumOnClear: Bool
  
  let database: SQLiteDatabase

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - fileURL: The file URL to use for your database.
  ///   - shouldVacuumOnClear: If the database should also be `VACCUM`ed on clear to remove all traces of info. Defaults to `false` since this involves a performance hit, but this should be used if you are storing any Personally Identifiable Information in the cache.
  /// - Throws: Any errors attempting to open or create the database.
  public init(fileURL: URL,
              databaseType: SQLiteDatabase.Type = SQLiteDotSwiftDatabase.self,
              shouldVacuumOnClear: Bool = false) throws {
    self.database = try databaseType.init(fileURL: fileURL)
    self.shouldVacuumOnClear = shouldVacuumOnClear
    try self.database.createRecordsTableIfNeeded()
  }

  public init(database: SQLiteDatabase,
              shouldVacuumOnClear: Bool = false) throws {
    self.database = database
    self.shouldVacuumOnClear = shouldVacuumOnClear
    try self.database.createRecordsTableIfNeeded()
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

  private func mergeRecords(records: RecordSet) throws -> Set<CacheKey> {
    var recordSet = RecordSet(records: try self.selectRecords(for: records.keys))
    let changedFieldKeys = recordSet.merge(records: records)
    let changedRecordKeys = changedFieldKeys.map { self.recordCacheKey(forFieldCacheKey: $0) }
    for recordKey in Set(changedRecordKeys) {
      if let recordFields = recordSet[recordKey]?.fields {
        let recordData = try SQLiteSerialization.serialize(fields: recordFields)
        guard let recordString = String(data: recordData, encoding: .utf8) else {
          assertionFailure("Serialization should yield UTF-8 data")
          continue
        }
        
        try self.database.addOrUpdateRecordString(recordString, for: recordKey)
      }
    }
    return Set(changedFieldKeys)
  }
  
  fileprivate func selectRecords(for keys: Set<CacheKey>) throws -> [Record] {
    try self.database.selectRawRows(forKeys: keys)
      .map { try self.parse(row: $0) }
  }

  private func parse(row: DatabaseRow) throws -> Record {
    guard let recordData = row.storedInfo.data(using: .utf8) else {
      throw SQLiteNormalizedCacheError.invalidRecordEncoding(record: row.storedInfo)
    }

    let fields = try SQLiteSerialization.deserialize(data: recordData)
    return Record(key: row.cacheKey, fields)
  }
}

// MARK: - NormalizedCache conformance

extension SQLiteNormalizedCache: NormalizedCache {
  public func loadRecords(forKeys keys: Set<CacheKey>) throws -> [CacheKey: Record] {
    return [CacheKey: Record](uniqueKeysWithValues:
                                try selectRecords(for: keys)
                                .map { record in
                                  (record.key, record)
                                })
  }
  
  public func merge(records: RecordSet) throws -> Set<CacheKey> {
    return try mergeRecords(records: records)
  }
  
  public func removeRecord(for key: CacheKey) throws {
    try self.database.deleteRecord(for: key)
  }
  
  public func clear() throws {
    try self.database.clearDatabase(shouldVacuumOnClear: self.shouldVacuumOnClear)
  }
}

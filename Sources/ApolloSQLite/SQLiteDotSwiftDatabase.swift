import Foundation
#if !COCOAPODS
import Apollo
#endif
import SQLite

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
    return try self.db.prepareRowIterator(query).map { row in
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

  public func deleteRecords(matching pattern: CacheKey) throws {
    let wildcardPattern = "%\(pattern)%"
    let query = self.records.filter(keyColumn.like(wildcardPattern))

    try self.db.run(query.delete())
  }
  
  public func clearDatabase(shouldVacuumOnClear: Bool) throws {
    try self.db.run(records.delete())
    if shouldVacuumOnClear {
      try self.db.prepare("VACUUM;").run()
    }
  }
}

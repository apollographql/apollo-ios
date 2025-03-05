import Foundation
#if !COCOAPODS
import ApolloMigration
#endif
import SQLite

public final class SQLiteDotSwiftDatabase: SQLiteDatabase {
  private var db: Connection!
  
  private let records: Table
  private let keyColumn: SQLite.Expression<CacheKey>
  private let recordColumn: SQLite.Expression<String>

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
      table.column(SQLite.Expression<Int64>(Self.idColumnName), primaryKey: .autoincrement)
      table.column(keyColumn, unique: true)
      table.column(SQLite.Expression<String>(Self.recordColumName))
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

  public func addOrUpdate(records: [(cacheKey: CacheKey, recordString: String)]) throws {
    guard !records.isEmpty else { return }
    
    let setters = records.map {
      [self.keyColumn <- $0.cacheKey, self.recordColumn <- $0.recordString]
    }

    try self.db.run(self.records.insertMany(or: .replace, setters))
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

  /// Sets the journal mode for the current database.
  ///
  /// - Parameter mode: The journal mode controls how the journal file is stored and processed.
  public func setJournalMode(mode: JournalMode) throws {
    try self.db.run("PRAGMA journal_mode = \(mode.rawValue)")
  }
}

import Foundation
import Apollo
import SQLite3

public final class ApolloSQLiteDatabase: SQLiteDatabase {
  
  private final class DBContextToken: Sendable {}

  private var db: OpaquePointer?
  private let dbURL: URL

  private let dbQueue = DispatchQueue(label: "com.apollo.sqlite.database")
  private static let dbContextKey = DispatchSpecificKey<DBContextToken>()
  private let dbContextValue = DBContextToken()

  let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

  public init(fileURL: URL) throws {
    self.dbURL = fileURL
    try openConnection()
    dbQueue.setSpecific(key: Self.dbContextKey, value: dbContextValue)
  }

  deinit {
    sqlite3_close(db)
  }

  // MARK: - Internal Helpers

  private func performSync<T>(_ block: () throws -> T) throws -> T {
    if DispatchQueue.getSpecific(key: Self.dbContextKey) === dbContextValue {
      return try block()
    } else {
      return try dbQueue.sync(execute: block)
    }
  }

  private func openConnection() throws {
    let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_URI
    if sqlite3_open_v2(dbURL.path, &db, flags, nil) != SQLITE_OK {
      throw SQLiteError.open(path: dbURL.path)
    }
  }

  private func rollbackTransaction() {
    sqlite3_exec(db, "ROLLBACK TRANSACTION", nil, nil, nil)
  }

  private func sqliteErrorMessage() -> String {
    return String(cString: sqlite3_errmsg(db))
  }

  @discardableResult
  private func exec(_ sql: String, errorMessage: @autoclosure () -> String) throws -> Int32 {
    let result = sqlite3_exec(db, sql, nil, nil, nil)
    if result != SQLITE_OK {
      throw SQLiteError.execution(message: "\(errorMessage()): \(sqliteErrorMessage())")
    }
    return result
  }

  private func prepareStatement(_ sql: String, errorMessage: @autoclosure () -> String) throws -> OpaquePointer? {
    var stmt: OpaquePointer?
    if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
      throw SQLiteError.prepare(message: "\(errorMessage()): \(sqliteErrorMessage())")
    }
    return stmt
  }

  // MARK: - SQLiteDatabase Protocol

  public func createRecordsTableIfNeeded() throws {
    try performSync {
      let sql = """
      CREATE TABLE IF NOT EXISTS "records" (
        "_id"  INTEGER,
        "key"  TEXT UNIQUE,
        "record"  TEXT,
        PRIMARY KEY("_id" AUTOINCREMENT)
      );
      """
      try exec(sql, errorMessage: "Failed to create 'records' database table")
    }
  }

  public func selectRawRows(forKeys keys: Set<CacheKey>) throws -> [DatabaseRow] {
      guard !keys.isEmpty else { return [] }

      let batchSize = 500
      var allRows = [DatabaseRow]()
      let keyBatches = keys.chunked(into: batchSize)

      for batch in keyBatches {
        let rows = try performSync {
          let placeholders = batch.map { _ in "?" }.joined(separator: ", ")
          let sql = """
          SELECT \(Self.keyColumnName), \(Self.recordColumName)
          FROM \(Self.tableName)
          WHERE \(Self.keyColumnName) IN (\(placeholders))
          """

          let stmt = try prepareStatement(sql, errorMessage: "Failed to prepare select statement")
          defer { sqlite3_finalize(stmt) }

          for (index, key) in batch.enumerated() {
            sqlite3_bind_text(stmt, Int32(index + 1), key, -1, SQLITE_TRANSIENT)
          }

          var rows = [DatabaseRow]()
          var result: Int32
          repeat {
            result = sqlite3_step(stmt)
            if result == SQLITE_ROW {
              let key = String(cString: sqlite3_column_text(stmt, 0))
              let record = String(cString: sqlite3_column_text(stmt, 1))
              rows.append(DatabaseRow(cacheKey: key, storedInfo: record))
            } else if result != SQLITE_DONE {
              let errorMsg = String(cString: sqlite3_errmsg(db))
              throw SQLiteError.step(message: "Failed to step raw row select: \(errorMsg)")
            }
          } while result != SQLITE_DONE

          return rows
        }

        allRows.append(contentsOf: rows)
      }

      return allRows
  }

  public func addOrUpdate(records: [(cacheKey: CacheKey, recordString: String)]) throws {
    guard !records.isEmpty else { return }

    try performSync {
      let sql = """
      INSERT INTO \(Self.tableName) (\(Self.keyColumnName), \(Self.recordColumName))
      VALUES (?, ?)
      ON CONFLICT(\(Self.keyColumnName)) DO UPDATE SET \(Self.recordColumName) = excluded.\(Self.recordColumName)
      """

      try exec("BEGIN TRANSACTION", errorMessage: "Failed to begin insert/update transaction")

      let stmt = try prepareStatement(sql, errorMessage: "Failed to prepare insert/update statement")
      defer { sqlite3_finalize(stmt) }

      for (key, record) in records {
        sqlite3_bind_text(stmt, 1, key, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, record, -1, SQLITE_TRANSIENT)

        if sqlite3_step(stmt) != SQLITE_DONE {
          rollbackTransaction()
          throw SQLiteError.step(message: "Insert/update failed: \(sqliteErrorMessage())")
        }

        sqlite3_reset(stmt)
        sqlite3_clear_bindings(stmt)
      }

      do {
        try exec("COMMIT TRANSACTION", errorMessage: "Failed to commit transaction")
      } catch {
        rollbackTransaction()
        throw error
      }
    }
  }

  public func deleteRecord(for cacheKey: CacheKey) throws {
    try performSync {
      let sql = "DELETE FROM \(Self.tableName) WHERE \(Self.keyColumnName) = ?"
      let stmt = try prepareStatement(sql, errorMessage: "Failed to prepare delete statement")
      defer { sqlite3_finalize(stmt) }

      sqlite3_bind_text(stmt, 1, cacheKey, -1, SQLITE_TRANSIENT)
      if sqlite3_step(stmt) != SQLITE_DONE {
        throw SQLiteError.step(message: "Delete failed: \(sqliteErrorMessage())")
      }
    }
  }

  public func deleteRecords(matching pattern: CacheKey) throws {
    guard !pattern.isEmpty else { return }
    let wildcardPattern = "%\(pattern)%"

    try performSync {
      let sql = "DELETE FROM \(Self.tableName) WHERE \(Self.keyColumnName) LIKE ? COLLATE NOCASE"
      let stmt = try prepareStatement(sql, errorMessage: "Failed to prepare delete pattern statement")
      defer { sqlite3_finalize(stmt) }

      sqlite3_bind_text(stmt, 1, wildcardPattern, -1, SQLITE_TRANSIENT)
      if sqlite3_step(stmt) != SQLITE_DONE {
        throw SQLiteError.step(message: "Pattern delete failed: \(sqliteErrorMessage())")
      }
    }
  }

  public func clearDatabase(shouldVacuumOnClear: Bool) throws {
    try performSync {
      try exec("DELETE FROM \(Self.tableName)", errorMessage: "Failed to clear database")
      if shouldVacuumOnClear {
        try exec("VACUUM;", errorMessage: "Failed to vacuum database")
      }
    }
  }

  public func setJournalMode(mode: JournalMode) throws {
    try performSync {
      _ = try exec("PRAGMA journal_mode = \(mode.rawValue);", errorMessage: "Failed to set journal mode")
    }
  }
}

// MARK: - Extensions

extension Array {
  func chunked(into size: Int) -> [[Element]] {
    stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }
}

extension Set {
  func chunked(into size: Int) -> [[Element]] {
    Array(self).chunked(into: size)
  }
}


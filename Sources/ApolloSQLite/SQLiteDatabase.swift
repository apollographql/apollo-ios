import Foundation
#if !COCOAPODS
import Apollo
#endif

public struct DatabaseRow {
  let cacheKey: CacheKey
  let storedInfo: String

  public init(cacheKey: CacheKey, storedInfo: String) {
    self.cacheKey = cacheKey
    self.storedInfo = storedInfo
  }
}

public enum SQLiteError: Error, CustomStringConvertible {
  case execution(message: String, resultCode: Int32)
  case open(path: String, resultCode: Int32)
  case prepare(message: String, resultCode: Int32)
  case step(message: String, resultCode: Int32)
  
  public var description: String {
    switch self {
    case .execution(let message, _):
      return message
    case .open(let path, _):
      return "Failed to open SQLite database connection at path: \(path)"
    case .prepare(let message, _):
      return message
    case .step(let message, _):
      return message
    }
  }
}

public protocol SQLiteDatabase {

  init(fileURL: URL) throws
  
  func createRecordsTableIfNeeded() throws
  
  func selectRawRows(forKeys keys: Set<CacheKey>) throws -> [DatabaseRow]

  func addOrUpdate(records: [(cacheKey: CacheKey, recordString: String)]) throws

  func deleteRecord(for cacheKey: CacheKey) throws

  func deleteRecords(matching pattern: CacheKey) throws
  
  func clearDatabase(shouldVacuumOnClear: Bool) throws

  @available(*, deprecated, renamed: "addOrUpdate(records:)")
  func addOrUpdateRecordString(_ recordString: String, for cacheKey: CacheKey) throws

}

extension SQLiteDatabase {

  public func addOrUpdateRecordString(_ recordString: String, for cacheKey: CacheKey) throws {
    try addOrUpdate(records: [(cacheKey, recordString)])
  }

}

public extension SQLiteDatabase {
  
  static var tableName: String {
    "records"
  }
  
  static var idColumnName: String {
    "_id"
  }

  static var keyColumnName: String {
    "key"
  }

  static var recordColumName: String {
    "record"
  }
}

import Foundation
#if !COCOAPODS
import Apollo
#endif

public struct DatabaseRow {
  let cacheKey: CacheKey
  let storedInfo: String
}

public protocol SQLiteDatabase {
  
  init(fileURL: URL) throws
  
  func createRecordsTableIfNeeded() throws
  
  func selectRawRows(forKeys keys: Set<CacheKey>) throws -> [DatabaseRow]

  func addOrUpdateRecordString(_ recordString: String, for cacheKey: CacheKey) throws
  
  func deleteRecord(for cacheKey: CacheKey) throws

  func deleteRecords(matching pattern: CacheKey) throws
  
  func clearDatabase(shouldVacuumOnClear: Bool) throws
  
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

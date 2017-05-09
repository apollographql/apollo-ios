import Apollo
import ApolloTestSupport
import ApolloSQLite

public class SQLiteTestCacheProvider: TestCacheProvider {
  public static func withCache(initialRecords: RecordSet? = nil, execute test: (NormalizedCache) throws -> ()) rethrows {
    return try withCache(initialRecords: initialRecords, fileURL: nil, execute: test)
  }
  
  /// Execute a test block rather than return a cache synchronously, since cache setup may be
  /// asynchronous at some point.
  public static func withCache(initialRecords: RecordSet? = nil, fileURL: URL? = nil, execute test: (NormalizedCache) throws -> ()) rethrows {
    let fileURL = fileURL ?? temporarySQLiteFileURL()
    let cache = try! SQLiteNormalizedCache(fileURL: fileURL)
    if let initialRecords = initialRecords {
      _ = cache.merge(records: initialRecords) // This is synchronous
    }
    try test(cache)
  }

  public static func temporarySQLiteFileURL() -> URL {
    let applicationSupportPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
    let applicationSupportURL = URL(fileURLWithPath: applicationSupportPath)
    let temporaryDirectoryURL = try! FileManager.default.url(
      for: .itemReplacementDirectory,
      in: .userDomainMask,
      appropriateFor: applicationSupportURL,
      create: true)
    return temporaryDirectoryURL.appendingPathComponent("db.sqlite3")
  }
}

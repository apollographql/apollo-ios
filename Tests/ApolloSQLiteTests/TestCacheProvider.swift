import Apollo
import ApolloSQLite

enum TestCacheProvider {

  /// Execute a test block rather than return a cache synchronously, since cache setup may be
  /// asynchronous at some point.
  static func withCache(initialRecords: RecordSet? = nil, fileURL: URL? = nil, execute test: (NormalizedCache) -> ()) {
    let fileURL = fileURL ?? temporarySQLiteFileURL()
    let cache = try! SQLiteNormalizedCache(fileURL: fileURL)
    if let initialRecords = initialRecords {
      _ = cache.merge(records: initialRecords) // This is synchronous
    }
    test(cache)
  }

  static func temporarySQLiteFileURL() -> URL {
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

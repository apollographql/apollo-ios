import Foundation
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
      cache.merge(records: initialRecords, callbackQueue: nil, completion: { _ in
        // Theoretically, this should be syncrhonous
      }) // This is synchronous
    }
    try test(cache)
  }

  public static func temporarySQLiteFileURL() -> URL {
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
    
    // Create a folder with a random UUID to hold the SQLite file, since creating them in the
    // same folder this close together will cause DB locks when you try to delete between tests.
    let folder = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString)
    try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    
    return folder.appendingPathComponent("db.sqlite3")
  }
}

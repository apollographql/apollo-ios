import Foundation
import Apollo
import ApolloSQLite

public class SQLiteTestCacheProvider: TestCacheProvider {
  /// Execute a test block rather than return a cache synchronously, since cache setup may be
  /// asynchronous at some point.
  public static func withCache(initialRecords: RecordSet? = nil, fileURL: URL? = nil, execute test: (NormalizedCache) throws -> ()) throws {
    let fileURL = fileURL ?? temporarySQLiteFileURL()
    let cache = try! SQLiteNormalizedCache(fileURL: fileURL)
    if let initialRecords = initialRecords {
      _ = try cache.merge(records: initialRecords)
    }
    try test(cache)
  }
  
  public static func makeNormalizedCache(_ completionHandler: (Result<TestDependency<NormalizedCache>, Error>) -> ()) {
    let fileURL = temporarySQLiteFileURL()
    let cache = try! SQLiteNormalizedCache(fileURL: fileURL)
    completionHandler(.success((cache, nil)))
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

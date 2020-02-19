import XCTest
@testable import Apollo
import ApolloTestSupport
#if canImport(ApolloSQLiteTestSupport)
import ApolloSQLiteTestSupport
#endif


public protocol TestCacheProvider: class {
  static func withCache(initialRecords: RecordSet?, execute test: (NormalizedCache) throws -> ()) rethrows
}

public class InMemoryTestCacheProvider: TestCacheProvider {
  /// Execute a test block rather than return a cache synchronously, since cache setup may be
  /// asynchronous at some point.
  public static func withCache(initialRecords: RecordSet? = nil, execute test: (NormalizedCache) throws -> ()) rethrows {
    let cache = InMemoryNormalizedCache(records: initialRecords ?? [:])
    try test(cache)
  }
}

extension XCTestCase {
  public static var bundleDirectoryURL: URL {
    return Bundle(for: self).bundleURL.deletingLastPathComponent()
  }
  
  public static var cacheProviderClass: TestCacheProvider.Type {
    #if canImport(ApolloSQLiteTestSupport)
        return SQLiteTestCacheProvider.self
    #else
        return InMemoryTestCacheProvider.self
    #endif
  }
  
  public func withCache(initialRecords: RecordSet? = nil, execute test: (NormalizedCache) throws -> ()) rethrows {
    return try type(of: self).cacheProviderClass.withCache(initialRecords: initialRecords, execute: test)
  }
}

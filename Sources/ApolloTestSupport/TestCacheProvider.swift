import XCTest
@testable import Apollo

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

public protocol CacheTesting {
  var cacheType: TestCacheProvider.Type { get }
}

extension CacheTesting where Self: XCTestCase {
  
  public func withCache(initialRecords: RecordSet? = nil, execute test: (NormalizedCache) throws -> ()) rethrows {
    return try self.cacheType.withCache(initialRecords: initialRecords, execute: test)
  }
}

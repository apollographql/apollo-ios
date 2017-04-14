import Apollo

enum TestCacheProvider {

  /// Execute a test block rather than return a cache synchronously, since cache setup may be
  /// asynchronous at some point.
  static func withCache(initialRecords: RecordSet? = nil, execute test: (NormalizedCache) -> ()) {
    let cache = InMemoryNormalizedCache(records: initialRecords ?? [:])
    test(cache)
  }
}

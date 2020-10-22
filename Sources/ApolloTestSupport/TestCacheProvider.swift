import XCTest
@testable import Apollo

public typealias TearDownHandler = () throws -> ()
public typealias TestDependency<Resource> = (Resource, TearDownHandler?)

public protocol TestCacheProvider: class {
  static func makeNormalizedCache(_ completionHandler: (Result<TestDependency<NormalizedCache>, Error>) -> ())

  static func withCache(initialRecords: RecordSet?, execute test: (NormalizedCache) throws -> ()) rethrows
}

public class InMemoryTestCacheProvider: TestCacheProvider {
  /// Execute a test block rather than return a cache synchronously, since cache setup may be
  /// asynchronous at some point.
  public static func withCache(initialRecords: RecordSet? = nil, execute test: (NormalizedCache) throws -> ()) rethrows {
    let cache = InMemoryNormalizedCache(records: initialRecords ?? [:])
    try test(cache)
  }
  
  public static func makeNormalizedCache(_ completionHandler: (Result<TestDependency<NormalizedCache>, Error>) -> ()) {
    let cache = InMemoryNormalizedCache()
    completionHandler(.success((cache, nil)))
  }
}

public protocol CacheTesting {
  var cacheType: TestCacheProvider.Type { get }
}

extension CacheTesting where Self: XCTestCase {
  
  public func withCache(initialRecords: RecordSet? = nil, execute test: (NormalizedCache) throws -> ()) rethrows {
    return try self.cacheType.withCache(initialRecords: initialRecords, execute: test)
  }
  
  public func makeNormalizedCache() throws -> NormalizedCache {
    var result: Result<NormalizedCache, Error> = .failure(XCTestError(.timeoutWhileWaiting))
    
    let expectation = XCTestExpectation(description: "Initialized normalized cache")
          
    cacheType.makeNormalizedCache() { [weak self] testDependencyResult in
      guard let self = self else { return }
      
      result = testDependencyResult.map { testDependency in
        let (cache, tearDownHandler) = testDependency
        
        if let tearDownHandler = tearDownHandler {
          self.addTeardownBlock {
            do {
              try tearDownHandler()
            } catch {
              self.record(error)
            }
          }
        }
        
        return cache
      }
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 1)
    
    return try result.get()
  }
}

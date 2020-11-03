import XCTest
@testable import Apollo

public typealias TearDownHandler = () throws -> ()
public typealias TestDependency<Resource> = (Resource, TearDownHandler?)

public protocol TestCacheProvider: class {
  static func makeNormalizedCache(_ completionHandler: (Result<TestDependency<NormalizedCache>, Error>) -> ())
}

public class InMemoryTestCacheProvider: TestCacheProvider {
  public static func makeNormalizedCache(_ completionHandler: (Result<TestDependency<NormalizedCache>, Error>) -> ()) {
    let cache = InMemoryNormalizedCache()
    completionHandler(.success((cache, nil)))
  }
}

public protocol CacheTesting {
  var cacheType: TestCacheProvider.Type { get }
  var cache: NormalizedCache! { get }
  var defaultWaitTimeout: TimeInterval { get }
}

extension CacheTesting where Self: XCTestCase {
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
  
  public func mergeRecordsIntoCache(_ records: RecordSet) {
    let expectation = expectSuccessfulResult(description: "Merged records into normalized cache") { handler in
      cache.merge(records: records, callbackQueue: nil, completion: handler)
    }
        
    wait(for: [expectation], timeout: defaultWaitTimeout)
  }
}

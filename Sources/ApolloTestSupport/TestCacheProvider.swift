import XCTest
@testable import Apollo

public typealias TearDownHandler = () throws -> ()
public typealias TestDependency<Resource> = (Resource, TearDownHandler?)

public protocol TestCacheProvider: AnyObject {
  static func makeNormalizedCache(_ completionHandler: (Result<TestDependency<NormalizedCache>, Error>) -> ())
}

public class InMemoryTestCacheProvider: TestCacheProvider {
  public static func makeNormalizedCache(_ completionHandler: (Result<TestDependency<NormalizedCache>, Error>) -> ()) {
    let cache = InMemoryNormalizedCache()
    completionHandler(.success((cache, nil)))
  }
}

public protocol CacheDependentTesting {
  var cacheType: TestCacheProvider.Type { get }
  var cache: NormalizedCache! { get }  
}

extension CacheDependentTesting where Self: XCTestCase {
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
    _ = try! cache.merge(records: records)
  }
}

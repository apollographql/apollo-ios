import XCTest
@testable import Apollo
import StarWarsAPI

class DataLoaderTests: XCTestCase {
  func testSingleLoad() {
    let loader = DataLoader<Int, Int> { keys in
      return Promise(fulfilled: keys)
    }
    
    let expectation = self.expectation(description: "Waiting for load")
    
    loader.load(key: 1).andThen { value in
      XCTAssertEqual(value, 1)
      expectation.fulfill()
    }
    
    loader.dispatch()
    
    waitForExpectations(timeout: 1)
  }
  
  func testMultipleLoads() {
    var numberOfBatchLoads = 0
    
    let loader = DataLoader<Int, Int> { keys in
      numberOfBatchLoads += 1
      return Promise(fulfilled: keys)
    }
    
    let expectation = self.expectation(description: "Waiting for all loads")
    
    let promises = [loader.load(key: 1), loader.load(key: 2)]
    
    whenAll(promises, notifyOn: DispatchQueue.global()).andThen { values in
      XCTAssertEqual(values, [1, 2])
      XCTAssertEqual(numberOfBatchLoads, 1)
      expectation.fulfill()
    }
    
    loader.dispatch()
    
    waitForExpectations(timeout: 1)
  }
}

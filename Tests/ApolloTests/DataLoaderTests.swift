import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class DataLoaderTests: XCTestCase {
  func testSingleLoad() {
    let loader = DataLoader<Int, Int> { keys in
      return Promise(fulfilled: keys)
    }
    
    let expectation = self.expectation(description: "Waiting for load")
    
    loader[1].andThen { value in
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
    
    let promises = [loader[1], loader[2]]
    
    whenAll(promises).andThen { values in
      XCTAssertEqual(values, [1, 2])
      XCTAssertEqual(numberOfBatchLoads, 1)
      expectation.fulfill()
    }
    
    loader.dispatch()
    
    waitForExpectations(timeout: 1)
  }
  
  func testCoalescesIdenticalRequests() {
    var batchLoads: [[Int]] = []
    
    let loader = DataLoader<Int, Int> { keys in
      batchLoads.append(keys)
      return Promise(fulfilled: keys)
    }
    
    let expectation = self.expectation(description: "Waiting for all loads")
    
    let promises = [loader[1], loader[1]]
    
    whenAll(promises).andThen { values in
      XCTAssertEqual(values, [1, 1])
      XCTAssertEqual(batchLoads.count, 1)
      XCTAssertEqual(batchLoads[0], [1])
      expectation.fulfill()
    }
    
    loader.dispatch()
    
    waitForExpectations(timeout: 1)
  }
  
  func testCachesRepeatedRequests() {
    var batchLoads: [[String]] = []
    
    let loader = DataLoader<String, String> { keys in
      batchLoads.append(keys)
      return Promise(fulfilled: keys)
    }
    
    let expectation1 = self.expectation(description: "Waiting for all loads")
    
    let promises1 = [loader["A"], loader["B"]]
    
    whenAll(promises1).andThen { values in
      XCTAssertEqual(values, ["A", "B"])
      XCTAssertEqual(batchLoads.count, 1)
      XCTAssertEqual(batchLoads[0], ["A", "B"])
      expectation1.fulfill()
    }
    
    loader.dispatch()
    
    waitForExpectations(timeout: 1)
    
    let expectation2 = self.expectation(description: "Waiting for all loads")
    
    let promises2 = [loader["A"], loader["C"]]
    
    whenAll(promises2).andThen { values in
      XCTAssertEqual(values, ["A", "C"])
      XCTAssertEqual(batchLoads.count, 2)
      XCTAssertEqual(batchLoads[1], ["C"])
      expectation2.fulfill()
    }
    
    loader.dispatch()
    
    waitForExpectations(timeout: 1)
    
    let expectation3 = self.expectation(description: "Waiting for all loads")
    
    let promises3 = [loader["A"], loader["B"], loader["C"]]
    
    whenAll(promises3).andThen { values in
      XCTAssertEqual(values, ["A", "B", "C"])
      XCTAssertEqual(batchLoads.count, 2)
      expectation3.fulfill()
    }
    
    loader.dispatch()
    
    waitForExpectations(timeout: 1)
  }
}

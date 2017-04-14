import XCTest
@testable import Apollo

class PromiseTests: XCTestCase {
  func testParallelPerformance() {
    let queue = DispatchQueue.global()
    
    let range = 1...1000
    
    measure {
      let promises = range.map { number in
        return Promise<Int> { fulfill, reject in
          queue.async {
            fulfill(number)
          }
        }
      }
      
      let expectation = self.expectation(description: "Waiting for all promises to be fulfilled")
      
      whenAll(promises, notifyOn: queue).andThen { values in
        XCTAssertEqual(values, Array(range))
        expectation.fulfill()
      }
      
      self.waitForExpectations(timeout: 1)
    }
  }
  
  func testSerialPerformance() {
    let queue = DispatchQueue.global()
    
    let range = 1...1000
        
    measure {
      let promise: Promise<[Int]> = range.reduce(Promise(fulfilled: [])) { promise, number in
        return promise.flatMap { values in
          return Promise { fulfill, reject in
            queue.async {
              var values = values
              values.append(number)
              fulfill(values)
            }
          }
        }
      }
      
      let expectation = self.expectation(description: "Waiting for promise to be fulfilled")
      
      promise.andThen { values in
        XCTAssertEqual(values, Array(range))
        expectation.fulfill()
      }
      
      self.waitForExpectations(timeout: 1)
    }
  }
}

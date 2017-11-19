import XCTest
@testable import Apollo

class CancelControllerTests: XCTestCase {
  func testSignalIsNotCancelledInitially() {
    let controller = CancelController()
    
    XCTAssertFalse(controller.signal.isCancelled)
  }
  
  func testSignalIsCancelledAfterCancel() {
    let controller = CancelController()
    controller.cancel()
    
    XCTAssert(controller.signal.isCancelled)
  }
  
  func testCallsOnCancelHandlerWhenCancelled() {
    let controller = CancelController()
    controller.cancel()

    let expectation = self.expectation(description: "onCancel handler invoked")

    controller.signal.onCancel {
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1)
  }
  
  func testCallsOnCancelHandlerAfterCancel() {
    let controller = CancelController()
    
    let expectation = self.expectation(description: "onCancel handler invoked")
    
    controller.signal.onCancel {
      expectation.fulfill()
    }
    
    controller.cancel()
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testCallsAllOnCancelHandler() {
    let controller = CancelController()
    
    let expectations = (1..<5).map { _ -> XCTestExpectation in
      let expectation = self.expectation(description: "onCancel handler invoked")
      
      controller.signal.onCancel {
        expectation.fulfill()
      }
      
      return expectation
    }
    
    controller.cancel()
    
    wait(for: expectations, timeout: 0.1)
  }
}

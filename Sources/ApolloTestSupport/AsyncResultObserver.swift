import XCTest

public class AsyncResultObserver<Success, Failure> where Failure: Error {
  public typealias ResultHandler = (Result<Success, Failure>) throws -> Void
  
  private class AsyncResultExpectation: XCTestExpectation {
    let file: StaticString
    let line: UInt
    let handler: ResultHandler?
    
    init(description: String, file: StaticString = #filePath, line: UInt = #line, handler: ResultHandler?) {
      self.file = file
      self.line = line
      self.handler = handler

      super.init(description: description)
    }
  }
  
  private let testCase: XCTestCase
  private var expectations: [AsyncResultExpectation] = []
  
  public init(testCase: XCTestCase) {
    self.testCase = testCase
  }
  
  public func expectation(description: String, file: StaticString = #filePath, line: UInt = #line, resultHandler: ResultHandler? = nil) -> XCTestExpectation {
    let expectation = AsyncResultExpectation(description: description, file: file, line: line, handler: resultHandler)
    expectation.assertForOverFulfill = true
    
    expectations.append(expectation)
    
    return expectation
  }
  
  public func handler(_ result: Result<Success, Failure>) {
    guard let expectation = expectations.first else {
      XCTFail("Unexpected result received by handler")
      return
    }
        
    if let handler = expectation.handler {
      do {
        try handler(result)
      } catch {
        testCase.record(error, file: expectation.file, line: expectation.line)
      }
    } else if case .failure(let error) = result {
      testCase.record(error, file: expectation.file, line: expectation.line)
    }
    
    expectation.fulfill()
    
    if expectation.numberOfFulfillments >= expectation.expectedFulfillmentCount {
      expectations.removeFirst()
    }
  }
}

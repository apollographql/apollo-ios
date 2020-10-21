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
  
  private var expectations: [AsyncResultExpectation] = []
  
  public init() {
  }
  
  public func expectation(description: String, file: StaticString = #filePath, line: UInt = #line, resultHandler: ResultHandler? = nil) -> XCTestExpectation {
    let expectation = AsyncResultExpectation(description: description, file: file, line: line, handler: resultHandler)
    
    expectations.append(expectation)
    
    return expectation
  }
  
  public func handler(_ result: Result<Success, Failure>) {
    precondition(!expectations.isEmpty)
    let expectation = expectations.removeFirst()
    
    if let handler = expectation.handler {
      XCTAssertNoThrow(try handler(result), file: expectation.file, line: expectation.line)
    }
    
    expectation.fulfill()
  }
}

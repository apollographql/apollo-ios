import XCTest

/// `AsyncResultObserver` is a helper class that can be used to test `Result` values received through a completion handler against one or more expectations. It is primarily useful if you expect the completion handler to be called multiple times,  when receiving a fetch result from the cache and then from the server for example.
///
/// The main benefit is that it avoids having to manually keep track of expectations and mutable closures (like `verifyResult`), which can make code hard to read and is prone to mistakes. Instead, you can use a result observer to create multiple expectations that will be automatically fulfilled in order when results are received. Often, you'll also want to run assertions against the result, which you can do by passing in an optional handler that is specific to that expectation. These handlers are throwing, which means you can use `result.get()` and `XCTUnwrap` for example. Thrown errors will automatically be recorded as failures in the test case (with the right line numbers, etc.).
///
/// By default, expectations returned from `AsyncResultObserver` only expect to be called once, which is similar to how other built-in expectations work. Unexpected fulfillments will result in test failures. Usually this is what you want, and you add additional expectations with their own assertions if you expect further results.
/// If multiple fulfillments of a single expectation are expected however, you can use the standard `expectedFulfillmentCount` property to change that.
public class AsyncResultObserver<Success, Failure> where Failure: Error {
  public typealias ResultHandler = (Result<Success, Failure>) throws -> Void
  
  private class AsyncResultExpectation: XCTestExpectation {
    let file: StaticString
    let line: UInt
    let handler: ResultHandler
    
    init(description: String, file: StaticString = #filePath, line: UInt = #line, handler: @escaping ResultHandler) {
      self.file = file
      self.line = line
      self.handler = handler

      super.init(description: description)
    }
  }

  private let testCase: XCTestCase
  
  // We keep track of the file and line number associated with the constructor as a fallback, in addition te keeping
  // these for each expectation. That way, we can still show a failure within the context of the test in case unexpected
  // results are received (which by definition do not have an associated expectation).
  private let file: StaticString
  private let line: UInt
  
  private var expectations: [AsyncResultExpectation] = []
  
  public init(testCase: XCTestCase, file: StaticString = #filePath, line: UInt = #line) {
    self.testCase = testCase
    self.file = file
    self.line = line
  }
  
  public func expectation(description: String, file: StaticString = #filePath, line: UInt = #line, resultHandler: @escaping ResultHandler) -> XCTestExpectation {
    let expectation = AsyncResultExpectation(description: description, file: file, line: line, handler: resultHandler)
    expectation.assertForOverFulfill = true
    
    expectations.append(expectation)
    
    return expectation
  }
  
  public func handler(_ result: Result<Success, Failure>) {
    guard let expectation = expectations.first else {
      XCTFail("Unexpected result received by handler", file: file, line: line)
      return
    }
        
    do {
      try expectation.handler(result)
    } catch {
      testCase.record(error, file: expectation.file, line: expectation.line)
    }
    
    expectation.fulfill()
    
    if expectation.numberOfFulfillments >= expectation.expectedFulfillmentCount {
      expectations.removeFirst()
    }
  }
}


import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

private struct TestError: Error {}
private struct OtherTestError: Error {}

class ResultOrPromiseTests: XCTestCase {
  func testSuccessResult() {
    let resultOrPromise = ResultOrPromise.result(.success("foo"))
    
    XCTAssertEqual(resultOrPromise.result?.value, "foo")
  }
  
  func testFailureResult() {
    let resultOrPromise = ResultOrPromise<String>.result(.failure(TestError()))
    
    XCTAssertNil(resultOrPromise.result?.value)
    XCTAssert(resultOrPromise.result?.error is TestError)
  }
  
  func testResultOfFulfilledPromise() {
    let resultOrPromise = ResultOrPromise.promise(Promise<String>(fulfilled: "foo"))
    
    XCTAssertEqual(resultOrPromise.result?.value, "foo")
  }
  
  func testResultOfRejectedPromise() {
    let resultOrPromise = ResultOrPromise.promise(Promise<String>(rejected: TestError()))
    
    XCTAssertNil(resultOrPromise.result?.value)
    XCTAssert(resultOrPromise.result?.error is TestError)
  }
  
  func testWaitForSuccessResult() throws {
    let resultOrPromise = ResultOrPromise.result(.success("foo"))
    
    XCTAssertEqual(try resultOrPromise.await(), "foo")
  }
  
  func testWaitForFailureResult() {
    let resultOrPromise = ResultOrPromise<String>.result(.failure(TestError()))
    
    XCTAssertThrowsError(try resultOrPromise.await()) { error in
      XCTAssert(error is TestError)
    }
  }
  
  func testWaitForResultOfFulfilledPromise() throws {
    let resultOrPromise = ResultOrPromise.promise(Promise<String>(fulfilled: "foo"))
    
    XCTAssertEqual(try resultOrPromise.await(), "foo")
  }
  
  func testWaitForResultOfRejectedPromise() {
    let resultOrPromise = ResultOrPromise.promise(Promise<String>(rejected: TestError()))
    
    XCTAssertThrowsError(try resultOrPromise.await()) { error in
      XCTAssert(error is TestError)
    }
  }
  
  func testSuccessResultAndThen() {
    let resultOrPromise = ResultOrPromise.result(.success("foo"))
    
    let expectation = self.expectation(description: "andThen handler invoked")
    
    resultOrPromise.andThen { value in
      XCTAssertEqual(value, "foo")
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testFailureResultCatch() {
    let resultOrPromise = ResultOrPromise<String>.result(.failure(TestError()))
    
    let expectation = self.expectation(description: "catch handler invoked")
    
    resultOrPromise.catch { error in
      XCTAssert(error is TestError)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testFulfilledPromiseAndThen() {
    let resultOrPromise = ResultOrPromise.promise(Promise<String>(fulfilled: "foo"))
    
    let expectation = self.expectation(description: "andThen handler invoked")
    
    resultOrPromise.andThen { value in
      XCTAssertEqual(value, "foo")
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testRejectedPromiseCatch() {
    let resultOrPromise = ResultOrPromise.promise(Promise<String>(rejected: TestError()))
    
    let expectation = self.expectation(description: "catch handler invoked")
    
    resultOrPromise.catch { error in
      XCTAssert(error is TestError)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  // When all
  
  func testWhenAllWithSuccessResults() throws {
    let queue = DispatchQueue(label: "callingQueue")
    
    let key = DispatchSpecificKey<Void>()
    queue.setSpecific(key: key, value: ())
    
    let resultOrPromises: [ResultOrPromise<String>] = [.result(.success("foo")), .result(.success("bar"))]
    
    let expectation = self.expectation(description: "whenAll andThen handler invoked")
    
    queue.async {
      whenAll(resultOrPromises).andThen { values in
        XCTAssertEqual(values, ["foo", "bar"])
        XCTAssertNotNil(DispatchQueue.getSpecific(key: key))
        
        expectation.fulfill()
      }
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testWhenAllWithFulfilledPromises() throws {
    let resultOrPromises: [ResultOrPromise<String>] = [.promise(Promise(fulfilled: "foo")), .promise(Promise(fulfilled: "bar"))]
    
    let expectation = self.expectation(description: "whenAll andThen handler invoked")
    
    whenAll(resultOrPromises).andThen { values in
      XCTAssertEqual(values, ["foo", "bar"])
      
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testWhenAllWithBothSuccessResultsAndFulfilledPromises() throws {
    let resultOrPromises: [ResultOrPromise<String>] = [.promise(Promise(fulfilled: "foo")), .result(.success("bar"))]
    
    let expectation = self.expectation(description: "whenAll andThen handler invoked")
    
    whenAll(resultOrPromises).andThen { values in
      XCTAssertEqual(values, ["foo", "bar"])
      
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testWhenAllRejectsWhenAnyOfTheResultsIsAFailure() throws {
    let queue = DispatchQueue(label: "callingQueue")
    
    let key = DispatchSpecificKey<Void>()
    queue.setSpecific(key: key, value: ())
    
    let resultOrPromises: [ResultOrPromise<String>] = [.result(.success("foo")), .result(.failure(TestError())), .result(.success("bar"))]
    
    let expectation = self.expectation(description: "whenAll catch handler invoked")
    
    queue.async {
      whenAll(resultOrPromises).catch { error in
        XCTAssert(error is TestError)
        XCTAssertNotNil(DispatchQueue.getSpecific(key: key))
        
        expectation.fulfill()
      }
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testWhenAllRejectsWhenAnyOfThePromisesRejects() throws {
    let resultOrPromises: [ResultOrPromise<String>] = [.promise(Promise(fulfilled: "foo")), .promise(Promise(rejected: TestError())), .promise(Promise(fulfilled: "bar"))]
    
    let expectation = self.expectation(description: "whenAll catch handler invoked")
    
    whenAll(resultOrPromises).catch { error in
      XCTAssert(error is TestError)
      
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testWhenAllRejectsWhenAnyOfThePromisesRejectsInAListThatAlsoContainsSuccessResults() throws {
    let resultOrPromises: [ResultOrPromise<String>] = [.result(.success("foo")), .promise(Promise(rejected: TestError())), .result(.success("bar"))]
    
    let expectation = self.expectation(description: "whenAll catch handler invoked")
    
    whenAll(resultOrPromises).catch { error in
      XCTAssert(error is TestError)
      
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testWhenAllRejectsWhenAnyOfTheResultsIsAFailureInAListThatAlsoContainsFulfilledPromises() throws {
    let resultOrPromises: [ResultOrPromise<String>] = [.promise(Promise(fulfilled: "foo")), .result(.failure(TestError())), .promise(Promise(fulfilled: "bar"))]
    
    let expectation = self.expectation(description: "whenAll catch handler invoked")
    
    whenAll(resultOrPromises).catch { error in
      XCTAssert(error is TestError)
      
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
}

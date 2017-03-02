import XCTest
@testable import Apollo

struct TestError: Error {
}

class PromiseTests: XCTestCase {
  func testImmediatelyFulfilledPromise() {
    let promise = Promise<String>(fulfilled: "foo")
    
    XCTAssertEqual(promise.value, "foo")
  }
  
  func testImmediatelyRejectedPromise() {
    let promise = Promise<String>(rejected: TestError())
    
    XCTAssertNil(promise.value)
    XCTAssert(promise.error is TestError)
  }
  
  func testImmediatelyFulfilledPromiseWait() throws {
    let promise = Promise<String>(fulfilled: "foo")
    
    XCTAssertEqual(try promise.wait(), "foo")
  }
  
  func testImmediatelyRejectedPromiseWait() {
    let promise = Promise<String>(rejected: TestError())
    
    XCTAssertThrowsError(try promise.wait()) { error in
      XCTAssert(promise.error is TestError)
    }
  }
  
  func testImmediatelyFulfilledPromiseThen() {
    let promise = Promise<String>(fulfilled: "foo")
    
    let expectation = self.expectation(description: "Waiting for promise then()")
    
    promise.then(on: DispatchQueue.global()) { value in
      XCTAssertEqual(value, "foo")
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1, handler: nil)
  }
  
  func testImmediatelyRejectedPromiseCatch() {
    let promise = Promise<String>(rejected: TestError())
    
    let expectation = self.expectation(description: "Waiting for promise then()")
    
    promise.catch(on: DispatchQueue.global()) { error in
      XCTAssert(error is TestError)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1, handler: nil)
  }
  
  func testManuallyFulfilledPromise() {
    let promise = Promise<String> { (fulfill, reject) in
      fulfill("foo")
    }
    
    XCTAssertEqual(promise.value, "foo")
  }
  
  func testManuallyFulfilledPromiseWait() throws {
    let promise = Promise<String> { (fulfill, reject) in
      fulfill("foo")
    }
    
    XCTAssertEqual(try promise.wait(), "foo")
  }
  
  func testManuallyRejectedPromise() {
    let promise = Promise<String> { (fulfill, reject) in
      reject(TestError())
    }

    XCTAssert(promise.error is TestError)
  }
  
  func testManuallyRejectedPromiseWait() {
    let promise = Promise<String> { (fulfill, reject) in
      reject(TestError())
    }
    
    XCTAssertThrowsError(try promise.wait()) { error in
      XCTAssert(promise.error is TestError)
    }
  }
  
  func testAllDictionary() throws {
    let promises = [
      "name": Promise(fulfilled: "Luke Skywalker"),
      "age": Promise(fulfilled: 18)
    ] as [String : Promise<Any>]
    
    let values = try whenAll(valuesOf: promises, on: DispatchQueue(label: "test")).wait()
    
    XCTAssertEqual(values, ["name": "Luke Skywalker", "age": 18])
  }
}

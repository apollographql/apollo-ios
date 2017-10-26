//
//  PromisedCancellableTests.swift
//  ApolloTests
//
//  Created by Marc Haisenko on 26.10.17.
//  Copyright © 2017 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import Apollo

// Progress is cancellable, add the protocol.
extension Progress: Cancellable {
}

class PromisedCancellableTests: XCTestCase {

  func testSynchronousCancel() {
    let progress = Progress(totalUnitCount: 1)
    let promise = Promise<Cancellable>(fulfilled: progress)
    let cancellable = PromisedCancellable(promise: promise)
    
    XCTAssertFalse(progress.isCancelled)
    XCTAssertFalse(cancellable.isCancelled)
    
    cancellable.cancel()
    
    XCTAssertTrue(progress.isCancelled)
    XCTAssertTrue(cancellable.isCancelled)
  }

  func testAsynchronousFulfilledCancel() {
    let expectation = self.expectation(description: "async")
    
    let progress = Progress(totalUnitCount: 1)
    let promise = Promise<Cancellable> {
      (fulfill, reject) in
      
      DispatchQueue.main.async {
        fulfill(progress)
        expectation.fulfill()
      }
    }
    let cancellable = PromisedCancellable(promise: promise)
    
    XCTAssertFalse(progress.isCancelled)
    XCTAssertFalse(cancellable.isCancelled)
    
    // This notes that the PromisedCancellable is cancelled, but since the promise is not yet
    // fulfilled the Progress will not be cancelled yet.
    cancellable.cancel()
    
    XCTAssertFalse(progress.isCancelled)
    XCTAssertTrue(cancellable.isCancelled)
    
    // Wait for asynchronous operation. The Progress immediately gets cancelled when the promise
    // is fulfilled.
    waitForExpectations(timeout: 1)
    
    XCTAssertTrue(progress.isCancelled)
    XCTAssertTrue(cancellable.isCancelled)
  }
  
  func testAsynchronousFulfilledCancelWithRejection() {
    let expectation = self.expectation(description: "async")

    var cancellable: PromisedCancellable?
    let promise = Promise<Cancellable> {
      (fulfill, reject) in
      
      DispatchQueue.main.async {
        // If the cancellable was cancelled before the asynchronous operation finished, reject the
        // promise and don't even start the actual "work".
        XCTAssertNotNil(cancellable)
        if let cancellable = cancellable, cancellable.isCancelled {
          reject(POSIXError(.ECANCELED))
        } else {
          fulfill(Progress(totalUnitCount: 1))
        }
        expectation.fulfill()
      }
    }
    
    let actualCancellable = PromisedCancellable(promise: promise)
    cancellable = actualCancellable
    
    XCTAssertFalse(actualCancellable.isCancelled)
    XCTAssertTrue(actualCancellable.promise.isPending)
    
    actualCancellable.cancel()

    XCTAssertTrue(actualCancellable.isCancelled)
    XCTAssertTrue(actualCancellable.promise.isPending)

    waitForExpectations(timeout: 1)

    // The promise should now have seen that the PromisedCancellable was cancelled before the async
    // operation of the promise was able to execute. Instead of fulfilling the promise the block
    // should have rejected it.
    XCTAssertTrue(actualCancellable.isCancelled)
    XCTAssertFalse(actualCancellable.promise.isPending)
    if let error = actualCancellable.promise.result?.error as? POSIXError {
      XCTAssertEqual(error, POSIXError(.ECANCELED))
    } else {
      XCTFail()
    }
  }

}

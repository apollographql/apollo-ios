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

}

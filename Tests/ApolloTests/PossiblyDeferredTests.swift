import XCTest
@testable import Apollo
import ApolloInternalTestHelpers

private struct TestError: Error {}
private struct OtherTestError: Error {}

class PossiblyDeferredTests: XCTestCase {
  func testImmediateSuccess() throws {
    let possiblyDeferred = PossiblyDeferred.immediate(.success("foo"))
    
    XCTAssertEqual(try possiblyDeferred.get(), "foo")
  }
  
  func testImmediateFailure() {
    let possiblyDeferred = PossiblyDeferred<String>.immediate(.failure(TestError()))
    
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
  }
  
  func testDeferredSuccess() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred.deferred { () -> String in
      numberOfInvocations += 1
      return "foo"
    }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertEqual(try possiblyDeferred.get(), "foo")
    XCTAssertEqual(numberOfInvocations, 1)
  }
  
  func testDeferredFailure() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred.deferred { () -> String in
      numberOfInvocations += 1
      throw TestError()
    }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
    XCTAssertEqual(numberOfInvocations, 1)
  }
  
  // MARK: - Map
  
  func testMapOverImmediateSuccessIsImmediate() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred.immediate(.success("foo"))
      .map { value -> String in
        numberOfInvocations += 1
        return value + "bar"
      }
    
    XCTAssertEqual(numberOfInvocations, 1)
    XCTAssertEqual(try possiblyDeferred.get(), "foobar")
    XCTAssertEqual(numberOfInvocations, 1)
  }
  
  func testMapOverDeferredSuccessIsDeferred() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred.deferred { "foo" }
      .map { value -> String in
        numberOfInvocations += 1
        return value + "bar"
      }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertEqual(try possiblyDeferred.get(), "foobar")
    XCTAssertEqual(numberOfInvocations, 1)
  }
  
  func testMapOverImmediateFailureIsNotInvoked() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred<String>.immediate(.failure(TestError()))
      .map { value -> String in
        numberOfInvocations += 1
        return value + "bar"
      }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
    XCTAssertEqual(numberOfInvocations, 0)
  }
  
  func testMapOverDeferredFailureIsNotInvoked() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred<String>.deferred { throw TestError() }
      .map { value -> String in
        numberOfInvocations += 1
        return value + "bar"
      }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
    XCTAssertEqual(numberOfInvocations, 0)
  }
  
  func testMapPropagatesError() {
    let possiblyDeferred = PossiblyDeferred<String>.deferred { throw TestError() }
      .map { _ in "foo" }
    
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
  }
  
  func testErrorThrownFromMapIsPropagated() {
    let possiblyDeferred = PossiblyDeferred.deferred { "foo" }
      .map { _ in throw TestError() }
    
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
  }
  
  // MARK: - Flat map
  
  func testImmediateFlatMapOverImmediateSuccessIsImmediate() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred.immediate(.success("foo"))
      .flatMap { value -> PossiblyDeferred<String> in
        numberOfInvocations += 1
        return .immediate(.success(value + "bar"))
      }
    
    XCTAssertEqual(numberOfInvocations, 1)
    XCTAssertEqual(try possiblyDeferred.get(), "foobar")
    XCTAssertEqual(numberOfInvocations, 1)
  }
  
  func testImmediateFlatMapOverDeferredSuccessIsDeferred() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred.deferred { "foo" }
      .flatMap { value -> PossiblyDeferred<String> in
        numberOfInvocations += 1
        return .immediate(.success(value + "bar"))
      }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertEqual(try possiblyDeferred.get(), "foobar")
    XCTAssertEqual(numberOfInvocations, 1)
  }
  
  func testDeferredFlatMapOverImmediateSuccessIsDeferred() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred.immediate(.success("foo"))
      .flatMap { value -> PossiblyDeferred<String> in
        return .deferred {
          numberOfInvocations += 1
          return value + "bar"
        }
      }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertEqual(try possiblyDeferred.get(), "foobar")
    XCTAssertEqual(numberOfInvocations, 1)
  }
  
  func testDeferredFlatMapOverDeferredSuccessIsDeferred() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred.deferred { "foo" }
      .flatMap { value -> PossiblyDeferred<String> in
        numberOfInvocations += 1
        return .deferred { value + "bar" }
      }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertEqual(try possiblyDeferred.get(), "foobar")
    XCTAssertEqual(numberOfInvocations, 1)
  }
  
  func testImmediateFlatMapOverImmediateFailureIsNotInvoked() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred<String>.immediate(.failure(TestError()))
      .flatMap { value -> PossiblyDeferred<String> in
        numberOfInvocations += 1
        return .immediate(.success(value + "bar"))
      }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
    XCTAssertEqual(numberOfInvocations, 0)
  }
  
  func testImmediateFlatMapOverDeferredFailureIsNotInvoked() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred<String>.deferred { throw TestError() }
      .flatMap { value -> PossiblyDeferred<String> in
        numberOfInvocations += 1
        return .immediate(.success(value + "bar"))
      }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
    XCTAssertEqual(numberOfInvocations, 0)
  }
  
  func testDeferredFlatMapOverImmediateFailureIsNotInvoked() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred<String>.immediate(.failure(TestError()))
      .flatMap { value -> PossiblyDeferred<String> in
        numberOfInvocations += 1
        return .immediate(.success(value + "bar"))
      }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
    XCTAssertEqual(numberOfInvocations, 0)
  }
  
  func testDeferredFlatMapOverDeferredFailureIsNotInvoked() {
    var numberOfInvocations = 0
    
    let possiblyDeferred = PossiblyDeferred<String>.deferred { throw TestError() }
      .flatMap { value -> PossiblyDeferred<String> in
        numberOfInvocations += 1
        return .immediate(.success(value + "bar"))
      }
    
    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
    XCTAssertEqual(numberOfInvocations, 0)
  }
  
  func testFlatMapPropagatesError() {
    let possiblyDeferred = PossiblyDeferred<String>.deferred { throw TestError() }
      .flatMap { _ in .immediate(.success("foo")) }
    
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
  }
  
  func testErrorReturnedFromFlatMapIsPropagated() {
    let possiblyDeferred = PossiblyDeferred.deferred { "foo" }
      .flatMap { _ -> PossiblyDeferred<String> in .immediate(.failure(TestError())) }
    
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is TestError)
    }
  }

  // MARK: - Map error
  
  func testMapErrorOverImmediateFailure() {
    let possiblyDeferred = PossiblyDeferred<String>.immediate(.failure(TestError()))
      .mapError { error in
        XCTAssert(error is TestError)
        return OtherTestError()
      }
    
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is OtherTestError)
    }
  }
  
  func testMapErrorOverDeferredFailure() {
    let possiblyDeferred = PossiblyDeferred<String>.deferred { throw TestError() }
      .mapError { error in
        XCTAssert(error is TestError)
        return OtherTestError()
      }
    
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is OtherTestError)
    }
  }
  
  func testMapErrorOverMapOverImmediateFailure() {
    let possiblyDeferred = PossiblyDeferred<String>.immediate(.failure(TestError()))
      .map { _ in "foo" }
      .mapError { error in
        XCTAssert(error is TestError)
        return OtherTestError()
      }
    
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is OtherTestError)
    }
  }
  
  func testMapErrorOverMapOverDeferredFailure() {
    let possiblyDeferred = PossiblyDeferred<String>.deferred { throw TestError() }
      .map { _ in "foo" }
      .mapError { error in
        XCTAssert(error is TestError)
        return OtherTestError()
      }
    
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is OtherTestError)
    }
  }
  
  func testMapErrorOverMapThrowingErrorOverImmediateSuccess() {
    let possiblyDeferred = PossiblyDeferred.immediate(.success("foo"))
      .map { value -> String in
        throw TestError()
      }
      .mapError { error in
        XCTAssert(error is TestError)
        return OtherTestError()
      }
    
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is OtherTestError)
    }
  }
  
  func testMapErrorOverMapThrowingErrorOverDeferredSuccess() {
    let possiblyDeferred = PossiblyDeferred.deferred { "foo" }
      .map { value -> String in
        throw TestError()
      }
      .mapError { error in
        XCTAssert(error is TestError)
        return OtherTestError()
      }
    
    XCTAssertThrowsError(try possiblyDeferred.get()) { error in
      XCTAssert(error is OtherTestError)
    }
  }
  
  // MARK: - Lazily evaluate all
  
  func testLazilyEvaluateAllIsDeferred() throws {
    let possiblyDeferreds: [PossiblyDeferred<String>] = [.deferred { "foo" }, .deferred { "bar" }]

    var numberOfInvocations = 0

    let deferred = lazilyEvaluateAll(possiblyDeferreds).map { values -> String in
      numberOfInvocations += 1
      XCTAssertEqual(values, ["foo", "bar"])
      return values.joined()
    }

    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertEqual(try deferred.get(), "foobar")
    XCTAssertEqual(numberOfInvocations, 1)
  }

  func testLazilyEvaluateAllFailsWhenAnyOfTheElementsFails() throws {
    let possiblyDeferreds: [PossiblyDeferred<String>] = [.deferred { "foo" }, .deferred { throw TestError() }]

    var numberOfInvocations = 0

    let deferred = lazilyEvaluateAll(possiblyDeferreds).map { values -> String in
      numberOfInvocations += 1
      XCTAssertEqual(values, ["foo", "bar"])
      return values.joined()
    }

    XCTAssertEqual(numberOfInvocations, 0)
    XCTAssertThrowsError(try deferred.get()) { error in
      XCTAssert(error is TestError)
    }
    XCTAssertEqual(numberOfInvocations, 0)
  }
}

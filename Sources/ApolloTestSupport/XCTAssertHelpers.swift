import XCTest
@testable import Apollo

public func XCTAssertEqual<T, U>(_ expression1: @autoclosure () throws -> [T : U]?, _ expression2: @autoclosure () throws -> [T : U]?, file: StaticString = #filePath, line: UInt = #line) rethrows {
  let optionalValue1 = try expression1()
  let optionalValue2 = try expression2()
  
  let message = {
    "(\"\(String(describing: optionalValue1))\") is not equal to (\"\(String(describing: optionalValue2))\")"
  }
  
  switch (optionalValue1, optionalValue2) {
  case (.none, .none):
    break
  case let (value1 as NSDictionary, value2 as NSDictionary):
    XCTAssertEqual(value1, value2, message(), file: file, line: line)
  default:
    XCTFail(message(), file: file, line: line)
  }
}

public func XCTAssertEqualUnordered<Element, C1: Collection, C2: Collection>(_ expression1: @autoclosure () throws -> C1, _ expression2: @autoclosure () throws -> C2, file: StaticString = #filePath, line: UInt = #line) rethrows where Element: Hashable, C1.Element == Element, C2.Element == Element {
  let collection1 = try expression1()
  let collection2 = try expression2()
  
  // Convert to sets to ignore ordering and only check whether all elements are accounted for,
  // but also check count to detect duplicates.
  XCTAssertEqual(collection1.count, collection2.count, file: file, line: line)
  XCTAssertEqual(Set(collection1), Set(collection2), file: file, line: line)
}

public func XCTAssertMatch<Pattern: Matchable>(_ valueExpression: @autoclosure () throws -> Pattern.Base, _ patternExpression: @autoclosure () throws -> Pattern, file: StaticString = #filePath, line: UInt = #line) rethrows {
  let value = try valueExpression()
  let pattern = try patternExpression()
  
  let message = {
    "(\"\(value)\") does not match (\"\(pattern)\")"
  }
  
  if case pattern = value { return }
    
  XCTFail(message(), file: file, line: line)
}

// We need overloaded versions instead of relying on default arguments
// due to https://bugs.swift.org/browse/SR-1534

public func XCTAssertSuccessResult<Success>(_ expression: @autoclosure () throws -> Result<Success, Error>, file: StaticString = #file, line: UInt = #line) rethrows {
  try XCTAssertSuccessResult(expression(), file: file, line: line, {_ in })
}

public func XCTAssertSuccessResult<Success>(_ expression: @autoclosure () throws -> Result<Success, Error>, file: StaticString = #file, line: UInt = #line, _ successHandler: (_ value: Success) throws -> Void) rethrows {
  let result = try expression()
  
  switch result {
  case .success(let value):
    try successHandler(value)
  case .failure(let error):
    XCTFail("Expected success, but result was an error: \(String(describing: error))", file: file, line: line)
  }
}

public func XCTAssertFailureResult<Success>(_ expression: @autoclosure () throws -> Result<Success, Error>, file: StaticString = #file, line: UInt = #line) rethrows {
  try XCTAssertFailureResult(expression(), file: file, line: line, {_ in })
}

public func XCTAssertFailureResult<Success>(_ expression: @autoclosure () throws -> Result<Success, Error>, file: StaticString = #file, line: UInt = #line, _ errorHandler: (_ error: Error) throws -> Void) rethrows {
  let result = try expression()
  
  switch result {
  case .success(let success):
    XCTFail("Expected failure, but result was successful: \(String(describing: success))", file: file, line: line)
  case .failure(let error):
    try errorHandler(error)
  }
}

/// Downcast an expression to a specified type.
///
/// Generates a failure when the downcast doesn't succeed.
///
/// - Parameters:
///   - expression: An expression to downcast to `ExpectedType`.
///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
/// - Returns: A value of type `ExpectedType`, the result of evaluating and downcasting the given `expression`.
/// - Throws: An error when the downcast doesn't succeed. It will also rethrow any error thrown while evaluating the given expression.
public func XCTDowncast<ExpectedType: AnyObject>(_ expression: @autoclosure () throws -> AnyObject, to type: ExpectedType.Type, file: StaticString = #filePath, line: UInt = #line) throws -> ExpectedType {
  let object = try expression()
  
  guard let expected = object as? ExpectedType else {
    throw XCTFailure("Expected type to be \(ExpectedType.self), but found \(Swift.type(of: object))", file: file, line: line)
  }
  
  return expected
}

/// An error which causes the current test to cease executing and fail when it is thrown.
/// Similar to `XCTSkip`, but without marking the test as skipped.
public struct XCTFailure: Error, CustomNSError {
  
  public init(_ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTFail(message(), file: file, line: line)
  }
  
  /// The domain of the error.
  public static let errorDomain = XCTestErrorDomain
  
  /// The error code within the given domain.
  public let errorCode: Int = 0
  
  /// The user-info dictionary.
  public let errorUserInfo: [String : Any] = [
    // Make sure the thrown error doesn't show up as a test failure, because we already record
    // a more detailed failure (with the right source location) ourselves.
    "XCTestErrorUserInfoKeyShouldIgnore": true
  ]
}

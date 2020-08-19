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

public func XCTAssertMatch<Pattern: Matchable>(_ valueExpression: @autoclosure () throws -> Pattern.Base, _ patternExpression: @autoclosure () throws -> Pattern, file: StaticString = #filePath, line: UInt = #line) rethrows {
  let value = try valueExpression()
  let pattern = try patternExpression()
  
  let message = {
    "(\"\(value)\") does not match (\"\(pattern)\")"
  }
  
  if case pattern = value { return }
  
  XCTFail(message(), file: file, line: line)
}

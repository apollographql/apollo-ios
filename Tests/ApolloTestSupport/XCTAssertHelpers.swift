import XCTest
@testable import Apollo

public func XCTAssertEqual<T: Equatable>(_ expression1: @autoclosure () throws -> [T?]?, _ expression2: @autoclosure () throws -> [T?]?, file: StaticString = #file, line: UInt = #line) rethrows {
  let optionalValue1 = try expression1()
  let optionalValue2 = try expression2()
  
  let message = {
    "(\"\(String(describing: optionalValue1))\") is not equal to (\"\(String(describing: optionalValue2))\")"
  }
  
  switch (optionalValue1, optionalValue2) {
  case (.none, .none):
    break
  case let (value1?, value2?):
    // FIXME: This ignores nil values in both lists, which is probably not what you want for true equality checking
    XCTAssertEqual(value1.flatMap { $0 }, value2.flatMap { $0 }, message(), file: file, line: line)
  default:
    XCTFail(message(), file: file, line: line)
  }
}

public func XCTAssertEqual<T, U>(_ expression1: @autoclosure () throws -> [T : U]?, _ expression2: @autoclosure () throws -> [T : U]?, file: StaticString = #file, line: UInt = #line) rethrows {
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

public func XCTAssertMatch<Pattern: Matchable>(_ valueExpression: @autoclosure () throws -> Pattern.Base, _ patternExpression: @autoclosure () throws -> Pattern, file: StaticString = #file, line: UInt = #line) rethrows {
  let value = try valueExpression()
  let pattern = try patternExpression()
  
  let message = {
    "(\"\(value)\") does not match (\"\(pattern)\")"
  }
  
  if case pattern = value { return }
  
  XCTFail(message(), file: file, line: line)
}

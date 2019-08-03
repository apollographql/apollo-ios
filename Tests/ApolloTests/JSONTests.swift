import XCTest
@testable import Apollo

class JSONTests: XCTestCase {
  func testMissingValueMatchable() {
    let value = JSONDecodingError.missingValue

    XCTAssertTrue(value ~= JSONDecodingError.missingValue)
    XCTAssertFalse(value ~= JSONDecodingError.nullValue)
    XCTAssertFalse(value ~= JSONDecodingError.wrongType)
    XCTAssertFalse(value ~= JSONDecodingError.couldNotConvert(value: 123, to: Int.self))
  }

  func testNullValueMatchable() {
    let value = JSONDecodingError.nullValue

    XCTAssertTrue(value ~= JSONDecodingError.nullValue)
    XCTAssertFalse(value ~= JSONDecodingError.missingValue)
    XCTAssertFalse(value ~= JSONDecodingError.wrongType)
    XCTAssertFalse(value ~= JSONDecodingError.couldNotConvert(value: 123, to: Int.self))
  }

  func testWrongTypeMatchable() {
    let value = JSONDecodingError.wrongType

    XCTAssertTrue(value ~= JSONDecodingError.wrongType)
    XCTAssertFalse(value ~= JSONDecodingError.nullValue)
    XCTAssertFalse(value ~= JSONDecodingError.missingValue)
    XCTAssertFalse(value ~= JSONDecodingError.couldNotConvert(value: 123, to: Int.self))
  }

  func testCouldNotConvertMatchable() {
    let value = JSONDecodingError.couldNotConvert(value: 123, to: Int.self)

    XCTAssertTrue(value ~= JSONDecodingError.couldNotConvert(value: 123, to: Int.self))
    XCTAssertTrue(value ~= JSONDecodingError.couldNotConvert(value: "abc", to: String.self))
    XCTAssertFalse(value ~= JSONDecodingError.wrongType)
    XCTAssertFalse(value ~= JSONDecodingError.nullValue)
    XCTAssertFalse(value ~= JSONDecodingError.missingValue)
  }
}

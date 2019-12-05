import XCTest
@testable import Apollo

class VersionNumberTests: XCTestCase {
  func testVersionNumberExists() {
    // It would be the first 2 digits of version number like `0.19`.
    XCTAssertGreaterThanOrEqual(ApolloVersionNumber, 0)
  }
}

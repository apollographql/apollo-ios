import XCTest
@testable import PackageTwo

final class PackageTwoTests: XCTestCase {
    func testExample() throws {
      XCTAssertEqual(PackageTwo().text, "Hello, World!")
    }
}

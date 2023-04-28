import XCTest
@testable import CocoaPodsProject

final class CocoaPodsProjectTests: XCTestCase {
  
  func test_mockObject() throws {
    let mock = Mock<Dog>()

    XCTAssertEqual(mock.__typename, "Dog")
  }
  
}

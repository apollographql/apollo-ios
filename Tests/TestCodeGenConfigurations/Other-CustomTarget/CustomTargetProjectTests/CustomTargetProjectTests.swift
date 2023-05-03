import XCTest
@testable import CustomTargetProject
import ApolloTestSupport

final class CustomTargetProjectTests: XCTestCase {

  func test_mockObject() throws {
    let mock = Mock<Dog>()

    XCTAssertEqual(mock.__typename, "Dog")
  }

}

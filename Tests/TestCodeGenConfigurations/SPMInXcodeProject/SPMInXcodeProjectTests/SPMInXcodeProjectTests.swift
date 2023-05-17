import XCTest
@testable import SPMInXcodeProject
import ApolloTestSupport
import AnimalKingdomAPITestMocks

final class SPMInXcodeProjectTests: XCTestCase {

  func test_mockObject() throws {
    let mock = Mock<Dog>()

    XCTAssertEqual(mock.__typename, "Dog")
  }

}

import Foundation
import XCTest
import ApolloTestSupport
import AnimalKingdomAPI
import AnimalKingdomAPITestMocks

class TestMockUsageTests: XCTestCase {

  func test_mockObject() throws {
    let mock = Mock<Dog>()

    XCTAssertEqual(mock.__typename, "Dog")
  }

}

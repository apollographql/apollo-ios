import Foundation
import XCTest
import ApolloTestSupport
import GraphQLSchemaName
import GraphQLSchemaNameTestMocks

class TestMockUsageTests: XCTestCase {

  func test_mockObject() throws {
    let mock = Mock<Dog>()

    XCTAssertEqual(mock.__typename, "Dog")
  }

}

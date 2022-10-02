import XCTest
@testable import PackageTwo
import TestMocks
import ApolloTestSupport

final class PackageTwoTests: XCTestCase {
  func testExample() throws {
    XCTAssertEqual(PackageTwo().text, "Hello, World!")
  }

  func test_mockObject_initialization() throws {
    // given
    let mockHuman: Mock<Human> = Mock(species: "Homosapien")
    let mockDog: Mock<Dog> = Mock(id: "100", owner: mockHuman)

    // then
    XCTAssertEqual(mockDog.id, "100")
  }
}

import XCTest
@testable import PackageOne
import TestMocks
import ApolloTestSupport

final class PackageOneTests: XCTestCase {
  func testOperation() {
    let mockDog = Mock<Dog>(species: "Canis familiaris")
    let mockQuery = Mock<Query>(dog: mockDog)
    let dogQuery = DogQuery.Data.from(mockQuery)

    XCTAssertEqual(dogQuery.dog.species, "Canis familiaris")
  }
}

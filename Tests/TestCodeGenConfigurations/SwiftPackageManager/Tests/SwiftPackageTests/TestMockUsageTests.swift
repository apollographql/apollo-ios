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
    
  func test_generatedTestMocksSetters_applyValuesCorrectly() throws {
  
    // given
    let mockHeight = Mock<Height>(feet: 2, inches: 7)
    let mockHuman = Mock<Human>(firstName: "Human")
      
    let mockCrocodile = Mock<Crocodile>(id: "Crocodile", skinCovering: .case(.scales))
    let mockBird = Mock<Bird>(id: "Bird", skinCovering: .case(.feathers))
      
    // when
    let mockDog = Mock<Dog>(birthdate: "Jan 10",
                            bodyTemperature: 70,
                            favoriteToy: "Ball",
                            height: mockHeight,
                            humanName: "Lucky",
                            id: "Dog",
                            laysEggs: false,
                            owner: mockHuman,
                            predators: [mockCrocodile, mockBird],
                            skinCovering: .case(.fur),
                            species: "Lab")

    // then
    XCTAssertEqual(mockDog.birthdate, "Jan 10")
    XCTAssertEqual(mockDog.bodyTemperature, 70)
    XCTAssertEqual(mockDog.favoriteToy, "Ball")
    XCTAssertEqual(mockDog.height?.feet, 2)
    XCTAssertEqual(mockDog.height?.inches, 7)
    XCTAssertEqual(mockDog.humanName, "Lucky")
    XCTAssertEqual(mockDog.id, "Dog")
    XCTAssertEqual(mockDog.laysEggs, false)
    XCTAssertEqual(mockDog.owner?.firstName, "Human")
    XCTAssertEqual(mockDog.predators?.count, 2)
    XCTAssertEqual(mockDog.skinCovering, .case(.fur))
    XCTAssertEqual(mockDog.species, "Lab")
  
  }

}

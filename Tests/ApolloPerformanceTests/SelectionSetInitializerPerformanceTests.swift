import Foundation
import XCTest
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers
import AnimalKingdomAPI

class SelectionSetInitializerPerformanceTests: XCTestCase {

  func testPerformance_selectionSetInitialization_concreteObjectTypeCaseWithMultipleFulfilledFragments() {
    measure {
      for _ in 0..<1_000 {
        let animal = AllAnimalsQuery.Data.AllAnimal.AsDog(
          favoriteToy: "Milk Bone",
          height: .init(feet: 3, meters: 1, relativeSize: .case(.small), centimeters: 100),
          species: "Canine",
          predators: [],
          bodyTemperature: 98
        )
        XCTAssertNotNil(animal)
      }
    }
  }

}

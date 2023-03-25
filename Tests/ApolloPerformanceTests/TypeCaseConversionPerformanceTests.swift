import Foundation
import XCTest
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers
import AnimalKingdomAPI

class TypeCaseConversionPerformanceTests: XCTestCase {

  func testPerformance_typeConversion_checkTypeConformsToInterface() {
    let animal = AllAnimalsQuery.Data.AllAnimal.AsDog(
      favoriteToy: "Milk Bone",
      height: .init(feet: 3, meters: 1, relativeSize: .case(.small), centimeters: 100),
      species: "Canine",
      predators: [],
      bodyTemperature: 98
    ).asRootEntityType

    measure {
      for _ in 0..<1_000 {
        let asDog = animal.asDog
        XCTAssertNotNil(asDog)
      }
    }
  }

  func testPerformance_typeConversion_inclusionCondition() {
    let animal = AllAnimalsIncludeSkipQuery.Data.AllAnimal.IfNotSkipHeightInMeters(
      __typename: "Dog",
      height: .init(feet: 3,  inches: 36, meters: 1),
      species: "Canine",
      predators: []
    ).asRootEntityType

    measure {
      for _ in 0..<1_000 {
        let asConditional = animal.ifNotSkipHeightInMeters
        XCTAssertNotNil(asConditional)
      }
    }
  }

}

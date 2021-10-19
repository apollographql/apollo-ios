import Foundation
import XCTest
import Nimble
import OrderedCollections
import AnimalKingdomAPI
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

final class AnimalKingdomASTCreationTests: XCTestCase {

  static let frontend = try! ApolloCodegenFrontend()

  static let schema = try! frontend.loadSchema(from: AnimalKingdomAPI.Resources.Schema)

  static let operations = { try! frontend.mergeDocuments(
    AnimalKingdomAPI.Resources.GraphQLOperations.map {
      try! frontend.parseDocument(from: $0)
    }
  )}()

  static let compilationResult = try! frontend.compile(schema: schema, document: operations)

  override func setUp() {
    super.setUp()

//    compilationResult =
  }

  override func tearDown() {
    super.tearDown()

//    compilationResult = nil
  }

  func test__mergedSelections_AllAnimalsQuery_RootQuery__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let rootSelectionSet = SelectionSetScope(selectionSet: operation!.selectionSet, parent: nil)

    // when
    let actual = rootSelectionSet.mergedSelections

    // then
    expect(actual.fields.count).to(equal(1))
    expect(actual.typeCases.count).to(equal(0))
    expect(actual.fragments.count).to(equal(0))

    let allAnimals = actual.fields[0]
    expect(allAnimals.name).to(equal("allAnimals"))
    expect(allAnimals.type.typeReference).to(equal("[Animal!]!"))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let scope = SelectionSetScope(selectionSet: allAnimals.selectionSet!, parent: nil)

    // when
    let actual = scope.mergedSelections

    // then
    expect(actual.fields.count).to(equal(4))
    expect(actual.typeCases.count).to(equal(4))
    expect(actual.fragments.count).to(equal(1))

    let height = actual.fields[0]
    expect(height.name).to(equal("height"))
    expect(height.type.typeReference).to(equal("Height!"))

    let species = actual.fields[1]
    expect(species.name).to(equal("species"))
    expect(species.type.typeReference).to(equal("String!"))

    let skinCovering = actual.fields[2]
    expect(skinCovering.name).to(equal("skinCovering"))
    expect(skinCovering.type.typeReference).to(equal("SkinCovering"))

    let predators = actual.fields[3]
    expect(predators.name).to(equal("predators"))
    expect(predators.type.typeReference).to(equal("[Predators!]!"))

    let asWarmBlooded = actual.typeCases[0]
    expect(asWarmBlooded.parentType.name).to(equal("WarmBlooded"))

    let asPet = actual.typeCases[1]
    expect(asPet.parentType.name).to(equal("Pet"))

    let asCat = actual.typeCases[2]
    expect(asCat.parentType.name).to(equal("Cat"))

    let asClassroomPet = actual.typeCases[3]
    expect(asClassroomPet.parentType.name).to(equal("Cat"))

    let heightInMeters = actual.fragments[1]
    expect(heightInMeters.name).to(equal("HeightInMeters"))
    expect(heightInMeters.type.name).to(equal("Animal"))
  }

  func test__mergedSelections_AllAnimalsQuery_AsWarmBlooded__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = SelectionSetScope(selectionSet: allAnimals.selectionSet!,
                                            parent: nil)
    let scope = allAnimalsScope.children[1]

    // when
    let actual = scope.mergedSelections

    // then
    expect(actual.fields.count).to(equal(5))
    expect(actual.typeCases.count).to(equal(0))
    expect(actual.fragments.count).to(equal(2))

    let bodyTemperature = actual.fields[1]
    expect(bodyTemperature.name).to(equal("bodyTemperature"))
    expect(bodyTemperature.type.typeReference).to(equal("Int!"))

    let height = actual.fields[2]
    expect(height.name).to(equal("height"))
    expect(height.type.typeReference).to(equal("Height!"))

    let species = actual.fields[4]
    expect(species.name).to(equal("species"))
    expect(species.type.typeReference).to(equal("String!"))

    let skinCovering = actual.fields[5]
    expect(skinCovering.name).to(equal("skinCovering"))
    expect(skinCovering.type.typeReference).to(equal("SkinCovering"))

    let predators = actual.fields[6]
    expect(predators.name).to(equal("predators"))
    expect(predators.type.typeReference).to(equal("[Predators!]!"))

    let warmBloodedDetails = actual.fragments[0]
    expect(warmBloodedDetails.name).to(equal("WarmBloodedDetails"))
    expect(warmBloodedDetails.type.name).to(equal("WarmBlooded"))

    let heightInMeters = actual.fragments[3]
    expect(heightInMeters.name).to(equal("HeightInMeters"))
    expect(heightInMeters.type.name).to(equal("Animal"))
  }

}

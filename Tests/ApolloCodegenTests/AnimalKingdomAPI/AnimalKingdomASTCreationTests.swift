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
    let actual = rootSelectionSet.mergedSelections!

    // then
    expect(actual.count).to(equal(1))

    guard case let .field(allAnimals) = actual[0] else { fail(); return }
    expect(allAnimals.name).to(equal("allAnimals"))
    expect(allAnimals.type.typeReference).to(equal("[Animal!]!"))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let scope = SelectionSetScope(selectionSet: allAnimals.selectionSet!, parent: nil)

    // when
    let actual = scope.mergedSelections!

    // then
    expect(scope.fieldSelections.count).to(equal(4))
    expect(actual.count).to(equal(9))

    guard case let .field(height) = actual[0] else { fail(); return }
    expect(height.name).to(equal("height"))
    expect(height.type.typeReference).to(equal("Height!"))

    guard case let .fragmentSpread(heightInMeters) = actual[1] else { fail(); return }
    expect(heightInMeters.fragment.name).to(equal("HeightInMeters"))
    expect(heightInMeters.fragment.type.name).to(equal("Animal"))

    guard case let .inlineFragment(asWarmBlooded) = actual[2] else { fail(); return }
    expect(asWarmBlooded.parentType.name).to(equal("WarmBlooded"))

    guard case let .field(species) = actual[3] else { fail(); return }
    expect(species.name).to(equal("species"))
    expect(species.type.typeReference).to(equal("String!"))

    guard case let .field(skinCovering) = actual[4] else { fail(); return }
    expect(skinCovering.name).to(equal("skinCovering"))
    expect(skinCovering.type.typeReference).to(equal("SkinCovering"))

    guard case let .inlineFragment(asPet) = actual[5] else { fail(); return }
    expect(asPet.parentType.name).to(equal("Pet"))

    guard case let .inlineFragment(asCat) = actual[6] else { fail(); return }
    expect(asCat.parentType.name).to(equal("Cat"))

    guard case let .inlineFragment(asClassroomPet) = actual[7] else { fail(); return }
    expect(asClassroomPet.parentType.name).to(equal("Cat"))

    guard case let .field(predators) = actual[8] else { fail(); return }
    expect(predators.name).to(equal("predators"))
    expect(predators.type.typeReference).to(equal("[Predators!]!"))
  }

  func test__mergedSelections_AllAnimalsQuery_AsWarmBlooded__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = SelectionSetScope(selectionSet: allAnimals.selectionSet!,
                                            parent: nil)
    let scope = allAnimalsScope.children[1]

    // when
    let actual = scope.mergedSelections!

    // then
    expect(scope.fieldSelections.count).to(equal(0))
    expect(actual.count).to(equal(7))

    guard case let .fragmentSpread(warmBloodedDetails) = actual[0] else { fail(); return }
    expect(warmBloodedDetails.fragment.name).to(equal("WarmBloodedDetails"))
    expect(warmBloodedDetails.fragment.type.name).to(equal("WarmBlooded"))

    guard case let .field(bodyTemperature) = actual[1] else { fail(); return }
    expect(bodyTemperature.name).to(equal("bodyTemperature"))
    expect(bodyTemperature.type.typeReference).to(equal("Int!"))

    guard case let .field(height) = actual[2] else { fail(); return }
    expect(height.name).to(equal("height"))
    expect(height.type.typeReference).to(equal("Height!"))

    guard case let .fragmentSpread(heightInMeters) = actual[3] else { fail(); return }
    expect(heightInMeters.fragment.name).to(equal("HeightInMeters"))
    expect(heightInMeters.fragment.type.name).to(equal("Animal"))


    guard case let .field(species) = actual[4] else { fail(); return }
    expect(species.name).to(equal("species"))
    expect(species.type.typeReference).to(equal("String!"))

    guard case let .field(skinCovering) = actual[5] else { fail(); return }
    expect(skinCovering.name).to(equal("skinCovering"))
    expect(skinCovering.type.typeReference).to(equal("SkinCovering"))

    guard case let .field(predators) = actual[6] else { fail(); return }
    expect(predators.name).to(equal("predators"))
    expect(predators.type.typeReference).to(equal("[Predators!]!"))
  }

}

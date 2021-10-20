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
  }

  override func tearDown() {
    super.tearDown()
  }

  func test__mergedSelections_AllAnimalsQuery_RootQuery__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let rootSelectionSet = SelectionSetScope(selectionSet: operation!.selectionSet, parent: nil)

    let expected = MergedSelections(
      fields: [
        .mock("allAnimals",
              type: .nonNull(.list(.nonNull(.named(GraphQLInterfaceType.mock("Animal"))))))
      ]
    )

    // when
    let actual = rootSelectionSet.mergedSelections

    // then
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let scope = SelectionSetScope(selectionSet: allAnimals.selectionSet!, parent: nil)

    let expected = MergedSelections(
      fields: [
        .mock("height",
              type: .nonNull(.named(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .named(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.named(GraphQLInterfaceType.mock("Animal")))))),
      ],
      typeCases: [
        .mock(parentType: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock(parentType: GraphQLObjectType.mock("Pet")),
        .mock(parentType: GraphQLObjectType.mock("Cat")),
        .mock(parentType: GraphQLUnionType.mock("ClassroomPet")),
      ],
      fragments: [
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal"))
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLObjectType.mock("Animal")))
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Height__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0],
          case let .field(height) = allAnimals.selectionSet?.selections[0] else { fail(); return }
    let scope = SelectionSetScope(selectionSet: height.selectionSet!, parent: nil)

    let expected = MergedSelections(
      fields: [
        .mock("feet",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("meters",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Predator__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0],
          case let .field(predator) = allAnimals.selectionSet?.selections[8] else { fail(); return }
    let scope = SelectionSetScope(selectionSet: predator.selectionSet!, parent: nil)

    let expected = MergedSelections(
      fields: [
        .mock("species",
              type: .nonNull(.named(GraphQLScalarType.string()))),
      ],
      typeCases: [
        .mock(parentType: GraphQLInterfaceType.mock("WarmBlooded"))
      ],
      fragments: []
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLInterfaceType.mock("Animal")))
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Predator_AsWarmBlooded__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0],
          case let .field(predator) = allAnimals.selectionSet?.selections[8] else { fail(); return }
    let scope = SelectionSetScope(selectionSet: predator.selectionSet!, parent: nil)
      .children[0]

    let expected = MergedSelections(
      fields: [
        .mock("laysEggs",
              type: .nonNull(.named(GraphQLScalarType.boolean()))),
        .mock("species",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("bodyTemperature",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("height",
              type: .nonNull(.named(GraphQLObjectType.mock("Height")))),
      ],
      typeCases: [],
      fragments: [
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsWarmBlooded__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = SelectionSetScope(selectionSet: allAnimals.selectionSet!,
                                            parent: nil)
    let scope = allAnimalsScope.children[0]

    let expected = MergedSelections(
      fields: [
        .mock("bodyTemperature",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("height",
              type: .nonNull(.named(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .named(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.named(GraphQLInterfaceType.mock("Animal")))))),
      ],
      typeCases: [],
      fragments: [
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsWarmBlooded_Height__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let height = SelectionSetScope(selectionSet: allAnimals.selectionSet!, parent: nil)
      .children[0]
      .mergedSelections
      .fields[1]

    let scope = SelectionSetScope(selectionSet: height.selectionSet!, parent: nil)

    let expected = MergedSelections(
      fields: [
        .mock("feet",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("meters",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("yards",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsPet__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = SelectionSetScope(selectionSet: allAnimals.selectionSet!,
                                            parent: nil)
    let scope = allAnimalsScope.children[1]

    let expected = MergedSelections(
      fields: [
        .mock("height",
              type: .nonNull(.named(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .named(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.named(GraphQLInterfaceType.mock("Animal")))))),
        .mock("humanName",
              type: .named(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("owner",
              type: .nonNull(.named(GraphQLObjectType.mock("Human")))),
      ],
      typeCases: [
        .mock(parentType: GraphQLInterfaceType.mock("WarmBlooded")),
      ],
      fragments: [
        .mock("HeightInMeters", type: GraphQLObjectType.mock("Animal")),
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLInterfaceType.mock("Pet")))
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsPet_Height__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let height = SelectionSetScope(selectionSet: allAnimals.selectionSet!, parent: nil)
      .children[1]
      .mergedSelections
      .fields[0]

    let scope = SelectionSetScope(selectionSet: height.selectionSet!, parent: nil)

    let expected = MergedSelections(
      fields: [
        .mock("relativeSize",
              type: .nonNull(.named(GraphQLEnumType.relativeSize()))),
        .mock("centimeters",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("feet",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("meters",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("yards",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsPet_AsWarmBlooded__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = SelectionSetScope(selectionSet: allAnimals.selectionSet!,
                                            parent: nil)
    let scope = allAnimalsScope.children[1].children[0]

    let expected = MergedSelections(
      fields: [
        .mock("height",
              type: .nonNull(.named(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .named(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.named(GraphQLInterfaceType.mock("Animal")))))),
        .mock("humanName",
              type: .named(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("owner",
              type: .nonNull(.named(GraphQLObjectType.mock("Human")))),
        .mock("bodyTemperature",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: [
        .mock("HeightInMeters", type: GraphQLObjectType.mock("Animal")),
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsCat__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = SelectionSetScope(selectionSet: allAnimals.selectionSet!,
                                            parent: nil)
    let scope = allAnimalsScope.children[2]

    let expected = MergedSelections(
      fields: [
        .mock("isJellicle",
              type: .nonNull(.named(GraphQLScalarType.boolean()))),
        .mock("height",
              type: .nonNull(.named(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .named(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.named(GraphQLInterfaceType.mock("Animal")))))),
        .mock("humanName",
              type: .named(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("owner",
              type: .nonNull(.named(GraphQLObjectType.mock("Human")))),
        .mock("bodyTemperature",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: [
        .mock("HeightInMeters", type: GraphQLObjectType.mock("Animal")),
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLObjectType.mock("Cat")))
    expect(actual).to(matchAST(expected))
  }

#warning("TODO: This is the same as AllAnimal.AsPet.Height. Should we inherit that object instead?")
  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsCat_Height__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let height = SelectionSetScope(selectionSet: allAnimals.selectionSet!, parent: nil)
      .children[2]
      .mergedSelections
      .fields[0]

    let scope = SelectionSetScope(selectionSet: height.selectionSet!, parent: nil)

    let expected = MergedSelections(
      fields: [
        .mock("feet",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("meters",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("yards",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("relativeSize",
              type: .nonNull(.named(GraphQLEnumType.relativeSize()))),
        .mock("centimeters",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsClassroomPet__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = SelectionSetScope(selectionSet: allAnimals.selectionSet!,
                                            parent: nil)
    let scope = allAnimalsScope.children[3]

    let expected = MergedSelections(
      fields: [
        .mock("height",
              type: .nonNull(.named(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .named(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.named(GraphQLInterfaceType.mock("Animal")))))),
      ],
      typeCases: [
        .mock(parentType: GraphQLObjectType.mock("Bird")),
      ],
      fragments: [
        .mock("HeightInMeters", type: GraphQLObjectType.mock("Animal")),
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLUnionType.mock("ClassroomPet")))
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsClassroomPet_AsBird__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = SelectionSetScope(selectionSet: allAnimals.selectionSet!,
                                            parent: nil)
    let scope = allAnimalsScope.children[3].children[0]

    let expected = MergedSelections(
      fields: [
        .mock("height",
              type: .nonNull(.named(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .named(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.named(GraphQLInterfaceType.mock("Animal")))))),
        .mock("humanName",
              type: .named(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("owner",
              type: .nonNull(.named(GraphQLObjectType.mock("Human")))),
        .mock("bodyTemperature",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("wingspan",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: [
        .mock("HeightInMeters", type: GraphQLObjectType.mock("Animal")),
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLObjectType.mock("Bird")))
    expect(actual).to(matchAST(expected))
  }

#warning("TODO: This is the same as AllAnimal.AsPet.Height. Should we inherit that object instead?")
  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsClassroomPet_AsBird_Height__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let height = SelectionSetScope(selectionSet: allAnimals.selectionSet!, parent: nil)
      .children[3]
      .children[0]
      .mergedSelections
      .fields[0]

    let scope = SelectionSetScope(selectionSet: height.selectionSet!, parent: nil)

    let expected = MergedSelections(
      fields: [
        .mock("feet",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("meters",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("yards",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("relativeSize",
              type: .nonNull(.named(GraphQLEnumType.relativeSize()))),
        .mock("centimeters",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(matchAST(expected))
  }

}

// MARK - Custom Matchers

fileprivate func matchAST(_ expectedValue: MergedSelections) -> Predicate<MergedSelections> {
  return Predicate { actual in
    if let actualValue = try actual.evaluate() {
      if expectedValue.fields.count != actualValue.fields.count {
        return PredicateResult(
          status: .fail,
          message: .expectedCustomValueTo("have fields equal to" + expectedValue.fields.debugDescription,
                                          actual: actualValue.fields.debugDescription)
        )
      }

      if expectedValue.typeCases.count != actualValue.typeCases.count {
        return PredicateResult(
          status: .fail,
          message: .expectedCustomValueTo("have typeCases equal to" + expectedValue.typeCases.debugDescription,
                                          actual: actualValue.typeCases.debugDescription)
        )
      }

      if expectedValue.fragments.count != actualValue.fragments.count {
        return PredicateResult(
          status: .fail,
          message: .expectedCustomValueTo("have fragments equal to" + expectedValue.fragments.debugDescription,
                                          actual: actualValue.fragments.debugDescription)
        )
      }

      for (index, field) in zip(expectedValue.fields, actualValue.fields).enumerated() {
        guard matchAST(expected: field.0, actual: field.1) else {
          return PredicateResult(
            status: .fail,
            message: .fail("Expected field[\(index)] to equal \(field.0), got \(field.1).")
          )
        }
      }

      for (index, typeCase) in zip(expectedValue.typeCases, actualValue.typeCases).enumerated() {
        guard matchAST(expected: typeCase.0, actual: typeCase.1) else {
          return PredicateResult(
            status: .fail,
            message: .fail("Expected typeCase[\(index)] to equal \(typeCase.0), got \(typeCase.1).")
          )
        }
      }

      for (index, fragment) in zip(expectedValue.fragments, actualValue.fragments).enumerated() {
        guard matchAST(expected: fragment.0, actual: fragment.1) else {
          return PredicateResult(
            status: .fail,
            message: .fail("Expected fragment[\(index)] to equal \(fragment.0), got \(fragment.1).")
          )
        }
      }

      return PredicateResult(
        status: .matches,
        message: .expectedActualValueTo("equal <\(expectedValue)>")
      )

    } else {
      return PredicateResult(
        status: .fail,
        message: .expectedActualValueTo("equal <\(expectedValue)>").appendedBeNilHint()
      )
    }
  }
}

fileprivate func matchAST(expected: CompilationResult.Field, actual: CompilationResult.Field) -> Bool {
  return expected.name == actual.name &&
  expected.alias == actual.alias &&
  expected.arguments == actual.arguments &&
  expected.type == actual.type
}

fileprivate func matchAST(expected: CompilationResult.InlineFragment, actual: CompilationResult.InlineFragment) -> Bool {
  return expected.parentType == actual.parentType
}

fileprivate func matchAST(expected: CompilationResult.FragmentDefinition, actual: CompilationResult.FragmentDefinition) -> Bool {
  return expected.name == actual.name &&
  expected.type == actual.type
}

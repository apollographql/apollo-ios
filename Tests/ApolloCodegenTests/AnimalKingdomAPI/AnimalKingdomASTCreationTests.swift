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
              type: .nonNull(.list(.nonNull(.named(GraphQLObjectType.mock("Animal"))))))
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
              type: .nonNull(.list(.nonNull(.named(GraphQLObjectType.mock("Animal")))))),
      ],
      typeCases: [
        .mock(parentType: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock(parentType: GraphQLObjectType.mock("Pet")),
        .mock(parentType: GraphQLObjectType.mock("Cat")),
        .mock(parentType: GraphQLUnionType.mock("ClassroomPet")),
      ],
      fragments: [
        .mock("HeightInMeters", type: GraphQLObjectType.mock("Animal"))
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(actual).to(matchAST(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsWarmBlooded__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = SelectionSetScope(selectionSet: allAnimals.selectionSet!,
                                            parent: nil)
    let scope = allAnimalsScope.children[1]

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
              type: .nonNull(.list(.nonNull(.named(GraphQLObjectType.mock("Animal")))))),
      ],
      typeCases: [],
      fragments: [
        .mock("WarmBloodedDetails", type: GraphQLObjectType.mock("WarmBlooded")), // TODO: This should be interface type. Want to test that wrong composite type causes failure."
        .mock("HeightInMeters", type: GraphQLObjectType.mock("Animal")),
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
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

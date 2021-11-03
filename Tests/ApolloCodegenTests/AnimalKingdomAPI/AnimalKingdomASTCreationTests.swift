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
    let rootSelectionSet = ASTSelectionSet(selectionSet: operation!.selectionSet,
                                           compilationResult: Self.compilationResult)

    let expected = SortedSelections(
      fields: [
        .mock("allAnimals",
              type: .nonNull(.list(.nonNull(.named(GraphQLInterfaceType.mock("Animal"))))))
      ]
    )

    // when
    let actual = rootSelectionSet.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal__isCorrect() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")

    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let scope = ASTSelectionSet(selectionSet: allAnimals.selectionSet!,
                                compilationResult: Self.compilationResult)

    let expected = SortedSelections(
      fields: [
        .mock("height",
              type: .nonNull(.named(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.named(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .named(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.named(Interface_Animal))))),
      ],
      typeCases: [
        .mock(parentType: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock(parentType: GraphQLInterfaceType.mock("Pet")),
        .mock(parentType: GraphQLObjectType.mock("Cat")),
        .mock(parentType: GraphQLUnionType.mock("ClassroomPet")),
      ],
      fragments: [
        .mock("HeightInMeters", type: Interface_Animal)
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(Interface_Animal))
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Height__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0],
          case let .field(height) = allAnimals.selectionSet?.selections[0] else { fail(); return }
    let scope = ASTSelectionSet(selectionSet: height.selectionSet!,
                                compilationResult: Self.compilationResult)

    let expected = SortedSelections(
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
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Predator__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0],
          case let .field(predator) = allAnimals.selectionSet?.selections[8] else { fail(); return }
    let scope = ASTSelectionSet(selectionSet: predator.selectionSet!,
                                compilationResult: Self.compilationResult)

    let expected = SortedSelections(
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
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Predator_AsWarmBlooded__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0],
          case let .field(predator) = allAnimals.selectionSet?.selections[8] else { fail(); return }
    let scope = ASTSelectionSet(selectionSet: predator.selectionSet!,
                                compilationResult: Self.compilationResult)
      .children.values[0]

    let expected = SortedSelections(
      fields: [
        .mock("bodyTemperature",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("height",
              type: .nonNull(.named(GraphQLObjectType.mock("Height")))),
        .mock("laysEggs",
              type: .nonNull(.named(GraphQLScalarType.boolean()))),
        .mock("species",
              type: .nonNull(.named(GraphQLScalarType.string()))),
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
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsWarmBlooded__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = ASTSelectionSet(selectionSet: allAnimals.selectionSet!,
                                          compilationResult: Self.compilationResult)
    let scope = allAnimalsScope.children.values[0]

    let expected = SortedSelections(
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
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsWarmBlooded_Height__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = ASTSelectionSet(selectionSet: allAnimals.selectionSet!,
                                          compilationResult: Self.compilationResult)
    let height = allAnimalsScope
      .children.values[0]
      .mergedSelections
      .fields.values[1]

    let scope = ASTSelectionSet(selectionSet: try XCTUnwrap(height.selectionSet),
                                compilationResult: Self.compilationResult)

    let expected = SortedSelections(
      fields: [
        .mock("meters",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("yards",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("feet",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.named(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsPet__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = ASTSelectionSet(selectionSet: allAnimals.selectionSet!,
                                          compilationResult: Self.compilationResult)
    let scope = allAnimalsScope.children.values[1]

    let expected = SortedSelections(
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
              type: .named(GraphQLObjectType.mock("Human"))),
      ],
      typeCases: [
        .mock(parentType: GraphQLInterfaceType.mock("WarmBlooded")),
      ],
      fragments: [
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
      ]
    )

    // when
    let actual = scope.mergedSelections

    // then
    expect(scope.type).to(equal(GraphQLInterfaceType.mock("Pet")))
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsPet_Height__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = ASTSelectionSet(selectionSet: allAnimals.selectionSet!,
                                          compilationResult: Self.compilationResult)
    let height = allAnimalsScope
      .children.values[1]
      .mergedSelections
      .fields.values[3]

    let scope = ASTSelectionSet(selectionSet: height.selectionSet!,
                                compilationResult: Self.compilationResult)

    let expected = SortedSelections(
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
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsPet_AsWarmBlooded__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = ASTSelectionSet(selectionSet: allAnimals.selectionSet!,
                                          compilationResult: Self.compilationResult)
    let scope = allAnimalsScope.children.values[1].children.values[0]

    let expected = SortedSelections(
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
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsCat__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = ASTSelectionSet(selectionSet: allAnimals.selectionSet!,
                                          compilationResult: Self.compilationResult)
    let scope = allAnimalsScope.children.values[2]

    let expected = SortedSelections(
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
    expect(actual).to(shallowlyMatch(expected))
  }

#warning("TODO: This is the same as AllAnimal.AsPet.Height. Should we inherit that object instead?")
  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsCat_Height__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = ASTSelectionSet(selectionSet: allAnimals.selectionSet!,
                                          compilationResult: Self.compilationResult)
    let height = allAnimalsScope
      .children.values[2]
      .mergedSelections
      .fields.values[1]

    let scope = ASTSelectionSet(selectionSet: height.selectionSet!,
                                compilationResult: Self.compilationResult)

    let expected = SortedSelections(
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
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsClassroomPet__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = ASTSelectionSet(selectionSet: allAnimals.selectionSet!,
                                          compilationResult: Self.compilationResult)
    let scope = allAnimalsScope.children.values[3]

    let expected = SortedSelections(
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
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsClassroomPet_AsBird__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = ASTSelectionSet(selectionSet: allAnimals.selectionSet!,
                                          compilationResult: Self.compilationResult)
    let scope = allAnimalsScope.children.values[3].children.values[0]

    let expected = SortedSelections(
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
    expect(actual).to(shallowlyMatch(expected))
  }

#warning("TODO: This is the same as AllAnimal.AsPet.Height. Should we inherit that object instead?")
  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsClassroomPet_AsBird_Height__isCorrect() {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    guard case let .field(allAnimals) = operation!.selectionSet.selections[0] else { fail(); return }
    let allAnimalsScope = ASTSelectionSet(selectionSet: allAnimals.selectionSet!,
                                          compilationResult: Self.compilationResult)
    let height = allAnimalsScope
      .children.values[3]
      .children.values[0]
      .mergedSelections
      .fields.values[1]

    let scope = ASTSelectionSet(selectionSet: height.selectionSet!,
                                compilationResult: Self.compilationResult)

    let expected = SortedSelections(
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
    expect(actual).to(shallowlyMatch(expected))
  }

}

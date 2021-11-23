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

  var expected: (fields: [CompilationResult.Field],
                 typeCases: [CompilationResult.SelectionSet],
                 fragments: [CompilationResult.FragmentDefinition])!

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
    expected = nil
  }

  func test__mergedSelections_AllAnimalsQuery_RootQuery__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    expected = (
      fields: [
        .mock("allAnimals",
              type: .nonNull(.list(.nonNull(.entity(GraphQLInterfaceType.mock("Animal"))))))
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = rootSelectionSet.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal__isCorrect() throws {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")

    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(rootSelectionSet[field: "allAnimals"]?.selectionSet)

    expected = (
      fields: [
        .mock("height",
              type: .nonNull(.entity(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .enum(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.entity(Interface_Animal))))),
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
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(Interface_Animal))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Height__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("meters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Predator__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[field: "predators"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("species",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
      ],
      typeCases: [
        .mock(parentType: GraphQLInterfaceType.mock("WarmBlooded"))
      ],
      fragments: []
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("Animal")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Predator_AsWarmBlooded__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[field: "height"]?[as: "WarmBlooded"]
    )

    expected = (
      fields: [
        .mock("laysEggs",
              type: .nonNull(.scalar(GraphQLScalarType.boolean()))),
        .mock("bodyTemperature",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("height",
              type: .nonNull(.entity(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
      ],
      typeCases: [],
      fragments: [
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
      ]
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsWarmBlooded__isCorrect() throws  {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "WarmBlooded"]
    )

    expected = (
      fields: [
        .mock("bodyTemperature",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("height",
              type: .nonNull(.entity(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .enum(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.entity(GraphQLInterfaceType.mock("Animal")))))),
      ],
      typeCases: [],
      fragments: [
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
      ]
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsWarmBlooded_Height__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "WarmBlooded"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("meters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("yards",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsPet__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Pet"]
    )

    expected = (
      fields: [
        .mock("height",
              type: .nonNull(.entity(GraphQLObjectType.mock("Height")))),
        .mock("humanName",
              type: .scalar(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("owner",
              type: .entity(GraphQLObjectType.mock("Human"))),
        .mock("species",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .enum(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.entity(GraphQLInterfaceType.mock("Animal")))))),
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
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("Pet")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsPet_Height__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Pet"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("relativeSize",
              type: .nonNull(.enum(GraphQLEnumType.relativeSize()))),
        .mock("centimeters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("meters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsPet_AsWarmBlooded__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Pet"]?[as: "WarmBlooded"]
    )

    expected = (
      fields: [
        .mock("bodyTemperature",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("height",
              type: .nonNull(.entity(GraphQLObjectType.mock("Height")))),
        .mock("humanName",
              type: .scalar(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("owner",
              type: .entity(GraphQLObjectType.mock("Human"))),
        .mock("species",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .enum(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.entity(GraphQLInterfaceType.mock("Animal")))))),
      ],
      typeCases: [],
      fragments: [
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
      ]
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(shallowlyMatch(self.expected))
  }


  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsPet_AsWarmBlooded_Height__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Pet"]?[as: "WarmBlooded"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("relativeSize",
              type: .nonNull(.enum(GraphQLEnumType.relativeSize()))),
        .mock("centimeters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("meters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("yards",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsCat__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Cat"]
    )

    expected = (
      fields: [
        .mock("isJellicle",
              type: .nonNull(.scalar(GraphQLScalarType.boolean()))),
        .mock("bodyTemperature",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("height",
              type: .nonNull(.entity(GraphQLObjectType.mock("Height")))),
        .mock("humanName",
              type: .scalar(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("owner",
              type: .entity(GraphQLObjectType.mock("Human"))),
        .mock("species",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .enum(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.entity(GraphQLInterfaceType.mock("Animal")))))),
      ],
      typeCases: [],
      fragments: [
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
      ]
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Cat")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

#warning("TODO: This is the same as AllAnimal.AsPet.AsWarmBlooded.Height. Should we inherit that object instead?")
  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsCat_Height__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Cat"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("meters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("yards",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("relativeSize",
              type: .nonNull(.enum(GraphQLEnumType.relativeSize()))),
        .mock("centimeters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsClassroomPet__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "ClassroomPet"]
    )

    expected = (
      fields: [
        .mock("height",
              type: .nonNull(.entity(GraphQLObjectType.mock("Height")))),
        .mock("species",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .enum(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.entity(GraphQLInterfaceType.mock("Animal")))))),
      ],
      typeCases: [
        .mock(parentType: GraphQLObjectType.mock("Bird")),
      ],
      fragments: [
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
      ]
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLUnionType.mock("ClassroomPet")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsClassroomPet_AsBird__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "ClassroomPet"]?[as: "Bird"]
    )

    expected = (
      fields: [
        .mock("wingspan",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("bodyTemperature",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("height",
              type: .nonNull(.entity(GraphQLObjectType.mock("Height")))),
        .mock("humanName",
              type: .scalar(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("owner",
              type: .entity(GraphQLObjectType.mock("Human"))),
        .mock("species",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .enum(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.entity(GraphQLInterfaceType.mock("Animal")))))),
      ],
      typeCases: [],
      fragments: [
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
      ]
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Bird")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

#warning("TODO: This is the same as AllAnimal.AsPet.Height. Should we inherit that object instead?")
  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsClassroomPet_AsBird_Height__isCorrect() throws {
    // given
    let operation = Self.compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR(compilationResult: Self.compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "ClassroomPet"]?[as: "Bird"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("meters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("yards",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("relativeSize",
              type: .nonNull(.enum(GraphQLEnumType.relativeSize()))),
        .mock("centimeters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.mergedSelections

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

}

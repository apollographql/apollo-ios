import Foundation
import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

final class AnimalKingdomIRCreationTests: XCTestCase {

  static let frontend = try! GraphQLJSFrontend()

  static let schema = try! frontend.loadSchema(from: ApolloCodegenInternalTestHelpers.Resources.AnimalKingdomSchema)

  static func operationDocuments(experimentalClientControlledNullability: Bool = false) -> GraphQLDocument {
    try! frontend.mergeDocuments(
      ApolloCodegenInternalTestHelpers.Resources.GraphQLOperations.map {
        try! frontend.parseDocument(
          from: $0,
          experimentalClientControlledNullability: experimentalClientControlledNullability
        )
      }
    )
  }

  static func operationCCNDocuments(experimentalClientControlledNullability: Bool = false) -> GraphQLDocument {
    try! frontend.mergeDocuments(
      ApolloCodegenInternalTestHelpers.Resources.CCNGraphQLOperations.map {
        try! frontend.parseDocument(
          from: $0,
          experimentalClientControlledNullability: experimentalClientControlledNullability
        )
      }
    )
  }

  var compilationResult: CompilationResult!

  var expected: (fields: [ShallowFieldMatcher],
                 typeCases: [ShallowInlineFragmentMatcher],
                 fragments: [ShallowFragmentSpreadMatcher])!

  override func setUp() {
    super.setUp()
    compilationResult = try! Self.frontend.compile(schema: Self.schema, document: Self.operationDocuments())
  }

  override func tearDown() {
    super.tearDown()
    compilationResult = nil
    expected = nil
  }

  func test__directSelections_AllAnimalsQuery_RootQuery__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
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
    let actual = rootSelectionSet.selections.direct

    // then
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_RootQuery__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    // when
    let actual = rootSelectionSet.selections.merged

    // then
    expect(actual).to(beEmpty())
  }

  func test__directSelections_AllAnimalsQuery_AllAnimal__isCorrect() throws {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")

    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
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
        .mock(parentType: GraphQLObjectType.mock("Dog")),
      ],
      fragments: [
        .mock("HeightInMeters", type: Interface_Animal)
      ]
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(Interface_Animal))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal__isCorrect() throws {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")

    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(rootSelectionSet[field: "allAnimals"]?.selectionSet)

    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(Interface_Animal))
    expect(actual).to(beEmpty())
  }

  func test__directSelections_AllAnimalsQuery_AllAnimal_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .scalar(GraphQLScalarType.integer())),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("meters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )
    
    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AllAnimal_Predator__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
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
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("Animal")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Predator__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[field: "predators"]?.selectionSet
    )

    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("Animal")))
    expect(actual).to(beEmpty())
  }

  func test__directSelections_AllAnimalsQuery_AllAnimal_Predator_AsWarmBlooded__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[field: "predators"]?[as: "WarmBlooded"]
    )

    expected = (
      fields: [
        .mock("laysEggs",
              type: .nonNull(.scalar(GraphQLScalarType.boolean()))),
      ],
      typeCases: [],
      fragments: [
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
      ]
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_Predator_AsWarmBlooded__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[field: "predators"]?[as: "WarmBlooded"]
    )

    expected = (
      fields: [
        .mock("species",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("bodyTemperature",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("height",
              type: .nonNull(.entity(GraphQLObjectType.mock("Height")))),
      ],
      typeCases: [],
      fragments: [
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
      ]
    )

    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AllAnimal_AsWarmBlooded__isCorrect() throws  {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "WarmBlooded"]
    )

    expected = (
      fields: [],
      typeCases: [],
      fragments: [
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
      ]
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsWarmBlooded__isCorrect() throws  {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "WarmBlooded"]
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
        .mock("bodyTemperature",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: [
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
      ]
    )

    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AllAnimal_AsWarmBlooded_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "WarmBlooded"]?[field: "height"]?.selectionSet
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(beNil())
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsWarmBlooded_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "WarmBlooded"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .scalar(GraphQLScalarType.integer())),
        .mock("meters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AllAnimal_AsPet__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Pet"]
    )

    expected = (
      fields: [
        .mock("height",
              type: .nonNull(.entity(GraphQLObjectType.mock("Height"))))
      ],
      typeCases: [
        .mock(parentType: GraphQLInterfaceType.mock("WarmBlooded")),
      ],
      fragments: [
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
      ]
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("Pet")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsPet__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Pet"]
    )

    expected = (
      fields: [
        .mock("species",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("skinCovering",
              type: .enum(GraphQLEnumType.skinCovering())),
        .mock("predators",
              type: .nonNull(.list(.nonNull(.entity(GraphQLInterfaceType.mock("Animal")))))),
        .mock("humanName",
              type: .scalar(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("owner",
              type: .entity(GraphQLObjectType.mock("Human"))),
      ],
      typeCases: [
      ],
      fragments: [
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
      ]
    )

    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("Pet")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AllAnimal_AsPet_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
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
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsPet_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Pet"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .scalar(GraphQLScalarType.integer())),
        .mock("meters",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AsPet_AsWarmBlooded__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Pet"]?[as: "WarmBlooded"]
    )

    expected = (
      fields: [],
      typeCases: [],
      fragments: [
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
      ]
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsPet_AsWarmBlooded__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Pet"]?[as: "WarmBlooded"]
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
        .mock("bodyTemperature",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("humanName",
              type: .scalar(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("owner",
              type: .entity(GraphQLObjectType.mock("Human"))),
      ],
      typeCases: [],
      fragments: [
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
      ]
    )

    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLInterfaceType.mock("WarmBlooded")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AllAnimal_AsPet_AsWarmBlooded_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Pet"]?[as: "WarmBlooded"]?[field: "height"]?.selectionSet
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(beNil())
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsPet_AsWarmBlooded_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Pet"]?[as: "WarmBlooded"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .scalar(GraphQLScalarType.integer())),
        .mock("meters",
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
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AsCat__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Cat"]
    )

    expected = (
      fields: [
        .mock("isJellicle",
              type: .nonNull(.scalar(GraphQLScalarType.boolean()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Cat")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsCat__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Cat"]
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
        .mock("bodyTemperature",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("humanName",
              type: .scalar(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("owner",
              type: .entity(GraphQLObjectType.mock("Human"))),
      ],
      typeCases: [],
      fragments: [
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
      ]
    )

    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Cat")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AllAnimal_AsCat_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Cat"]?[field: "height"]?.selectionSet
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(beNil())
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsCat_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "Cat"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .scalar(GraphQLScalarType.integer())),
        .mock("meters",
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
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AsClassroomPet__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "ClassroomPet"]
    )

    expected = (
      fields: [],
      typeCases: [
        .mock(parentType: GraphQLObjectType.mock("Bird")),
      ],
      fragments: []
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLUnionType.mock("ClassroomPet")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsClassroomPet__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
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
      ],
      fragments: [
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
      ]
    )

    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLUnionType.mock("ClassroomPet")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AsClassroomPet_AsBird__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "ClassroomPet"]?[as: "Bird"]
    )

    expected = (
      fields: [
        .mock("wingspan",
              type: .nonNull(.scalar(GraphQLScalarType.float())))
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Bird")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AsClassroomPet_AsBird__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "ClassroomPet"]?[as: "Bird"]
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
        .mock("bodyTemperature",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("humanName",
              type: .scalar(GraphQLScalarType.string())),
        .mock("favoriteToy",
              type: .nonNull(.scalar(GraphQLScalarType.string()))),
        .mock("owner",
              type: .entity(GraphQLObjectType.mock("Human"))),
      ],
      typeCases: [],
      fragments: [
        .mock("HeightInMeters", type: GraphQLInterfaceType.mock("Animal")),
        .mock("WarmBloodedDetails", type: GraphQLInterfaceType.mock("WarmBlooded")),
        .mock("PetDetails", type: GraphQLInterfaceType.mock("Pet")),
      ]
    )

    // when
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Bird")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__directSelections_AllAnimalsQuery_AllAnimal_AsClassroomPet_AsBird_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "ClassroomPet"]?[as: "Bird"]?[field: "height"]?.selectionSet
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(beNil())
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsClassroomPet_AsBird_Height__isCorrect() throws {
    // given
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsQuery" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[as: "ClassroomPet"]?[as: "Bird"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("feet",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
        .mock("inches",
              type: .scalar(GraphQLScalarType.integer())),
        .mock("meters",
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
    let actual = selectionSet.selections.merged

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }

  func test__mergedSelections_AllAnimalsQuery_AllAnimal_AsClassroomPet_AsBird_Height__isCorrect_CCN() throws {
    // given
    compilationResult = try! Self.frontend.compile(
      schema: Self.schema,
      document: Self.operationCCNDocuments(
        experimentalClientControlledNullability: true
      )
    )
    let operation = compilationResult.operations.first { $0.name == "AllAnimalsCCN" }
    let ir = IR.mock(compilationResult: compilationResult)
    let rootSelectionSet = ir.build(operation: try XCTUnwrap(operation)).rootField.selectionSet!

    let selectionSet = try XCTUnwrap(
      rootSelectionSet[field: "allAnimals"]?[field: "height"]?.selectionSet
    )

    expected = (
      fields: [
        .mock("feet",
              type: .scalar(GraphQLScalarType.integer())),
        .mock("inches",
              type: .nonNull(.scalar(GraphQLScalarType.integer()))),
      ],
      typeCases: [],
      fragments: []
    )

    // when
    let actual = selectionSet.selections.direct

    // then
    expect(selectionSet.parentType).to(equal(GraphQLObjectType.mock("Height")))
    expect(actual).to(shallowlyMatch(self.expected))
  }
}

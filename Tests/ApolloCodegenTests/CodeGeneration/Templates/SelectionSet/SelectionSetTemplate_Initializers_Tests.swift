import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class SelectionSetTemplate_Initializers_Tests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var operation: IR.Operation!
  var subject: SelectionSetTemplate!

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    schemaSDL = nil
    document = nil
    ir = nil
    operation = nil
    subject = nil
    super.tearDown()
  }

  // MARK: - Helpers

  func buildSubjectAndOperation(
    named operationName: String = "TestOperation"
  ) throws {
    ir = try .mock(schema: schemaSDL, document: document)
    let operationDefinition = try XCTUnwrap(ir.compilationResult[operation: operationName])
    operation = ir.build(operation: operationDefinition)
    let config = ApolloCodegenConfiguration.mock(
      schemaName: "TestSchema",
      options: .init()
    )
    subject = SelectionSetTemplate(
      generateInitializers: true,
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

//  private func buildFragmentTemplate(
//    named fragmentName: String = "TestFragment"
//  ) throws -> FragmentTemplate {
//    ir = try .mock(schema: schemaSDL, document: document)
//    let fragmentDefinition = try XCTUnwrap(ir.compilationResult[fragment: fragmentName])
//    let fragment = ir.build(fragment: fragmentDefinition)
//    let config = ApolloCodegenConfiguration.mock(
//      schemaName: "TestSchema",
//      options: .init(
//        selectionSetInitializers: [.all]
//      )
//    )
//    return FragmentTemplate(fragment: fragment, config: .init(config: config))
//  }

  // MARK: - Tests

  // MARK: Object Type Tests

  func test__render_givenSelectionSetOnObjectType_parametersDoNotIncludeTypenameFieldAndObjectTypeIsRenderedDirectly() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
      public init(
        species: String
      ) {
        let objectType = TestSchema.Objects.Animal
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "species": species
        ]))
      }
    """

    // when
    try buildSubjectAndOperation()

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test__render_givenSelectionSetOnInterfaceType_parametersIncludeTypenameFieldAndObjectTypeIsRenderedWithInterfaceIncluded() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
      public init(
        __typename: String,
        species: String
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
            TestSchema.Interfaces.Animal
        ])
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "species": species
        ]))
      }
    """

    // when
    try buildSubjectAndOperation()

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test__render_givenNestedTypeCaseSelectionSetOnInterfaceTypeNotInheritingFromParentInterface_objectTypeIncludesAllInterfacesInScope() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }

    interface Pet {
      species: String!
    }

    interface WarmBlooded {
      species: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Pet {
          ... on WarmBlooded {
            species
          }
        }
      }
    }
    """

    let expected =
    """
      public init(
        __typename: String,
        species: String
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
            TestSchema.Interfaces.Animal,
            TestSchema.Interfaces.Pet,
            TestSchema.Interfaces.WarmBlooded
        ])
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "species": species
        ]))
      }
    """

    // when
    try buildSubjectAndOperation()

    let allAnimals_asPet_asWarmBlooded = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Pet"]?[as: "WarmBlooded"]
    )

    let actual = subject.render(inlineFragment: allAnimals_asPet_asWarmBlooded)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  // MARK: Selection Tests

  func test__render_given_scalarFieldSelections_rendersInitializer() throws {
      // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      string_optional: String
      int: Int!
      int_optional: Int
      float: Float!
      float_optional: Float
      boolean: Boolean!
      boolean_optional: Boolean
      custom: Custom!
      custom_optional: Custom
      custom_required_list: [Custom!]!
      custom_optional_list: [Custom!]
      list_required_required: [String!]!
      list_optional_required: [String!]
      list_required_optional: [String]!
      list_optional_optional: [String]
      nestedList_required_required_required: [[String!]!]!
      nestedList_required_required_optional: [[String]!]!
      nestedList_required_optional_optional: [[String]]!
      nestedList_required_optional_required: [[String!]]!
      nestedList_optional_required_required: [[String!]!]
      nestedList_optional_required_optional: [[String]!]
      nestedList_optional_optional_required: [[String!]]
      nestedList_optional_optional_optional: [[String]]
    }

    scalar Custom
    """

    document = """
    query TestOperation {
      allAnimals {
        string
        string_optional
        int
        int_optional
        float
        float_optional
        boolean
        boolean_optional
        custom
        custom_optional
        custom_required_list
        custom_optional_list
        list_required_required
        list_optional_required
        list_required_optional
        list_optional_optional
        nestedList_required_required_required
        nestedList_required_required_optional
        nestedList_required_optional_optional
        nestedList_required_optional_required
        nestedList_optional_required_required
        nestedList_optional_required_optional
        nestedList_optional_optional_required
        nestedList_optional_optional_optional
      }
    }
    """

    let expected = """
        public init(
          string: String,
          string_optional: String? = nil,
          int: Int,
          int_optional: Int? = nil,
          float: Double,
          float_optional: Double? = nil,
          boolean: Bool,
          boolean_optional: Bool? = nil,
          custom: TestSchema.Custom,
          custom_optional: TestSchema.Custom? = nil,
          custom_required_list: [TestSchema.Custom],
          custom_optional_list: [TestSchema.Custom]? = nil,
          list_required_required: [String],
          list_optional_required: [String]? = nil,
          list_required_optional: [String?],
          list_optional_optional: [String?]? = nil,
          nestedList_required_required_required: [[String]],
          nestedList_required_required_optional: [[String?]],
          nestedList_required_optional_optional: [[String?]?],
          nestedList_required_optional_required: [[String]?],
          nestedList_optional_required_required: [[String]]? = nil,
          nestedList_optional_required_optional: [[String?]]? = nil,
          nestedList_optional_optional_required: [[String]?]? = nil,
          nestedList_optional_optional_optional: [[String?]?]? = nil
        ) {
          let objectType = TestSchema.Objects.Animal
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "string": string,
              "string_optional": string_optional,
              "int": int,
              "int_optional": int_optional,
              "float": float,
              "float_optional": float_optional,
              "boolean": boolean,
              "boolean_optional": boolean_optional,
              "custom": custom,
              "custom_optional": custom_optional,
              "custom_required_list": custom_required_list,
              "custom_optional_list": custom_optional_list,
              "list_required_required": list_required_required,
              "list_optional_required": list_optional_required,
              "list_required_optional": list_required_optional,
              "list_optional_optional": list_optional_optional,
              "nestedList_required_required_required": nestedList_required_required_required,
              "nestedList_required_required_optional": nestedList_required_required_optional,
              "nestedList_required_optional_optional": nestedList_required_optional_optional,
              "nestedList_required_optional_required": nestedList_required_optional_required,
              "nestedList_optional_required_required": nestedList_optional_required_required,
              "nestedList_optional_required_optional": nestedList_optional_required_optional,
              "nestedList_optional_optional_required": nestedList_optional_optional_required,
              "nestedList_optional_optional_optional": nestedList_optional_optional_optional
          ]))
        }
      """

      // when
      try buildSubjectAndOperation()

      let allAnimals = try XCTUnwrap(
        operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
      )

      let actual = subject.render(field: allAnimals)

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 61, ignoringExtraLines: true))
    }


//  func test__render_givenOperationSelectionSet_configIncludesOperations_rendersInitializer() throws {
//    // given
//    schemaSDL = """
//    type Query {
//      allAnimals: [Animal!]
//    }
//
//    type Animal {
//      species: String!
//    }
//    """
//
//    document = """
//    query TestOperation {
//      allAnimals {
//        species
//      }
//    }
//    """
//
//    let expected =
//    """
//      }
//
//      public init(
//        species: String
//      ) {
//        self.init(data: DataDict(
//          objectType: AnimalKingdomAPI.Objects.Cat,
//          data: ["species": species],
//          variables: nil
//        ))
//      }
//    """
//
//    // when
//    try buildSubjectAndOperation(
//      selectionSetInitializers: [.operations]
//    )
//
//    let allAnimals = try XCTUnwrap(
//      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
//    )
//
//    let actual = subject.render(field: allAnimals)
//
//    // then
//    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
//  }
//
//  func test__render_givenOperationSelectionSet_configIncludesSpecificOperation_rendersInitializer() throws {
//    // given
//    schemaSDL = """
//    type Query {
//      allAnimals: [Animal!]
//    }
//
//    type Animal {
//      species: String!
//    }
//    """
//
//    document = """
//    query TestOperation {
//      allAnimals {
//        species
//      }
//    }
//    """
//
//    let expected =
//    """
//      }
//
//      public init(
//        species: String
//      ) {
//        self.init(data: DataDict(
//          objectType: AnimalKingdomAPI.Objects.Cat,
//          data: ["species": species],
//          variables: nil
//        ))
//      }
//    """
//
//    // when
//    try buildSubjectAndOperation(
//      selectionSetInitializers: [.operation(named: "TestOperation")]
//    )
//
//    let allAnimals = try XCTUnwrap(
//      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
//    )
//
//    let actual = subject.render(field: allAnimals)
//
//    // then
//    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
//  }
//
//  func test__render_givenOperationSelectionSet_configDoesNotIncludeOperations_doesNotRenderInitializer() throws {
//    // given
//    schemaSDL = """
//    type Query {
//      allAnimals: [Animal!]
//    }
//
//    type Animal {
//      species: String!
//    }
//    """
//
//    document = """
//    query TestOperation {
//      allAnimals {
//        species
//      }
//    }
//    """
//
//    // when
//    try buildSubjectAndOperation(
//      selectionSetInitializers: [.namedFragments]
//    )
//
//    let allAnimals = try XCTUnwrap(
//      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
//    )
//
//    let actual = subject.render(field: allAnimals)
//
//    // then
//    expect(actual).to(equalLineByLine("}", atLine: 13, ignoringExtraLines: true))
//  }
//
//  func test__render_givenOperationSelectionSet_configIncludeSpecificOperationWithOtherName_doesNotRenderInitializer() throws {
//    // given
//    schemaSDL = """
//    type Query {
//      allAnimals: [Animal!]
//    }
//
//    type Animal {
//      species: String!
//    }
//    """
//
//    document = """
//    query TestOperation {
//      allAnimals {
//        species
//      }
//    }
//    """
//
//    // when
//    try buildSubjectAndOperation(
//      selectionSetInitializers: [.operation(named: "OtherOperation")]
//    )
//
//    let allAnimals = try XCTUnwrap(
//      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
//    )
//
//    let actual = subject.render(field: allAnimals)
//
//    // then
//    expect(actual).to(equalLineByLine("}", atLine: 13, ignoringExtraLines: true))
//  }
//
//  func test__render_givenNamedFragment_configIncludesNamedFragments_rendersInitializer() throws {
//    // given
//    schemaSDL = """
//    type Query {
//      allAnimals: [Animal!]
//    }
//
//    type Animal {
//      species: String!
//    }
//    """
//
//    document = """
//    fragment TestFragment on Animal {
//      species
//    }
//    """
//
//    let expected =
//    """
//      }
//
//      public init(
//        species: String
//      ) {
//        self.init(data: DataDict(
//          objectType: AnimalKingdomAPI.Objects.Cat,
//          data: ["species": species],
//          variables: nil
//        ))
//      }
//    """
//
//    // when
//    let subject = try buildFragmentTemplate(
//      selectionSetInitializers: [.operations]
//    )
//
//    let actual = subject.render()
//
//    // then
//    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
//  }
//
//  func test__render_givenNamedFragment_configIncludesSpecificFragment_rendersInitializer() throws {
//    // given
//    schemaSDL = """
//    type Query {
//      allAnimals: [Animal!]
//    }
//
//    type Animal {
//      species: String!
//    }
//    """
//
//    document = """
//    fragment TestFragment on Animal {
//      species
//    }
//    """
//
//    let expected =
//    """
//      }
//
//      public init(
//        species: String
//      ) {
//        self.init(data: DataDict(
//          objectType: AnimalKingdomAPI.Objects.Cat,
//          data: ["species": species],
//          variables: nil
//        ))
//      }
//    """
//
//    // when
//    let subject = try buildFragmentTemplate(
//      selectionSetInitializers: [.operations]
//    )
//
//    let actual = subject.render()
//
//    // then
//    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
//  }
//
//  func test__render_givenNamedFragment_configDoesNotIncludeNamedFragments_doesNotRenderInitializer() throws {
//    // given
//    schemaSDL = """
//    type Query {
//      allAnimals: [Animal!]
//    }
//
//    type Animal {
//      species: String!
//    }
//    """
//
//    document = """
//    fragment TestFragment on Animal {
//      species
//    }
//    """
//
//    // when
//    let subject = try buildFragmentTemplate(
//      selectionSetInitializers: [.operations]
//    )
//
//    let actual = subject.render()
//
//    // then
//    expect(actual).to(equalLineByLine("}", atLine: 13, ignoringExtraLines: true))
//  }
//
//  func test__render_givenNamedFragments_configIncludeSpecificFragmentWithOtherName_doesNotRenderInitializer() throws {
//    // given
//    schemaSDL = """
//    type Query {
//      allAnimals: [Animal!]
//    }
//
//    type Animal {
//      species: String!
//    }
//    """
//
//    document = """
//    fragment TestFragment on Animal {
//      species
//    }
//    """
//
//    // when
//    let subject = try buildFragmentTemplate(
//      selectionSetInitializers: [.operations]
//    )
//
//    let actual = subject.render()
//
//    // then
//    expect(actual).to(equalLineByLine("}", atLine: 13, ignoringExtraLines: true))
//  }

}

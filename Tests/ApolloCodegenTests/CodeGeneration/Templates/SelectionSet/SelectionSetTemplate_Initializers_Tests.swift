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
    expect(actual).to(equalLineByLine(expected, atLine: 16, ignoringExtraLines: true))
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

  func test__render_given_fieldWithAlias_rendersInitializer() throws {
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
        aliased: species
      }
    }
    """

    let expected = """
        public init(
          aliased: String
        ) {
          let objectType = TestSchema.Objects.Animal
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "aliased": aliased
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
  
  func test__render_given_entityFieldSelection_rendersInitializer() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
      friend: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        friend {
          species
        }
      }
    }
    """

    let expected = """
        public init(
          friend: Friend
        ) {
          let objectType = TestSchema.Objects.Animal
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "friend": friend._fieldData
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

  func test__render_given_abstractEntityFieldSelectionWithNoFields_rendersInitializer() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      friend: Animal!
    }

    type Cat implements Animal {
      species: String!
      friend: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Cat {
          friend {
            species
          }
        }
      }
    }
    """

    let expected = """
        public init(
          __typename: String
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

  func test__render_given_entityFieldListSelection_rendersInitializer() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
      friends: [Animal!]!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        friends {
          species
        }
      }
    }
    """

    let expected = #"""
        public init(
          friends: [Friend]
        ) {
          let objectType = TestSchema.Objects.Animal
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "friends": friends._fieldData
          ]))
        }
      """#

    // when
    try buildSubjectAndOperation()

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test__render_given_entityFieldSelection_nullable_rendersInitializer() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
      friend: Animal
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        friend {
          species
        }
      }
    }
    """

    let expected = """
        public init(
          friend: Friend? = nil
        ) {
          let objectType = TestSchema.Objects.Animal
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "friend": friend._fieldData
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


  func test__render_given_mergedSelection_rendersInitializer() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      age: Int!
    }

    interface Pet implements Animal {
      species: String!
      age: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        age
        ... on Pet {
          species
        }
      }
    }
    """

    let expected =
    """
      public init(
        __typename: String,
        species: String,
        age: Int
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
            TestSchema.Interfaces.Animal,
            TestSchema.Interfaces.Pet
        ])
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "species": species,
            "age": age
        ]))
      }
    """

    // when
    try buildSubjectAndOperation()

    let allAnimals_asPet = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Pet"]
    )

    let actual = subject.render(inlineFragment: allAnimals_asPet)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 17, ignoringExtraLines: true))
  }

  func test__render_given_mergedOnly_SelectionSet_rendersInitializer() throws {
    // given
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      height: Height
    }

    interface Pet implements Animal {
      height: Height
    }

    type Cat implements Animal & Pet {
      breed: String!
      height: Height
    }

    type Height {
      feet: Int
      inches: Int
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        height {
          inches
        }
        ... on Pet {
          height {
            feet
          }
        }
        ... on Cat {
          breed
        }
      }
    }
    """

    let expected =
    """
      public init(
        inches: Int? = nil,
        feet: Int? = nil
      ) {
        let objectType = TestSchema.Objects.Height
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "inches": inches,
            "feet": feet
        ]))
      }
    """

    // when
    try buildSubjectAndOperation()

    let asCat_height = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Cat"]?[field: "height"] as? IR.EntityField
    )

    let actual = subject.render(field: asCat_height)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

}

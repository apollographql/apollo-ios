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
      schemaNamespace: "TestSchema",
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
        self.init(_dataDict: DataDict(data: [
          "__typename": TestSchema.Objects.Animal.typename,
          "species": species,
          "__fulfilled": Set([
            ObjectIdentifier(Self.self)
          ])
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
  
  func test__render_givenSelectionSetOnInterfaceType_parametersIncludeTypenameField() throws {
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
        self.init(_dataDict: DataDict(data: [
          "__typename": __typename,
          "species": species,
          "__fulfilled": Set([
            ObjectIdentifier(Self.self)
          ])
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

  #warning("TODO: Write tests that included named fragments are included in initializer.")
  #warning("TODO: Write tests that union type cases are included in initializer.")

  func test__render_givenNestedTypeCaseSelectionSetOnInterfaceTypeNotInheritingFromParentInterface_fulfilledFragmentsIncludesAllTypeCasesInScope() throws {
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
        self.init(_dataDict: DataDict(data: [
          "__typename": __typename,
          "species": species,
          "__fulfilled": Set([
            ObjectIdentifier(Self.self),
            ObjectIdentifier(AllAnimal.self),
            ObjectIdentifier(AllAnimal.AsPet.self)
          ])
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
          self.init(_dataDict: DataDict(data: [
            "__typename": TestSchema.Objects.Animal.typename,
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
            "nestedList_optional_optional_optional": nestedList_optional_optional_optional,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self)
            ])
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
          self.init(_dataDict: DataDict(data: [
            "__typename": TestSchema.Objects.Animal.typename,
            "aliased": aliased,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self)
            ])
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
          self.init(_dataDict: DataDict(data: [
            "__typename": TestSchema.Objects.Animal.typename,
            "friend": friend._fieldData,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self)
            ])
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
          self.init(_dataDict: DataDict(data: [
            "__typename": __typename,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self)
            ])
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
          self.init(_dataDict: DataDict(data: [
            "__typename": TestSchema.Objects.Animal.typename,
            "friends": friends._fieldData,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self)
            ])
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
          self.init(_dataDict: DataDict(data: [
            "__typename": TestSchema.Objects.Animal.typename,
            "friend": friend._fieldData,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self)
            ])
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
        self.init(_dataDict: DataDict(data: [
          "__typename": __typename,
          "species": species,
          "age": age,
          "__fulfilled": Set([
            ObjectIdentifier(Self.self),
            ObjectIdentifier(AllAnimal.self)
          ])
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
        self.init(_dataDict: DataDict(data: [
          "__typename": TestSchema.Objects.Height.typename,
          "inches": inches,
          "feet": feet,
          "__fulfilled": Set([
            ObjectIdentifier(Self.self)
          ])
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

  // MARK: - Include/Skip Tests

  func test__render_given_inlineFragmentWithInclusionCondition_rendersInitializerWithFulfilledFragments() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
      friend: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... @include(if: $a) {
          name
        }
        friend {
          species
        }
      }
    }
    """

    let expected = """
        public init(
          name: String,
          friend: Friend
        ) {
          self.init(_dataDict: DataDict(data: [
            "__typename": TestSchema.Objects.Animal.typename,
            "name": name,
            "friend": friend._fieldData,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self),
              ObjectIdentifier(AllAnimal.self)
            ])
          ]))
        }
      """

    // when
    try buildSubjectAndOperation()

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[if: "a"]
    )

    let actual = subject.render(inlineFragment: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 17, ignoringExtraLines: true))
  }

  func test__render_given_inlineFragmentWithMultipleInclusionConditions_rendersInitializerWithFulfilledFragments() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
      friend: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!, $b: Boolean!) {
      allAnimals {
        ... @include(if: $a) @skip(if: $b) {
          name
        }
        friend {
          species
        }
      }
    }
    """

    let expected = """
        public init(
          name: String,
          friend: Friend
        ) {
          self.init(_dataDict: DataDict(data: [
            "__typename": TestSchema.Objects.Animal.typename,
            "name": name,
            "friend": friend._fieldData,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self),
              ObjectIdentifier(AllAnimal.self)
            ])
          ]))
        }
      """

    // when
    try buildSubjectAndOperation()

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[if: "a" && !"b"]
    )

    let actual = subject.render(inlineFragment: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 17, ignoringExtraLines: true))
  }

  func test__render_given_inlineFragmentWithNestedInclusionConditions_rendersInitializerWithFulfilledFragments() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
      friend: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!, $b: Boolean!) {
      allAnimals {
        ... @include(if: $a) {
          ... @skip(if: $b) {
            name
          }
        }
        friend {
          species
        }
      }
    }
    """

    let expected = """
        public init(
          name: String,
          friend: Friend
        ) {
          self.init(_dataDict: DataDict(data: [
            "__typename": TestSchema.Objects.Animal.typename,
            "name": name,
            "friend": friend._fieldData,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self),
              ObjectIdentifier(AllAnimal.self),
              ObjectIdentifier(AllAnimal.IfA.self)
            ])
          ]))
        }
      """

    // when
    try buildSubjectAndOperation()

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[if: "a"]?[if: !"b"]
    )

    let actual = subject.render(inlineFragment: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 17, ignoringExtraLines: true))
  }

  func test__render_given_inlineFragmentWithInclusionConditionNestedInEntityWithOtherInclusionCondition_rendersInitializerWithFulfilledFragments() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
      friend: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!, $b: Boolean!) {
      allAnimals {
        ... @include(if: $a) {
          friend {
            ... @skip(if: $b) {
              name
            }
            species
          }
        }
      }
    }
    """

    let expected = """
        public init(
          name: String,
          species: String
        ) {
          self.init(_dataDict: DataDict(data: [
            "__typename": TestSchema.Objects.Animal.typename,
            "name": name,
            "species": species,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self),
              ObjectIdentifier(AllAnimal.IfA.Friend.self)
            ])
          ]))
        }
      """

    // when
    try buildSubjectAndOperation()

    let allAnimals_friend = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[if: "a"]?[field: "friend"]?[if: !"b"]
    )

    let actual = subject.render(inlineFragment: allAnimals_friend)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 17, ignoringExtraLines: true))
  }
}

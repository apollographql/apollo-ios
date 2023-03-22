import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class SelectionSetTemplate_LocalCacheMutationTests: XCTestCase {

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
    schemaNamespace: String = "TestSchema",
    named operationName: String = "TestOperation"
  ) throws {
    ir = try .mock(schema: schemaSDL, document: document)
    let operationDefinition = try XCTUnwrap(ir.compilationResult[operation: operationName])
    operation = ir.build(operation: operationDefinition)
    subject = SelectionSetTemplate(
      mutable: true,
      generateInitializers: false,
      config: .init(config: .mock(schemaNamespace: schemaNamespace))
    )
  }

  // MARK: - Declaration Tests

  func test__renderForOperation__rendersDeclarationAsMutableSelectionSet() throws {
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
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    let expected = """
    public struct Data: TestSchema.MutableSelectionSet {
    """

    // when
    try buildSubjectAndOperation()
    let actual = subject.render(for: operation)

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__renderForEntityField__rendersDeclarationAsMutableSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }

    type Dog {
      name: String!
    }
    """

    document = """
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        ... on Dog {
          name
        }
      }
    }
    """

    let expected = """
    public struct AllAnimal: TestSchema.MutableSelectionSet {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 2, ignoringExtraLines: true))
  }

  func test__renderForInlineFragment__rendersDeclarationAsMutableInlineFragment() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }

    type Dog {
      name: String!
    }
    """

    document = """
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        ... on Dog {
          name
        }
      }
    }
    """

    let expected = """
      public struct AsDog: TestSchema.MutableInlineFragment {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 17, ignoringExtraLines: true))
  }

  // MARK: - Accessor Tests

  func test__render_dataDict__rendersDataDictAsVar() throws {
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
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    let expected = """
      public var __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3, ignoringExtraLines: true))
  }

  func test__render_fragmentContainer_dataDict__rendersDataDictAsVar() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...FragmentA
      }
    }

    fragment FragmentA on Animal {
      int
    }
    """

    let expected = """
      public struct Fragments: FragmentContainer {
        public var __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 16, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__rendersFieldAccessorWithGetterAndSetter() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldName: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        fieldName
      }
    }
    """

    let expected = """
      public var fieldName: String {
        get { __data["fieldName"] }
        set { __data["fieldName"] = newValue }
      }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_inlineFragmentAccessors__rendersAccessorWithGetterAndSetter() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }

    type Dog {
      name: String!
    }
    """

    document = """
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        ... on Dog {
          name
        }
      }
    }
    """

    let expected = """
      public var asDog: AsDog? {
        get { _asInlineFragment() }
        set { if let newData = newValue?.__data._data { __data._data = newData }}
      }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_namedFragmentAccessors__givenFragmentWithNoConditions_rendersAccessorWithGetterModifierAndSetterUnavailable() throws {
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
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        ...AnimalDetails
      }
    }

    fragment AnimalDetails on Animal {
      species
    }
    """

    let expected = """
        public var animalDetails: AnimalDetails {
          get { _toFragment() }
          _modify { var f = animalDetails; yield &f; __data = f.__data }
          @available(*, unavailable, message: "mutate properties of the fragment instead.")
          set { preconditionFailure() }
        }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 20, ignoringExtraLines: true))
  }

  func test__render_namedFragmentAccessors__givenFragmentWithConditions_rendersAccessorAsOptionalWithGetterAndSetter() throws {
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
    query TestOperation($a: Boolean!) @apollo_client_ios_localCacheMutation {
      allAnimals {
        ...AnimalDetails @include(if: $a)
      }
    }

    fragment AnimalDetails on Animal {
      species
    }
    """

    let expected = """
        public var animalDetails: AnimalDetails? {
          get { _toFragment() }
          _modify { var f = animalDetails; yield &f; if let newData = f?.__data { __data = newData } }
          @available(*, unavailable, message: "mutate properties of the fragment instead.")
          set { preconditionFailure() }
        }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 20, ignoringExtraLines: true))
  }

  // MARK: - Casing Tests

  func test__casingForMutableSelectionSet__givenLowercasedSchemaName_generatesFirstUppercasedNamespace() throws {
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

    // when
    try buildSubjectAndOperation(schemaNamespace: "myschema")
    let actual = subject.render(for: operation)

    // then
    let expected = """
    public struct Data: Myschema.MutableSelectionSet {
    """

    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__casingForMutableSelectionSet__givenUppercasedSchemaName_generatesUppercasedNamespace() throws {
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

    // when
    try buildSubjectAndOperation(schemaNamespace: "MYSCHEMA")
    let actual = subject.render(for: operation)

    // then
    let expected = """
    public struct Data: MYSCHEMA.MutableSelectionSet {
    """

    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__casingForMutableSelectionSet__givenCapitalizedSchemaName_generatesCapitalizedNamespace() throws {
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
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    // when
    try buildSubjectAndOperation(schemaNamespace: "MySchema")
    let actual = subject.render(for: operation)

    // then
    let expected = """
    public struct Data: MySchema.MutableSelectionSet {
    """

    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__casingForMutableInlineFragment__givenLowercasedSchemaName_generatesFirstUppercasedNamespace() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }

    type Dog {
      name: String!
    }
    """

    document = """
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        ... on Dog {
          name
        }
      }
    }
    """

    // when
    try buildSubjectAndOperation(schemaNamespace: "myschema")
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    let expected = """
      public struct AsDog: Myschema.MutableInlineFragment {
    """

    expect(actual).to(equalLineByLine(expected, atLine: 17, ignoringExtraLines: true))
  }

  func test__casingForMutableInlineFragment__givenUppercasedSchemaName_generatesUppercasedNamespace() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }

    type Dog {
      name: String!
    }
    """

    document = """
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        ... on Dog {
          name
        }
      }
    }
    """

    // when
    try buildSubjectAndOperation(schemaNamespace: "MYSCHEMA")
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    let expected = """
      public struct AsDog: MYSCHEMA.MutableInlineFragment {
    """

    expect(actual).to(equalLineByLine(expected, atLine: 17, ignoringExtraLines: true))
  }

  func test__casingForMutableInlineFragment__givenCapitalizedSchemaName_generatesCapitalizedNamespace() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }

    type Dog {
      name: String!
    }
    """

    document = """
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        ... on Dog {
          name
        }
      }
    }
    """

    // when
    try buildSubjectAndOperation(schemaNamespace: "MySchema")
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    let expected = """
      public struct AsDog: MySchema.MutableInlineFragment {
    """

    expect(actual).to(equalLineByLine(expected, atLine: 17, ignoringExtraLines: true))
  }
}

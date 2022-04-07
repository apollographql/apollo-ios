import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class SelectionSetTemplateTests: XCTestCase {

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

  func buildSubjectAndOperation(named operationName: String = "TestOperation") throws {
    ir = try .mock(schema: schemaSDL, document: document)
    let operationDefinition = try XCTUnwrap(ir.compilationResult[operation: operationName])
    operation = ir.build(operation: operationDefinition)
    subject = SelectionSetTemplate(schema: ir.schema)
  }

  // MARK: - Tests

  func test__render_rendersClosingBracket() throws {
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

    // when
    try buildSubjectAndOperation()

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(String(actual.reversed())).to(equalLineByLine("}", ignoringExtraLines: true))
  }

  // MARK: Parent Type

  func test__render_parentType__givenParentTypeAs_Object_rendersParentType() throws {
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

    let expected = """
      public static var __parentType: ParentType { .Object(TestSchema.Animal.self) }
    """

    // when
    try buildSubjectAndOperation()

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render_parentType__givenParentTypeAs_Interface_rendersParentType() throws {
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

    let expected = """
      public static var __parentType: ParentType { .Interface(TestSchema.Animal.self) }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render_parentType__givenParentTypeAs_Union_rendersParentType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Dog {
      species: String!
    }

    union Animal = Dog
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Dog {
          species
        }
      }
    }
    """

    let expected = """
      public static var __parentType: ParentType { .Union(TestSchema.Animal.self) }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  // MARK: - Selections

  func test__render_selections__givenNilDirectSelections_doesNotRenderSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Dog {
      species: String!
      nested: Nested!
    }

    type Nested {
      a: Int!
      b: Int!
    }

    interface Animal {
      nested: Nested!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        nested {
          a
        }
        ... on Dog {
          species
        }
      }
    }
    """

    let expected = """
      public static var __parentType: ParentType { .Object(TestSchema.Nested.self) }
    
    """

    // when
    try buildSubjectAndOperation()
    let asDog_Nested = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "nested"] as? IR.EntityField
    )

    let actual = subject.render(field: asDog_Nested)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  // MARK: Selections - Fields

  func test__render_selections__givenScalarFieldSelections_rendersAllFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      string_optional: String
      boolean: Boolean!
      boolean_optional: Boolean
      int: Int!
      int_optional: Int
      custom: Custom!
      custom_optional: Custom
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
        boolean
        boolean_optional
        int
        int_optional
        custom
        custom_optional
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
      public static var selections: [Selection] { [
        .field("string", String.self),
        .field("string_optional", String?.self),
        .field("boolean", Bool.self),
        .field("boolean_optional", Bool?.self),
        .field("int", Int.self),
        .field("int_optional", Int?.self),
        .field("custom", Custom.self),
        .field("custom_optional", Custom?.self),
        .field("list_required_required", [String].self),
        .field("list_optional_required", [String]?.self),
        .field("list_required_optional", [String?].self),
        .field("list_optional_optional", [String?]?.self),
        .field("nestedList_required_required_required", [[String]].self),
        .field("nestedList_required_required_optional", [[String?]].self),
        .field("nestedList_required_optional_optional", [[String?]?].self),
        .field("nestedList_required_optional_required", [[String]?].self),
        .field("nestedList_optional_required_required", [[String]]?.self),
        .field("nestedList_optional_required_optional", [[String?]]?.self),
        .field("nestedList_optional_optional_required", [[String]?]?.self),
        .field("nestedList_optional_optional_optional", [[String?]?]?.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenEnumField_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      testEnum: TestEnum!
      testEnumOptional: TestEnumOptional
    }

    enum TestEnum {
      CASE_ONE
    }

    enum TestEnumOptional {
      CASE_ONE
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        testEnum
        testEnumOptional
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .field("testEnum", GraphQLEnum<TestEnum>.self),
        .field("testEnumOptional", GraphQLEnum<TestEnumOptional>?.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithUppercasedName_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      FieldName: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        FieldName
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .field("FieldName", String.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithAlias_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        aliased: string
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .field("string", alias: "aliased", String.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenEnitityFieldWithNameNotMatchingType_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      predator: Animal!
      species: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .field("predator", Predator.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  // MARK: Selections - Fields - Arguments

  func test__render_selections__givenFieldWithArgumentWithConstantValue_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string(variable: Int): String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        aliased: string(variable: 3)
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .field("string", alias: "aliased", String.self, arguments: ["variable": 3]),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithArgumentWithNullConstantValue_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string(variable: Int): String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        aliased: string(variable: null)
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .field("string", alias: "aliased", String.self, arguments: ["variable": .null]),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithArgumentWithVariableValue_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string(variable: Int): String!
    }
    """

    document = """
    query TestOperation($var: Int) {
      allAnimals {
        aliased: string(variable: $var)
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .field("string", alias: "aliased", String.self, arguments: ["variable": .variable("var")]),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithArgumentOfInputObjectTypeWithNullableFields_withConstantValues_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string(input: TestInput): String!
    }

    input TestInput {
      string: String
      int: Int
      float: Float
      bool: Boolean
      list: [String]
      enum: TestEnum
      innerInput: InnerInput
    }

    input InnerInput {
      string: String
      enumList: [TestEnum]
    }

    enum TestEnum {
      CaseOne
      CaseTwo
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        aliased: string(input: {
          string: "ABCD",
          int: 3,
          float: 123.456,
          bool: true,
          list: ["A", "B"],
          enum: CaseOne,
          innerInput: {
            string: "EFGH",
            enumList: [CaseOne, CaseTwo]
          }
        })
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .field("string", alias: "aliased", String.self, arguments: ["input": [
          "string": "ABCD",
          "int": 3,
          "float": 123.456,
          "bool": true,
          "list": ["A", "B"],
          "enum": "CaseOne",
          "innerInput": [
            "string": "EFGH",
            "enumList": ["CaseOne", "CaseTwo"]
          ]
        ]]),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  // MARK: Selections - Type Cases

  func test__render_selections__givenTypeCases_rendersTypeCaseSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
    }

    interface Pet {
      int: Int!
    }

    interface lowercaseInterface {
      int: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Pet {
          int
        }
        ... on lowercaseInterface {
          int
        }
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .typeCase(AsPet.self),
        .typeCase(AsLowercaseInterface.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  // MARK: Selections - Fragments

  func test__render_selections__givenFragments_rendersFragmentSelections() throws {
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
        ...lowercaseFragment
      }
    }

    fragment FragmentA on Animal {
      int
    }

    fragment lowercaseFragment on Animal {
      string
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .fragment(FragmentA.self),
        .fragment(LowercaseFragment.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  // MARK: Selections - Include/Skip

  func test__render_selections__givenFieldWithIncludeCondition_rendersFieldSelections() throws {
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
    query TestOperation($a: Boolean!) {
      allAnimals {
        fieldName @include(if: $a)
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .include(if: "a", .field("fieldName", String.self)),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithSkipCondition_rendersFieldSelections() throws {
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
    query TestOperation($b: Boolean!) {
      allAnimals {
        fieldName @skip(if: $b)
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .include(if: !"b", .field("fieldName", String.self)),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithMultipleConditions_rendersFieldSelections() throws {
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
    query TestOperation($b: Boolean!) {
      allAnimals {
        fieldName @skip(if: $b) @include(if: $a)
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .include(if: !"b" && "a", .field("fieldName", String.self)),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenMergedFieldsWithMultipleConditions_rendersFieldSelections() throws {
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
    query TestOperation($b: Boolean!) {
      allAnimals {
        fieldName @skip(if: $b) @include(if: $a)
        fieldName @skip(if: $c)
        fieldName @include(if: $d) @skip(if: $e)
        fieldName @include(if: $f)
      }
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .include(if: (!"b" && "a") || !"c" || ("d" && !"e") || "f", .field("fieldName", String.self)),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenMultipleSelectionsWithSameIncludeConditions_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
      fieldB: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        fieldA @include(if: $a)
        fieldB @include(if: $a)
        ... on Pet @include(if: $a) {
          fieldA
        }
        ...FragmentA @include(if: $a)
      }
    }

    fragment FragmentA on Animal {
      fieldA
    }
    """

    let expected = """
      public static var selections: [Selection] { [
        .include(if: "a", [
          .field("fieldA", String.self),
          .field("fieldB", String.self),
          .typeCase(AsPet.self),
          .fragment(FragmentA.self)
        ]),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  // MARK: - Field Accessors - Scalar

  func test__render_fieldAccessors__givenScalarFields_rendersAllFieldAccessors() throws {
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
      custom: Custom!
      custom_optional: Custom
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
        custom
        custom_optional
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
      public var string: String { data["string"] }
      public var string_optional: String? { data["string_optional"] }
      public var int: Int { data["int"] }
      public var int_optional: Int? { data["int_optional"] }
      public var custom: Custom { data["custom"] }
      public var custom_optional: Custom? { data["custom_optional"] }
      public var list_required_required: [String] { data["list_required_required"] }
      public var list_optional_required: [String]? { data["list_optional_required"] }
      public var list_required_optional: [String?] { data["list_required_optional"] }
      public var list_optional_optional: [String?]? { data["list_optional_optional"] }
      public var nestedList_required_required_required: [[String]] { data["nestedList_required_required_required"] }
      public var nestedList_required_required_optional: [[String?]] { data["nestedList_required_required_optional"] }
      public var nestedList_required_optional_optional: [[String?]?] { data["nestedList_required_optional_optional"] }
      public var nestedList_required_optional_required: [[String]?] { data["nestedList_required_optional_required"] }
      public var nestedList_optional_required_required: [[String]]? { data["nestedList_optional_required_required"] }
      public var nestedList_optional_required_optional: [[String?]]? { data["nestedList_optional_required_optional"] }
      public var nestedList_optional_optional_required: [[String]?]? { data["nestedList_optional_optional_required"] }
      public var nestedList_optional_optional_optional: [[String?]?]? { data["nestedList_optional_optional_optional"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 28, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEnumField_rendersFieldAccessors() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      testEnum: TestEnum!
      testEnumOptional: TestEnumOptional
    }

    enum TestEnum {
      CASE_ONE
    }

    enum TestEnumOptional {
      CASE_ONE
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        testEnum
        testEnumOptional
      }
    }
    """

    let expected = """
      public var testEnum: GraphQLEnum<TestEnum> { data["testEnum"] }
      public var testEnumOptional: GraphQLEnum<TestEnumOptional>? { data["testEnumOptional"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenFieldWithUpperCaseName_rendersFieldAccessorWithLowercaseName() throws {
    // given
    schemaSDL = """
    type Query {
      AllAnimals: [Animal!]
    }

    type Animal {
      FieldName: String!
    }

    scalar Custom
    """

    document = """
    query TestOperation {
      AllAnimals {
        FieldName
      }
    }
    """

    let expected = """
      public var fieldName: String { data["FieldName"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "AllAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenFieldWithAlias_rendersAllFieldAccessors() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
    }

    scalar Custom
    """

    document = """
    query TestOperation {
      allAnimals {
        aliasedFieldName: string
      }
    }
    """

    let expected = """
      public var aliasedFieldName: String { data["aliasedFieldName"] }
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

  func test__render_fieldAccessors__givenMergedScalarField_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
    }

    type Dog {
      b: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        a
        ... on Dog {
          b
        }
      }
    }
    """

    let expected = """
      public var b: String { data["b"] }
      public var a: String { data["a"] }
    """

    // when
    try buildSubjectAndOperation()
    let dog = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]
    )

    let actual = subject.render(inlineFragment: dog)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  // MARK: - Field Accessors - Entity

  func test__render_fieldAccessors__givenDirectEntityField_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
      }
    }
    """

    let expected = """
      public var predator: Predator { data["predator"] }
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

  func test__render_fieldAccessors__givenDirectEntityFieldWithAlias_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        aliasedPredator: predator {
          species
        }
      }
    }
    """

    let expected = """
      public var aliasedPredator: AliasedPredator { data["aliasedPredator"] }
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

  func test__render_fieldAccessors__givenDirectEntityFieldAsOptional_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
      }
    }
    """

    let expected = """
      public var predator: Predator? { data["predator"] }
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

  func test__render_fieldAccessors__givenDirectEntityFieldAsList_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predators: [Animal!]
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predators {
          species
        }
      }
    }
    """

    let expected = """
      public var predators: [Predator]? { data["predators"] }
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

  func test__render_fieldAccessors__givenEntityFieldWithDirectSelectionsAndMergedFromFragment_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      name: String!
      predator: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...PredatorDetails
        predator {
          name
        }
      }
    }

    fragment PredatorDetails on Animal {
      predator {
        species
      }
    }
    """

    let expected = """
      public var predator: Predator { data["predator"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  // MARK: Field Accessors - Merged Fragment

  func test__render_fieldAccessors__givenEntityFieldMergedFromFragment_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...PredatorDetails
      }
    }

    fragment PredatorDetails on Animal {
      predator {
        species
      }
    }
    """

    let expected = """
      public var predator: PredatorDetails.Predator { data["predator"] }
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

  func test__render_fieldAccessors__givenEntityFieldMergedFromFragmentEntityNestedInEntity_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    type Height {
      feet: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
        ...PredatorDetails
      }
    }

    fragment PredatorDetails on Animal {
      predator {
        height {
          feet
        }
      }
    }
    """

    let expected = """
      public var species: String { data["species"] }
      public var height: PredatorDetails.Predator.Height { data["height"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldMergedFromFragmentInTypeCaseWithEntityNestedInEntity_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface Pet {
      predator: Animal!
    }

    type Height {
      feet: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
        ...PredatorDetails
      }
    }

    fragment PredatorDetails on Pet {
      predator {
        height {
          feet
        }
      }
    }
    """

    let expected = """
      public var height: PredatorDetails.Predator.Height { data["height"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asPet_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Pet"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asPet_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldMergedFromFragmentWithEntityNestedInEntityTypeCase_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface Pet {
      height: Height!
    }

    type Height {
      feet: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
        ...PredatorDetails
      }
    }

    fragment PredatorDetails on Animal {
      predator {
        ... on Pet {
          height {
            feet
          }
        }
      }
    }
    """

    let predator_expected = """
      public var species: String { data["species"] }

    """

    let predator_asPet_expected = """
      public var species: String { data["species"] }
      public var height: PredatorDetails.Predator.AsPet.Height { data["height"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "predator"] as? IR.EntityField
    )

    let allAnimals_predator_asPet = try XCTUnwrap(allAnimals_predator[as: "Pet"])

    let allAnimals_predator_actual = subject.render(field: allAnimals_predator)
    let allAnimals_predator_asPet_actual = subject.render(inlineFragment: allAnimals_predator_asPet)

    // then
    expect(allAnimals_predator_actual).to(equalLineByLine(predator_expected, atLine: 11, ignoringExtraLines: true))
    expect(allAnimals_predator_asPet_actual).to(equalLineByLine(predator_asPet_expected, atLine: 8, ignoringExtraLines: true))
  }

  // MARK: Field Accessors - Merged From Parent

  func test__render_fieldAccessors__givenEntityFieldMergedFromParent_rendersFieldAccessorWithDirectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    type Dog implements Animal {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
        ... on Dog {
          name
        }
      }
    }
    """

    let expected = """
      public var name: String { data["name"] }
      public var predator: Predator { data["predator"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]
    )

    let actual = subject.render(inlineFragment: allAnimals_asDog)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldMergedFromSiblingTypeCase_rendersFieldAccessorWithCorrectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
    }

    type Dog implements Animal & Pet {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Pet {
          predator {
            species
          }
        }
        ... on Dog {
          name
        }
      }
    }
    """

    let expected = """
      public var name: String { data["name"] }
      public var predator: AsPet.Predator { data["predator"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]
    )

    let actual = subject.render(inlineFragment: allAnimals_asDog)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldNestedInEntityFieldMergedFromParent_rendersFieldAccessorWithCorrectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    type Dog implements Animal {
      name: String!
      species: String!
      predator: Animal!
      height: Height!
    }

    type Height {
      feet: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          height {
            feet
          }
        }
        ... on Dog {
          predator {
            species
          }
        }
      }
    }
    """

    let expected = """
      public var species: String { data["species"] }
      public var height: AllAnimal.Predator.Height { data["height"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asDog_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldNestedInEntityFieldInMatchingTypeCaseMergedFromParent_rendersFieldAccessorWithCorrectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    type Dog implements Animal & Pet {
      name: String!
      species: String!
      predator: Animal!
      height: Height!
    }

    type Height {
      feet: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Pet {
          predator {
            height {
              feet
            }
          }
        }
        ... on Dog {
          predator {
            species
          }
        }
      }
    }
    """

    let expected = """
      public var species: String { data["species"] }
      public var height: AllAnimal.AsPet.Predator.Height { data["height"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asDog_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  // MARK: Field Accessors - Include/Skip

  func test__render_fieldAccessor__givenNonNullFieldWithIncludeCondition_rendersAsOptional() throws {
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
    query TestOperation($a: Boolean!) {
      allAnimals {
        fieldName @include(if: $a)
      }
    }
    """

    let expected = """
      public var fieldName: String? { data["fieldName"] }
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

  func test__render_fieldAccessor__givenNonNullFieldWithSkipCondition_rendersAsOptional() throws {
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
    query TestOperation($a: Boolean!) {
      allAnimals {
        fieldName @skip(if: $a)
      }
    }
    """

    let expected = """
      public var fieldName: String? { data["fieldName"] }
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

  // MARK: - Inline Fragment Accessors

  func test__render_inlineFragmentAccessors__givenDirectTypeCases_rendersTypeCaseAccessorWithCorrectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      name: String!
    }

    type Dog implements Animal & Pet {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
        ... on Pet {
          name
        }
        ... on Dog {
          name
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asType() }
      public var asDog: AsDog? { _asType() }
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

  func test__render_inlineFragmentAccessors__givenMergedTypeCasesFromSingleMergedTypeCaseSource_rendersTypeCaseAccessorWithCorrectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      name: String!
    }

    type Dog implements Animal & Pet {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
        predator {
          ... on Pet {
            name
          }
        }
        ... on Dog {
          name
          predator {
            species
          }
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asType() }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asDog_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  // MARK: Inline Fragment Accessors - Include/Skip

  func test__render_inlineFragmentAccessors__givenInlineFragmentOnDifferentTypeWithCondition_rendersWithConditionInTypeCaseConversionFunction() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... on Pet @include(if: $a) {
          fieldA
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asType(if: "a") }
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

  func test__render_inlineFragmentAccessors__givenInlineFragmentOnDifferentTypeWithSkipCondition_rendersWithConditionInTypeCaseConversionFunction() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... on Pet @skip(if: $a) {
          fieldA
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asType(if: !"a") }
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

  func test__render_inlineFragmentAccessors__givenInlineFragmentOnDifferentTypeWithMultipleConditions_rendersWithConditionInTypeCaseConversionFunction() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... on Pet @include(if: $a) @skip(if: $b) {
          fieldA
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asType(if: "a" && !"b") }
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

  func test__render_inlineFragmentAccessors__givenInlineFragmentOnSameTypeWithMultipleConditions_rendersConditionalSelectionSetAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... on Animal @include(if: $a) @skip(if: $b) {
          fieldA
        }
      }
    }
    """

    let expected = """
      public var ifAAndNotB: IfAAndNotB? { _asInlineFragment(if: "a" && !"b") }
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

  // MARK: - Fragment Accessors

  func test__render_fragmentAccessor__givenFragments_rendersFragmentAccessor() throws {
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
        ...lowercaseFragment
      }
    }

    fragment FragmentA on Animal {
      int
    }

    fragment lowercaseFragment on Animal {
      string
    }
    """

    let expected = """
      public struct Fragments: FragmentContainer {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public var fragmentA: FragmentA { _toFragment() }
        public var lowercaseFragment: LowercaseFragment { _toFragment() }
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

  func test__render_fragmentAccessor__givenInheritedFragmentFromParent_rendersFragmentAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      string: String!
      int: Int!
    }

    type Cat implements Animal {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...FragmentA
        ... on Cat {
          string
        }
      }
    }

    fragment FragmentA on Animal {
      int
    }

    fragment lowercaseFragment on Animal {
      string
    }
    """

    let expected = """
      public struct Fragments: FragmentContainer {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public var fragmentA: FragmentA { _toFragment() }
      }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asCat = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Cat"]
    )

    let actual = subject.render(inlineFragment: allAnimals_asCat)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 14, ignoringExtraLines: true))
  }

  // MARK: - Nested Selection Sets

  func test__render_nestedSelectionSets__givenDirectEntityFieldAsList_rendersNestedSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predators: [Animal!]
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predators {
          species
        }
      }
    }
    """

    let expected = """
      public var predators: [Predator]? { data["predators"] }

      /// AllAnimal.Predator
      public struct Predator: TestSchema.SelectionSet {
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

  func test__render_nestedSelectionSets__givenEntityFieldMergedFromTwoSources_rendersMergedSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface WarmBlooded implements Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    type Dog implements Animal & Pet & WarmBlooded {
      name: String!
      species: String!
      predator: Animal!
      height: Height!
    }

    type Height {
      feet: Int!
      meters: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Pet {
          predator {
            height {
              feet
            }
          }
        }
        ... on WarmBlooded {
          predator {
            height {
              meters
            }
          }
        }
        ... on Dog {
          predator {
            species
          }
        }
      }
    }
    """

    let expected = """
      public var species: String { data["species"] }
      public var height: Height { data["height"] }

      /// AllAnimal.AsDog.Predator.Height
      public struct Height: TestSchema.SelectionSet {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asDog_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet__givenEntityFieldMergedFromFragment_doesNotRendersSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...PredatorDetails
      }
    }

    fragment PredatorDetails on Animal {
      predator {
        species
      }
    }
    """

    let expected = """
      public var predator: PredatorDetails.Predator { data["predator"] }

      public struct Fragments: FragmentContainer {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public var predatorDetails: PredatorDetails { _toFragment() }
      }
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

  func test__render_nestedSelectionSets__givenDirectSelection_typeCase_rendersNestedSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      name: String!
    }

    type Dog implements Animal & Pet {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
        ... on Pet {
          name
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asType() }

      /// AllAnimal.AsPet
      public struct AsPet: TestSchema.TypeCase {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 14, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet__givenMergedTypeCasesFromSingleMergedTypeCaseSource_rendersTypeCaseSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      name: String!
    }

    type Dog implements Animal & Pet {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
        predator {
          ... on Pet {
            name
          }
        }
        ... on Dog {
          name
          predator {
            species
          }
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asType() }

      /// AllAnimal.AsDog.Predator.AsPet
      public struct AsPet: TestSchema.TypeCase {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asDog_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet__givenInlineFragmentOnSameTypeWithMultipleConditions_rendersConditionalSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... on Animal @include(if: $a) @skip(if: $b) {
          fieldA
        }
      }
    }
    """

    let expected = """
      public var ifAAndNotB: IfAAndNotB? { _asInlineFragment(if: "a" && !"b") }

      /// AllAnimal.IfAAndNotB
      public struct IfAAndNotB: TestSchema.TypeCase {
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

}

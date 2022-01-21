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
    expect(actual).to(equalLineByLine(expected, atLine: 5, ignoringExtraLines: true))
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
    expect(actual).to(equalLineByLine(expected, atLine: 5, ignoringExtraLines: true))
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
    expect(actual).to(equalLineByLine(expected, atLine: 5, ignoringExtraLines: true))
  }

  // MARK: - Selections

  func test__render_selections__givenNilDirectSelections_doesNotRenderSelections() throws {
    // given
    let type = GraphQLObjectType.mock("Animal")

    let field = IR.EntityField(
      .mock(),
      selectionSet: .init(
        entity: .init(
          rootTypePath: [type],
          fieldPath: ["query", "allAnimals"]
        ),
        parentType: type,
        typePath: [.descriptor(forType: type, givenAllTypesInSchema: .init([type]))],
        mergedSelectionsOnly: true
      )
    )

    let result = CompilationResult.emptyMockObject()
    result.referencedTypes = [type]

    let schema = IR.mock(compilationResult: result).schema

    let expected = """
      public static var __parentType: ParentType { .Object(TestSchema.Animal.self) }

    """

    // when
    subject = SelectionSetTemplate(schema: schema)

    let actual = subject.render(field: field)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 5, ignoringExtraLines: true))
  }

  // MARK: Selections - Fields

  func test__render_selections__givenFieldSelections_rendersAllFieldSelections() throws {
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
      public static var selections: [Selection] { [
        .field("string", String.self),
        .field("string_optional", String?.self),
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
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
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
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
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
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
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
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

}

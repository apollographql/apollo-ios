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

  func buildSubjectAndOperation(named operationName: String = "TestOperation") throws {
    ir = try .mock(schema: schemaSDL, document: document)
    let operationDefinition = try XCTUnwrap(ir.compilationResult[operation: operationName])
    operation = ir.build(operation: operationDefinition)
    subject = SelectionSetTemplate(schema: ir.schema, mutable: true)
  }

  // MARK: - Tests

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
    expect(actual).to(equalLineByLine(expected, atLine: 14, ignoringExtraLines: true))
  }
}

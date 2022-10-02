import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class SelectionSetTemplate_RenderOperation_Tests: XCTestCase {

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
    subject = SelectionSetTemplate(
      schema: ir.schema,
      config: ApolloCodegen.ConfigurationContext(config: .mock())
    )
  }

  // MARK: - Tests

  func test__render__givenOperationWithName_rendersDeclaration() throws {
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
    public struct Data: TestSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { TestSchema.Objects.Query }
    """

    // when
    try buildSubjectAndOperation()
    let actual = subject.render(for: operation)

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
    expect(String(actual.reversed())).to(equalLineByLine("}", ignoringExtraLines: true))
  }

}

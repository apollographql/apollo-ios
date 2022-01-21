import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

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

  func test__render__givenOperationWithName_rendersDeclarationWithName() throws {
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
      public let data: ResponseDict
      public init(data: ResponseDict) { self.data = data }

      public static var __parentType: ParentType { .Object(TestSchema.Query.self) }
    """

    // when
    try buildSubjectAndOperation()
    let actual = subject.render(for: operation)

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

}

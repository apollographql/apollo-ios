import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloTestSupport
import ApolloCodegenTestSupport
import ApolloAPI
import ApolloUtils

class IRSelectionSet_IncludeSkip_Tests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var operation: CompilationResult.OperationDefinition!
  var subject: IR.EntityField!

  var schema: IR.Schema { ir.schema }

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

  // MARK: = Helpers

  func buildSubjectRootField() throws {
    ir = try .mock(schema: schemaSDL, document: document)
    operation = try XCTUnwrap(ir.compilationResult.operations.first)

    (subject, _) = IR.RootFieldBuilder.buildRootEntityField(
      forRootField: .mock(
        "query",
        type: .nonNull(.entity(operation.rootType)),
        selectionSet: operation.selectionSet
      ),
      onRootEntity: IR.Entity(
        rootTypePath: LinkedList(operation.rootType),
        fieldPath: ResponsePath("query")
      ),
      inSchema: ir.schema
    )
  }

  func test__selections__givenIncludeIfVariable_onField_createsSelectionWithInclusionCondition() throws {
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
    query Test($a: Boolean!) {
      allAnimals {
        species @include(if: $a)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    let expected: [IR.InclusionCondition] = [.include("a")]

    // then
    expect(actual?.inclusionConditions).to(equal(expected))
  }
}

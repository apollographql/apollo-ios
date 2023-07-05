import Foundation
import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib

class IRInputObjectTests: XCTestCase {

  var subject: GraphQLInputObjectType!
  var schemaSDL: String!
  var document: String!

  override func tearDown() {
    subject = nil
    schemaSDL = nil
    document = nil

    super.tearDown()
  }

  // MARK: - Helpers

  func buildSubject() throws {
    let ir: IR = try .mock(schema: schemaSDL, document: document)
    subject = ir.schema.referencedTypes.inputObjects.first!
  }

  // MARK: - Tests

  func test__compileInputObject__givenNestedInputObjectParameterWithDefaultValue_compilesInputTypeWithDefaultValue() throws {
    // given
    schemaSDL = """
    type Query {
      exampleQuery(input: Input!): String!
    }

    input ChildInput {
        a: String
        b: String
        c: String
      }

    input Input {
      child: ChildInput = { a: "a", b: "b", c: "c" }
    }
    """

    document = """
    query TestOperation($input: Input!) {
      exampleQuery(input: $input)
    }
    """

    // when
    try buildSubject()
    let childField = subject.fields["child"]

    let expectedDefaultValue = GraphQLValue.object([
      "a": .string("a"),
      "b": .string("b"),
      "c": .string("c")
    ])

    // then
    expect(childField?.defaultValue).to(equal(expectedDefaultValue))
  }

}

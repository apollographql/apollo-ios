import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class SchemaTypeFieldsTemplateTests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var subject: SchemaTypeFieldsTemplate!

  var schema: IR.Schema { ir.schema }

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    schemaSDL = nil
    document = nil
    ir = nil
    subject = nil
    super.tearDown()
  }

  // MARK: - Helpers

  func buildSubject() throws {
    ir = try .mock(schema: schemaSDL, document: document)

    for operation in ir.compilationResult.operations {
      _ = ir.build(operation: operation)
    }

    subject = SchemaTypeFieldsTemplate(ir: ir)
  }


  // MARK: Field Accessor Tests

  #warning("TODO: fields with arguments")

  func test__render__givenReferencedFields_rendersReferencedFields() throws {
    // given
    schemaSDL = """
    type Query {
      dog: Dog!
    }

    type Dog {
      a: String
      b: String
      c: String
    }
    """

    document = """
    query Test {
      dog {
        a
        b
      }
    }
    """

    let expected =
    """
    @Field("a") public var a: String?
    @Field("b") public var b: String?
    """

    // when
    try buildSubject()

    let Dog = try schema[object: "Dog"].xctUnwrapped()

    let actual = subject.render(type: Dog).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenReferencedField_nonNull_rendersFieldAsOptional() throws {
    // given
    schemaSDL = """
    type Query {
      dog: Dog!
    }

    type Dog {
      a: String!
    }
    """

    document = """
    query Test {
      dog {
        a
      }
    }
    """

    let expected =
    """
    @Field("a") public var a: String?
    """

    // when
    try buildSubject()

    let Dog = try schema[object: "Dog"].xctUnwrapped()

    let actual = subject.render(type: Dog).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

}

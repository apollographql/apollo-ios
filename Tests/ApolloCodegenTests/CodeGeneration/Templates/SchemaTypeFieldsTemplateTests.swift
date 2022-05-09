import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class SchemaTypeFieldsTemplateTests: XCTestCase {

  // MARK: Field Accessor Tests

  #warning("TODO: fields with arguments")

  func test__render__givenFieldsOnObject_rendersReferencedFields() throws {
    // given
    let fields: [GraphQLField] = [
      .mock("a", type: .string()),
      .mock("b", type: .string()),
    ]

    let expected =
    """
    @Field("a") public var a: String?
    @Field("b") public var b: String?
    """

    // when
    let actual = SchemaTypeFieldsTemplate.render(fields: fields, schemaName: "Schema").description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenFieldOnObject_nonNull_rendersFieldAsOptional() throws {
    // given
    let fields: [GraphQLField] = [
      .mock("a", type: .nonNull(.string())),
    ]

    let expected =
    """
    @Field("a") public var a: String?
    """

    // when
    let actual = SchemaTypeFieldsTemplate.render(fields: fields, schemaName: "Schema").description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenFieldOnObject_customScalar_rendersFieldWithSchemaName() throws {
    // given
    let fields: [GraphQLField] = [
      .mock("a", type: .nonNull(.scalar(.mock(name: "CustomScalar")))),
    ]

    let expected =
    """
    @Field("a") public var a: Schema.CustomScalar?
    """

    // when
    let actual = SchemaTypeFieldsTemplate.render(fields: fields, schemaName: "Schema").description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

}

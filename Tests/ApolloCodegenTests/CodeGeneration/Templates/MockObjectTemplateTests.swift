import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class MockObjectTemplateTests: XCTestCase {

  var ir: IR!
  var subject: MockObjectTemplate!

  override func tearDown() {
    subject = nil
    ir = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(name: String = "Dog", interfaces: [GraphQLInterfaceType] = []) {
    ir = IR.mock(compilationResult: .mock())

    subject = MockObjectTemplate(
      graphqlObject: GraphQLObjectType.mock(name, interfaces: interfaces),
      ir: ir
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate tests

  func test_render_givenSchemaType_generatesSwiftClassExtension() {
    // given
    buildSubject(name: "Dog")

    let expected = """
    public extension Dog: Mockable {
      public static let __mockFields = MockFields()

      public struct MockFields {
      }
    }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Class Definition Tests

  func test_render_givenSchemaType_generatesSwiftClassExtensionCorrectlyCased() {
    // given
    buildSubject(name: "dog")

    let expected = """
    public extension Dog: Mockable {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Field Accessor Tests

  func test_render_givenSchemaType_generatesFieldAccessors() {
    // given
    buildSubject()

    let Cat: GraphQLType = .entity(.mock("Cat"))

    subject.graphqlObject.fields = [
      "string": .mock("string", type: .nonNull(.string())),
      "customScalar": .mock("customScalar", type: .nonNull(.scalar(.mock(name: "CustomScalar")))),
      "optionalString": .mock("optionalString", type: .string()),
      "object": .mock("object", type: Cat),
      "objectList": .mock("objectList", type: .list(.nonNull(Cat))),
      "objectNestedList": .mock("objectNestedList", type: .list(.nonNull(.list(.nonNull(Cat))))),
      "objectOptionalList": .mock("objectOptionalList", type: .list(Cat)),
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expected = """
      public struct MockFields {
        @Field<TestSchema.CustomScalar>("customScalar") public var customScalar
        @Field<Cat>("object") public var object
        @Field<[Cat]>("objectList") public var objectList
        @Field<[[Cat]]>("objectNestedList") public var objectNestedList
        @Field<[Cat?]>("objectOptionalList") public var objectOptionalList
        @Field<String>("optionalString") public var optionalString
        @Field<String>("string") public var string
      }
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

}

import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class ObjectTemplateTests: XCTestCase {

  var ir: IR!
  var subject: ObjectTemplate!

  override func tearDown() {
    subject = nil
    ir = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(name: String = "Dog", interfaces: [GraphQLInterfaceType] = []) {
    ir = IR.mock(compilationResult: .mock())

    subject = ObjectTemplate(
      graphqlObject: GraphQLObjectType.mock(name, interfaces: interfaces),
      ir: ir
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate tests

  func test_render_generatesClosingBrace() {
    // given
    buildSubject()

    // when
    let actual = renderSubject()

    // then
    expect(String(actual.reversed())).to(equalLineByLine("}", ignoringExtraLines: true))
  }

  // MARK: Class Definition Tests

  func test_render_givenSchemaType_generatesSwiftClassDefinitionCorrectlyCased() {
    // given
    buildSubject(name: "dog")

    let expected = """
    public final class Dog: Object {
      override public class var __typename: StaticString { "Dog" }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }  

  // MARK: Metadata Tests

  func test_render_givenSchemaType_generatesTypeMetadata() {
    // given
    buildSubject(interfaces: [
        GraphQLInterfaceType.mock("Animal", fields: ["species": GraphQLField.mock("species", type: .scalar(.string()))]),
        GraphQLInterfaceType.mock("Pet", fields: ["name": GraphQLField.mock("name", type: .scalar(.string()))])
      ]
    )

    let expected = """
      override public class var __metadata: Metadata { _metadata }
      private static let _metadata: Metadata = Metadata(
        implements: [
          Animal.self,
          Pet.self
        ]
      )
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  func test_render_givenNoImplementedInterfacesOrCovariantFields_doesNotGenerateTypeMetadata() {
    // given
    buildSubject()

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine("}", atLine: 4, ignoringExtraLines: false))
  }

  func test__render__givenObject_withFieldOfDifferentTypeThanImplementedInterface_generatesCovariantFieldsInMetadata() throws {
    // given
    let schemaSDL = """
    type Query {
      animal: Animal!
      dog: Dog!
    }

    interface Animal {
      a: Animal
      b: String!
    }

    type Dog implements Animal {
      a: Dog
      b: String!
    }
    """

    let document = """
    query Test1 {
      dog {
        a {
          b
        }
      }
    }
    """

    let expected = """
      override public class var __metadata: Metadata { _metadata }
      private static let _metadata: Metadata = Metadata(
        implements: [
          Animal.self
        ],
        covariantFields: [
          "a": Dog.self
        ]
      )
    """

    // when
    ir = try .mock(schema: schemaSDL, document: document)

    for operation in ir.compilationResult.operations {
      _ = ir.build(operation: operation)
    }

    let Dog = try ir.schema[object: "Dog"].xctUnwrapped()

    subject = ObjectTemplate(graphqlObject: Dog, ir: ir)

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  // MARK: Field Accessor Tests

  func test_render_givenSchemaType_generatesFieldAccessors() {
    // given
    buildSubject()

    subject.graphqlObject.fields = ["fieldA": .mock("fieldA", type: .string())]

    ir.fieldCollector.add(field: .mock("fieldA", type: .string()),
                          to: subject.graphqlObject)

    let expected = """
      @Field("fieldA") public var fieldA: String?
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

}

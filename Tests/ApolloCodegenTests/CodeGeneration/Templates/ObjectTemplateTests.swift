import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class ObjectTemplateTests: XCTestCase {

  var subject: ObjectTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(name: String = "Dog", interfaces: [GraphQLInterfaceType] = []) {
    subject = ObjectTemplate(
      graphqlObject: GraphQLObjectType.mock(name, interfaces: interfaces)
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

  func test_render_givenSchemaTypeImplementsInterfaces_generatesImplementedInterfaces() {
    // given
    buildSubject(interfaces: [
        GraphQLInterfaceType.mock("Animal", fields: ["species": GraphQLField.mock("species", type: .scalar(.string()))]),
        GraphQLInterfaceType.mock("Pet", fields: ["name": GraphQLField.mock("name", type: .scalar(.string()))])
      ]
    )

    let expected = """
      override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
      private static let _implementedInterfaces: [Interface.Type]? = [
        Animal.self,
        Pet.self
      ]
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
    expect(actual).to(equalLineByLine("}", atLine: 3, ignoringExtraLines: false))
  }

}

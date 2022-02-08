import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class ObjectTemplateTests: XCTestCase {
  var subject: ObjectTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  private func buildSubject(name: String = "Dog", interfaces: [GraphQLInterfaceType] = []) {
    subject = ObjectTemplate(
      graphqlObject: GraphQLObjectType.mock(name, interfaces: interfaces)
    )
  }

  // MARK: Boilerplate tests

  func test_render_generatesHeaderComment() {
    // given
    buildSubject()

    let expected = """
    // @generated
    // This file was automatically generated and should not be edited.

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_generatesImportStatement() {
    // given
    buildSubject()

    let expected = """
    import ApolloAPI

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  func test_render_generatesClosingBrace() {
    // given
    buildSubject()

    // when
    let actual = subject.render()

    // then
    expect(String(actual.reversed())).to(equalLineByLine("}", ignoringExtraLines: true))
  }

  // MARK: Class Definition Tests

  func test_render_givenSchemaType_generatesSwiftClassDefinition() {
    // given
    buildSubject()

    let expected = """
    public final class Dog: Object {
      override public class var __typename: String { "Dog" }

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
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
      private static let _metadata: Metadata = Metadata(implements: [
        Animal.self,
        Pet.self
      ])
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }
}

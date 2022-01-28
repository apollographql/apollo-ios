import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class TypeTemplateTests: XCTestCase {

  // MARK: Boilerplate tests

  func test_boilerplate_givenSchemaType_generatesImportStatement() {
    // given
    let graphqlObject = GraphQLObjectType.mock("Dog")

    let expected = """
    import ApolloAPI

    """

    // when
    let actual = TypeTemplate(graphqlObject: graphqlObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_boilerplate_givenSchemaType_generatesSwiftClassDefinition() {
    // given
    let graphqlObject = GraphQLObjectType.mock("Dog")

    let expected = """
    public final class Dog: Object {
      override public class var __typename: String { "Dog" }

    """

    // when
    let actual = TypeTemplate(graphqlObject: graphqlObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3, ignoringExtraLines: true))
  }

  func test_boilerplate_givenSchemaType_generatesClosingBrace() {
    // given
    let graphqlObject = GraphQLObjectType.mock("Dog")

    // when
    let actual = TypeTemplate(graphqlObject: graphqlObject).render()

    // then
    expect(String(actual.reversed())).to(equalLineByLine("}", ignoringExtraLines: true))
  }

  // MARK: Metadata Tests

  func test_render_givenSchemaType_generatesTypeMetadata() {
    // given
    let graphqlObject = GraphQLObjectType.mock(
      "Dog",
      interfaces: [
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
    let actual = TypeTemplate(graphqlObject: graphqlObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }
}

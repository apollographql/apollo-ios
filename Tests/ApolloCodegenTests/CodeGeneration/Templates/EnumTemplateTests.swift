import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class EnumTemplateTests: XCTestCase {

  func test_render_boilerplate_givenInputObject_generatesImportStatement() {
    let graphqlEnum = GraphQLEnumType.mock(name: "TestEnum", values: ["ONE", "TWO"])
    let template = EnumTemplate(graphqlEnum: graphqlEnum)

    let expected = """
    import ApolloAPI

    """

    // when
    let actual = template.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenSchemaEnum_generatesSwiftEnum() throws {
    // given
    let graphqlEnum = GraphQLEnumType.mock(name: "TestEnum", values: ["ONE", "TWO"])
    let template = EnumTemplate(graphqlEnum: graphqlEnum)

    let expected = """
    public enum TestEnum: String, EnumType {
      case ONE
      case TWO
    }
    """

    // when
    let actual = template.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3))
  }

  func test_render_givenSchemaEnum_generatesSwiftEnumRespectingCase() throws {
    // given
    let graphqlEnum = GraphQLEnumType.mock(
      name: "CasedEnum",
      values: ["lower", "UPPER", "Capitalized"]
    )
    let template = EnumTemplate(graphqlEnum: graphqlEnum)

    let expected = """
    public enum CasedEnum: String, EnumType {
      case lower
      case UPPER
      case Capitalized
    }
    """

    // when
    let actual = template.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3))
  }
}

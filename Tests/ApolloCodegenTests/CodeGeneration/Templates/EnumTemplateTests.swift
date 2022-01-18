import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class EnumTemplateTests: XCTestCase {
  func test_render_givenSchemaEnum_generatesSwiftEnum() throws {
    // given
    let schema = IR.Schema(name: "TestSchema", referencedTypes: .init([
      GraphQLEnumType.mock(name: "TestEnum", values: ["ONE", "TWO"])
    ]))
    let graphqlEnum = try schema[enum: "TestEnum"].xctUnwrapped()
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
    expect(actual).to(equalLineByLine(expected))
  }

  func test_render_givenSchemaEnum_generatesSwiftEnumRespectingCase() throws {
    // given
    let schema = IR.Schema(name: "TestSchema", referencedTypes: .init([
      GraphQLEnumType.mock(name: "CasedEnum", values: ["lower", "UPPER", "Capitalized"])
    ]))
    let graphqlEnum = try schema[enum: "CasedEnum"].xctUnwrapped()
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
    expect(actual).to(equalLineByLine(expected))
  }
}

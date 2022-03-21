import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class EnumTemplateTests: XCTestCase {
  var subject: EnumTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  private func buildSubject(name: String = "TestEnum", values: [String] = ["ONE", "TWO"]) {
    subject = EnumTemplate(
      graphqlEnum: GraphQLEnumType.mock(name: name, values: values)
    )
  }

  // MARK: Enum Tests

  func test_render_givenSchemaEnum_generatesSwiftEnum() throws {
    // given
    buildSubject()

    let expected = """
    public enum TestEnum: String, EnumType {
      case ONE
      case TWO
    }
    """

    // when
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: Casing Tests

  func test_render_givenSchemaEnum_generatesSwiftEnumNameFirstUppercased() throws {
    // given
    buildSubject(name: "testEnum")

    let expected = """
    public enum TestEnum: String, EnumType {
    """

    // when
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenSchemaEnum_generatesSwiftEnumRespectingCase() throws {
    // given
    buildSubject(name: "CasedEnum", values: ["lower", "UPPER", "Capitalized"])

    let expected = """
    public enum CasedEnum: String, EnumType {
      case lower
      case UPPER
      case Capitalized
    }
    """

    // when
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

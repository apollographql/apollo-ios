import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class EnumTemplateTests: XCTestCase {
  var subject: EnumTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(name: String = "testEnum", values: [String] = ["ONE", "TWO"]) {
    subject = EnumTemplate(
      graphqlEnum: GraphQLEnumType.mock(name: name, values: values)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
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
    let actual = renderSubject()

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
    let actual = renderSubject()

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
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

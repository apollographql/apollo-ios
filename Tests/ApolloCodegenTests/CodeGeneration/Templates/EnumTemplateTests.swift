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

  private func buildSubject(name: String, values: [String]) {
    subject = EnumTemplate(
      graphqlEnum: GraphQLEnumType.mock(name: name, values: values)
    )
  }

  // MARK: Boilerplate Tests

  func test_render_generatesHeaderComment() {
    // given
    buildSubject(name: "TestEnum", values: ["ONE", "TWO"])

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
    buildSubject(name: "TestEnum", values: ["ONE", "TWO"])

    let expected = """
    import ApolloAPI

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  // MARK: Enum Casing Tests

  func test_render_givenSchemaEnum_generatesSwiftEnumNameFirstUppercased() throws {
    // given
    buildSubject(name: "testEnum", values: ["ONE", "TWO"])

    let expected = """
    public enum TestEnum: String, EnumType {
      case ONE
      case TWO
    }
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6))
  }

  func test_render_givenSchemaEnum_generatesSwiftEnum() throws {
    // given
    buildSubject(name: "TestEnum", values: ["ONE", "TWO"])

    let expected = """
    public enum TestEnum: String, EnumType {
      case ONE
      case TWO
    }
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6))
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
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6))
  }
}

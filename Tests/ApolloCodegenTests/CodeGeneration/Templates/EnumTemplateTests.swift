import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers
import ApolloUtils

class EnumTemplateTests: XCTestCase {
  var subject: EnumTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Helpers

  /// Convenience function to build the `EnumTemplate` `subject`.
  ///
  /// - Parameters:
  ///   - name: Enum definition name.
  ///   - values: A tuple that combines the value name and optional deprecation reason.
  ///   - config: Code generation configuration.
  private func buildSubject(
    name: String = "testEnum",
    values: [(String, String?)] = [("ONE", nil), ("TWO", nil)],
    config: ApolloCodegenConfiguration = ApolloCodegenConfiguration.mock()
  ) {
    subject = EnumTemplate(
      graphqlEnum: GraphQLEnumType.mock(
        name: name,
        values: values.map({ GraphQLEnumValue.mock(name: $0.0, deprecationReason: $0.1) })
      ),
      config: ReferenceWrapped(value: config)
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
    buildSubject(
      name: "CasedEnum",
      values: [
        ("lower", nil),
        ("UPPER", nil),
        ("Capitalized", nil)
      ]
    )

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

  // MARK: Deprecation Tests

  func test__render__givenOption_deprecatedEnumCasesIncluded_whenEnumValueIsDeprecated_shouldGenerateEnumCase() throws {
    // given / when
    buildSubject(
      values: [
        ("ONE", nil),
        ("TWO", "Deprecated for tests"),
        ("THREE", nil)
      ],
      config: ApolloCodegenConfiguration.mock(options: .init(deprecatedEnumCases: .include))
    )

    let expected = """
    public enum TestEnum: String, EnumType {
      case ONE
      case TWO
      case THREE
    }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenOption_deprecatedEnumCasesExcluded_whenEnumValueIsDeprecated_shouldNotGenerateEnumCase() throws {
    // given / when
    buildSubject(
      values: [
        ("ONE", "Deprecated for tests"),
        ("TWO", nil),
        ("THREE", "Deprecated for tests")
      ],
      config: ApolloCodegenConfiguration.mock(options: .init(deprecatedEnumCases: .exclude))
    )

    let expected = """
    public enum TestEnum: String, EnumType {
      case TWO
    }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

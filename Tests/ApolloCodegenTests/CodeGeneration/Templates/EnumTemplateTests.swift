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
    name: String = "TestEnum",
    documentation: String? = nil,
    values: [(String, String?, documentation: String?)] = [("ONE", nil, nil), ("TWO", nil, nil)],
    config: ApolloCodegenConfiguration = ApolloCodegenConfiguration.mock()
  ) {
    subject = EnumTemplate(
      graphqlEnum: GraphQLEnumType.mock(
        name: name,
        values: values.map({
          GraphQLEnumValue.mock(
            name: $0.0,
            deprecationReason: $0.1,
            documentation: $0.documentation
          )
        }),
        documentation: documentation
      ),
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Enum Tests

  func test_render_givenModuleType_swiftPackageManager_generatesSwiftEnum_withPublicModifier() {
    // given
    buildSubject(config: .mock(.swiftPackageManager))

    let expected = """
    public enum TestEnum: String, EnumType {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_other_generatesSwiftEnum_withPublicModifier() {
    // given
    buildSubject(config: .mock(.other))

    let expected = """
    public enum TestEnum: String, EnumType {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_embeddedInTarget_generatesSwiftEnum_noPublicModifier() {
    // given
    buildSubject(config: .mock(.embeddedInTarget(name: "TestTarget")))

    let expected = """
    enum TestEnum: String, EnumType {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Casing Tests

  func test_render_givenSchemaEnum_generatesSwiftEnumNameFirstUppercased() throws {
    // given
    buildSubject(name: "anEnum")

    let expected = """
    enum AnEnum: String, EnumType {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenSchemaEnum_generatesSwiftEnumRespectingValueCasing() throws {
    // given
    buildSubject(
      name: "casedEnum",
      values: [
        ("lower", nil, nil),
        ("UPPER", nil, nil),
        ("Capitalized", nil, nil)
      ]
    )

    let expected = """
    enum CasedEnum: String, EnumType {
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

  func test__render__givenOption_deprecatedInclude_warningsExclude_whenDeprecation_shouldGenerateEnumCase_noAvailableAttribute() throws {
    // given / when
    buildSubject(
      values: [
        ("ONE", nil, nil),
        ("TWO", "Deprecated for tests", nil),
        ("THREE", nil, nil)
      ],
      config: ApolloCodegenConfiguration.mock(options: .init(
        deprecatedEnumCases: .include,
        warningsOnDeprecatedUsage: .exclude
      ))
    )

    let expected = """
    enum TestEnum: String, EnumType {
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

  func test__render__givenOption_deprecatedInclude_warningsInclude_whenDeprecation_shouldGenerateEnumCase_withAvailableAttribute() throws {
    // given / when
    buildSubject(
      values: [
        ("ONE", nil, nil),
        ("TWO", "Deprecated for tests", nil),
        ("THREE", nil, nil)
      ],
      config: ApolloCodegenConfiguration.mock(options: .init(
        deprecatedEnumCases: .include,
        warningsOnDeprecatedUsage: .include
      ))
    )

    let expected = """
    enum TestEnum: String, EnumType {
      case ONE
      @available(*, deprecated, message: "Deprecated for tests")
      case TWO
      case THREE
    }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenOption_deprecatedExclude_warningsInclude_whenDeprecation_shouldNotGenerateEnumCase() throws {
    // given / when
    buildSubject(
      values: [
        ("ONE", "Deprecated for tests", nil),
        ("TWO", nil, nil),
        ("THREE", "Deprecated for tests", nil)
      ],
      config: ApolloCodegenConfiguration.mock(options: .init(
        deprecatedEnumCases: .exclude,
        warningsOnDeprecatedUsage: .include
      ))
    )

    let expected = """
    enum TestEnum: String, EnumType {
      case TWO
    }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenOption_deprecatedExclude_warningsExclude_whenDeprecation_shouldNotGenerateEnumCase() throws {
    // given / when
    buildSubject(
      values: [
        ("ONE", "Deprecated for tests", nil),
        ("TWO", nil, nil),
        ("THREE", "Deprecated for tests", nil)
      ],
      config: ApolloCodegenConfiguration.mock(options: .init(
        deprecatedEnumCases: .exclude,
        warningsOnDeprecatedUsage: .exclude
      ))
    )

    let expected = """
    enum TestEnum: String, EnumType {
      case TWO
    }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: Documentation Tests

  func test__render__givenSchemaDocumentation_include_hasDocumentation_shouldGenerateDocumentationComment() throws {
    // given
    let documentation = "This is some great documentation!"
    buildSubject(
      documentation: documentation,
      values: [
        ("ONE", "Deprecated for tests", "Doc: One"),
        ("TWO", nil, "Doc: Two"),
        ("THREE", "Deprecated for tests", nil)
      ],
      config: ApolloCodegenConfiguration.mock(options: .init(
        deprecatedEnumCases: .include,
        schemaDocumentation: .include,
        warningsOnDeprecatedUsage: .include
      ))
    )

    let expected = """
    /// \(documentation)
    enum TestEnum: String, EnumType {
      /// Doc: One
      @available(*, deprecated, message: "Deprecated for tests")
      case ONE
      /// Doc: Two
      case TWO
      @available(*, deprecated, message: "Deprecated for tests")
      case THREE
    }
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected))
  }

  func test__render__givenSchemaDocumentation_include_warningsOnDeprecation_exclude_hasDocumentation_shouldGenerateDocumentationComment() throws {
    // given
    let documentation = "This is some great documentation!"
    buildSubject(
      documentation: documentation,
      values: [
        ("ONE", "Deprecated for tests", "Doc: One"),
        ("TWO", nil, "Doc: Two"),
        ("THREE", "Deprecated for tests", nil)
      ],
      config: ApolloCodegenConfiguration.mock(options: .init(
        deprecatedEnumCases: .include,
        schemaDocumentation: .include,
        warningsOnDeprecatedUsage: .exclude
      ))
    )

    let expected = """
    /// \(documentation)
    enum TestEnum: String, EnumType {
      /// Doc: One
      case ONE
      /// Doc: Two
      case TWO
      case THREE
    }
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected))
  }

  func test__render__givenSchemaDocumentation_exclude_hasDocumentation_shouldNotGenerateDocumentationComment() throws {
    // given
    let documentation = "This is some great documentation!"
    buildSubject(
      documentation: documentation,
      values: [
        ("ONE", "Deprecated for tests", "Doc: One"),
        ("TWO", nil, "Doc: Two"),
        ("THREE", "Deprecated for tests", nil)
      ],
      config: ApolloCodegenConfiguration.mock(options: .init(
        deprecatedEnumCases: .include,
        schemaDocumentation: .exclude,
        warningsOnDeprecatedUsage: .exclude
      ))
    )

    let expected = """
    enum TestEnum: String, EnumType {
      case ONE
      case TWO
      case THREE
    }
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected))
  }
}

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

  func test_render_givenCaseConversionStrategy_camelCase_generatesSwiftEnum_convertedToCamelCase() {
    // given
    buildSubject(
      name: "casedEnum",
      values: [
        ("lower", nil, nil),
        ("UPPER", nil, nil),
        ("Capitalized", nil, nil),
        ("associatedtype", nil, nil),
        ("class", nil, nil),
        ("deinit", nil, nil),
        ("enum", nil, nil),
        ("extension", nil, nil),
        ("fileprivate", nil, nil),
        ("func", nil, nil),
        ("import", nil, nil),
        ("init", nil, nil),
        ("inout", nil, nil),
        ("internal", nil, nil),
        ("let", nil, nil),
        ("operator", nil, nil),
        ("private", nil, nil),
        ("precedencegroup", nil, nil),
        ("protocol", nil, nil),
        ("Protocol", nil, nil),
        ("public", nil, nil),
        ("rethrows", nil, nil),
        ("static", nil, nil),
        ("struct", nil, nil),
        ("subscript", nil, nil),
        ("typealias", nil, nil),
        ("var", nil, nil),
        ("break", nil, nil),
        ("case", nil, nil),
        ("catch", nil, nil),
        ("continue", nil, nil),
        ("default", nil, nil),
        ("defer", nil, nil),
        ("do", nil, nil),
        ("else", nil, nil),
        ("fallthrough", nil, nil),
        ("guard", nil, nil),
        ("if", nil, nil),
        ("in", nil, nil),
        ("repeat", nil, nil),
        ("return", nil, nil),
        ("throw", nil, nil),
        ("switch", nil, nil),
        ("where", nil, nil),
        ("while", nil, nil),
        ("as", nil, nil),
        ("false", nil, nil),
        ("is", nil, nil),
        ("nil", nil, nil),
        ("self", nil, nil),
        ("Self", nil, nil),
        ("super", nil, nil),
        ("throws", nil, nil),
        ("true", nil, nil),
        ("try", nil, nil),
      ]
    )

    let expected = """
    enum CasedEnum: String, EnumType {
      case lower = "lower"
      case upper = "UPPER"
      case capitalized = "Capitalized"
      case `associatedtype` = "associatedtype"
      case `class` = "class"
      case `deinit` = "deinit"
      case `enum` = "enum"
      case `extension` = "extension"
      case `fileprivate` = "fileprivate"
      case `func` = "func"
      case `import` = "import"
      case `init` = "init"
      case `inout` = "inout"
      case `internal` = "internal"
      case `let` = "let"
      case `operator` = "operator"
      case `private` = "private"
      case `precedencegroup` = "precedencegroup"
      case `protocol` = "protocol"
      case `protocol` = "Protocol"
      case `public` = "public"
      case `rethrows` = "rethrows"
      case `static` = "static"
      case `struct` = "struct"
      case `subscript` = "subscript"
      case `typealias` = "typealias"
      case `var` = "var"
      case `break` = "break"
      case `case` = "case"
      case `catch` = "catch"
      case `continue` = "continue"
      case `default` = "default"
      case `defer` = "defer"
      case `do` = "do"
      case `else` = "else"
      case `fallthrough` = "fallthrough"
      case `guard` = "guard"
      case `if` = "if"
      case `in` = "in"
      case `repeat` = "repeat"
      case `return` = "return"
      case `throw` = "throw"
      case `switch` = "switch"
      case `where` = "where"
      case `while` = "while"
      case `as` = "as"
      case `false` = "false"
      case `is` = "is"
      case `nil` = "nil"
      case `self` = "self"
      case `self` = "Self"
      case `super` = "super"
      case `throws` = "throws"
      case `true` = "true"
      case `try` = "try"
    }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test_render_givenSchemaEnum_noneConveersionStrategies_generatesSwiftEnumRespectingValueCasing() throws {
    // given
    buildSubject(
      name: "casedEnum",
      values: [
        ("lower", nil, nil),
        ("UPPER", nil, nil),
        ("Capitalized", nil, nil),
        ("associatedtype", nil, nil),
        ("class", nil, nil),
        ("deinit", nil, nil),
        ("enum", nil, nil),
        ("extension", nil, nil),
        ("fileprivate", nil, nil),
        ("func", nil, nil),
        ("import", nil, nil),
        ("init", nil, nil),
        ("inout", nil, nil),
        ("internal", nil, nil),
        ("let", nil, nil),
        ("operator", nil, nil),
        ("private", nil, nil),
        ("precedencegroup", nil, nil),
        ("protocol", nil, nil),
        ("Protocol", nil, nil),
        ("public", nil, nil),
        ("rethrows", nil, nil),
        ("static", nil, nil),
        ("struct", nil, nil),
        ("subscript", nil, nil),
        ("typealias", nil, nil),
        ("var", nil, nil),
        ("break", nil, nil),
        ("case", nil, nil),
        ("catch", nil, nil),
        ("continue", nil, nil),
        ("default", nil, nil),
        ("defer", nil, nil),
        ("do", nil, nil),
        ("else", nil, nil),
        ("fallthrough", nil, nil),
        ("guard", nil, nil),
        ("if", nil, nil),
        ("in", nil, nil),
        ("repeat", nil, nil),
        ("return", nil, nil),
        ("throw", nil, nil),
        ("switch", nil, nil),
        ("where", nil, nil),
        ("while", nil, nil),
        ("as", nil, nil),
        ("false", nil, nil),
        ("is", nil, nil),
        ("nil", nil, nil),
        ("self", nil, nil),
        ("Self", nil, nil),
        ("super", nil, nil),
        ("throws", nil, nil),
        ("true", nil, nil),
        ("try", nil, nil),
      ],
      config: .mock(
        options: .init(conversionStrategies: .init(enumCases: .none))
      )
    )

    let expected = """
    enum CasedEnum: String, EnumType {
      case lower
      case UPPER
      case Capitalized
      case `associatedtype`
      case `class`
      case `deinit`
      case `enum`
      case `extension`
      case `fileprivate`
      case `func`
      case `import`
      case `init`
      case `inout`
      case `internal`
      case `let`
      case `operator`
      case `private`
      case `precedencegroup`
      case `protocol`
      case `Protocol`
      case `public`
      case `rethrows`
      case `static`
      case `struct`
      case `subscript`
      case `typealias`
      case `var`
      case `break`
      case `case`
      case `catch`
      case `continue`
      case `default`
      case `defer`
      case `do`
      case `else`
      case `fallthrough`
      case `guard`
      case `if`
      case `in`
      case `repeat`
      case `return`
      case `throw`
      case `switch`
      case `where`
      case `while`
      case `as`
      case `false`
      case `is`
      case `nil`
      case `self`
      case `Self`
      case `super`
      case `throws`
      case `true`
      case `try`
    }
    
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: Deprecation Tests

  func test__render__givenOption_deprecatedInclude_warningsExclude_whenDeprecation_shouldGenerateEnumCase_withDeprecationComment() throws {
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
      case one = "ONE"
      /// **Deprecated**: Deprecated for tests
      case two = "TWO"
      case three = "THREE"
    }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenOption_deprecatedInclude_warningsInclude_whenDeprecation_shouldGenerateEnumCase_withDeprecationComment() throws {
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
      case one = "ONE"
      /// **Deprecated**: Deprecated for tests
      case two = "TWO"
      case three = "THREE"
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
      case two = "TWO"
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
      case two = "TWO"
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
      ///
      /// **Deprecated**: Deprecated for tests
      case one = "ONE"
      /// Doc: Two
      case two = "TWO"
      /// **Deprecated**: Deprecated for tests
      case three = "THREE"
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
      ///
      /// **Deprecated**: Deprecated for tests
      case one = "ONE"
      /// Doc: Two
      case two = "TWO"
      /// **Deprecated**: Deprecated for tests
      case three = "THREE"
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
      /// **Deprecated**: Deprecated for tests
      case one = "ONE"
      case two = "TWO"
      /// **Deprecated**: Deprecated for tests
      case three = "THREE"
    }
    
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected))
  }
}

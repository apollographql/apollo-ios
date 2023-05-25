import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class InterfaceTemplateTests: XCTestCase {
  var subject: InterfaceTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: - Helpers

  private func buildSubject(
    name: String = "Dog",
    documentation: String? = nil,
    config: ApolloCodegenConfiguration = .mock()
  ) {
    subject = InterfaceTemplate(
      graphqlInterface: GraphQLInterfaceType.mock(
        name,
        fields: [:],
        interfaces: [],
        documentation: documentation
      ),
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Casing Tests

  func test_render_givenSchemaInterface_generatesSwiftClassDefinitionCorrectlyCased() throws {
    // given
    buildSubject(name: "aDog")

    let expected = """
    static let ADog = Interface(name: "aDog")
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
      config: .mock(options: .init(schemaDocumentation: .include))
    )

    let expected = """
    /// \(documentation)
    static let Dog = Interface(name: "Dog")
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenSchemaDocumentation_exclude_hasDocumentation_shouldNotGenerateDocumentationComment() throws {
    // given
    // given
    let documentation = "This is some great documentation!"
    buildSubject(
      documentation: documentation,
      config: .mock(options: .init(schemaDocumentation: .exclude))
    )

    let expected = """
    static let Dog = Interface(name: "Dog")
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected, ignoringExtraLines: true))
  }
}

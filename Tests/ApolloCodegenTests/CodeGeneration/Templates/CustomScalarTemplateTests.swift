import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers
import ApolloAPI
import ApolloUtils

class CustomScalarTemplateTests: XCTestCase {
  var subject: CustomScalarTemplate!

  // MARK: Helpers

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  private func buildSubject(
    name: String = "MyCustomScalar",
    config: ApolloCodegenConfiguration = .mock()
  ) {
    subject = CustomScalarTemplate(
      graphqlScalar: GraphQLScalarType.mock(name: name),
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Casing Tests

  func test__render__givenCustomScalar_shouldGenerateTypealiasNameFirstUppercased() throws {
    // given
    buildSubject(name: "aCustomScalar")

    let expected = """
    typealias ACustomScalar = String
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected))
  }

  // MARK: Typealias Definition Tests

  func test__render__givenCustomScalar_shouldGenerateStringTypealias() throws {
    // given
    buildSubject()

    let expected = """
    typealias MyCustomScalar = String
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected))
  }

  func test_render_givenModuleType_swiftPackageManager_generatesTypealias_withPublicModifier() {
    // given
    buildSubject(config: .mock(.swiftPackageManager))

    let expected = """
    public typealias MyCustomScalar = String
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_other_generatesTypealias_withPublicModifier() {
    // given
    buildSubject(config: .mock(.other))

    let expected = """
    public typealias MyCustomScalar = String
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_embeddedInTarget_generatesTypealias_noPublicModifier() {
    // given
    buildSubject(config: .mock(.embeddedInTarget(name: "TestTarget")))

    let expected = """
    typealias MyCustomScalar = String
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }
}

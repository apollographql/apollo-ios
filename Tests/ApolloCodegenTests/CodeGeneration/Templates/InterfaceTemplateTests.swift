import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers
import ApolloUtils

class InterfaceTemplateTests: XCTestCase {
  var subject: InterfaceTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(
    name: String = "Dog",
    config: ApolloCodegenConfiguration = .mock()
  ) {
    subject = InterfaceTemplate(
      graphqlInterface: GraphQLInterfaceType.mock(name, fields: [:], interfaces: []),
      config: ReferenceWrapped(value: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Class Definition Tests

  func test_render_givenSchemaInterface_generatesSwiftClassDefinitionCorrectlyCased() throws {
    // given
    buildSubject(name: "aDog")

    let expected = """
    final class ADog: Interface { }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test_render_givenModuleType_swiftPackageManager_generatesSwiftClassDefinition_withPublicModifier() {
    // given
    buildSubject(config: .mock(.swiftPackageManager))

    let expected = """
    public final class Dog: Interface { }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_other_generatesSwiftClassDefinition_withPublicModifier_correctlyCased() {
    // given
    buildSubject(config: .mock(.other))

    let expected = """
    public final class Dog: Interface { }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_embeddedInTarget_generatesSwiftClassDefinition_noPublicModifier_correctlyCased() {
    // given
    buildSubject(config: .mock(.embeddedInTarget(name: "TestTarget")))

    let expected = """
    final class Dog: Interface { }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }
}

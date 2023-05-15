import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class SchemaConfigurationTemplateTests: XCTestCase {
  var subject: SchemaConfigurationTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: - Helpers

  private func buildSubject(
    name: String = "testSchema",
    config: ApolloCodegenConfiguration = ApolloCodegenConfiguration.mock(.swiftPackageManager)
  ) {
    subject = SchemaConfigurationTemplate(
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderTemplate() -> String {
    subject.template.description
  }

  private func renderDetachedTemplate() -> String? {
    subject.detachedTemplate?.description
  }

  // MARK: Header Tests

  func test__render_header__rendersEditableHeaderTemplateWithReason() throws {
    // given
    let expected = """
    // @generated
    // This file was automatically generated and can be edited to
    // provide custom configuration for a generated GraphQL schema.
    //
    // Any changes to this file will not be overwritten by future
    // code generation execution.

    """

    buildSubject()
    // when

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Boilerplate Tests

  func test__render__rendersTemplate() throws {
    // given
    let expected = """
    public enum SchemaConfiguration: ApolloAPI.SchemaConfiguration {
      public static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
        // Implement this function to configure cache key resolution for your schema types.
        return nil
      }
    }

    """

    buildSubject()
    // when

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 10, ignoringExtraLines: false))
  }

  // MARK: Access Level Tests

  func test__render__givenModuleEmbeddedInTarget_withPublicAccessModifier_rendersTemplate_withPublicAccess() throws {
    // given
    let expected = """
    enum SchemaConfiguration: ApolloAPI.SchemaConfiguration {
      public static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
        // Implement this function to configure cache key resolution for your schema types.
        return nil
      }
    }

    """

    buildSubject(config: .mock(.embeddedInTarget(name: "TestTarget", accessModifier: .public)))
    // when

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 10, ignoringExtraLines: false))
  }

  func test__render__givenModuleEmbeddedInTarget_withInternalAccessModifier_rendersTemplate_withInternalAccess() throws {
    // given
    let expected = """
    enum SchemaConfiguration: ApolloAPI.SchemaConfiguration {
      static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
        // Implement this function to configure cache key resolution for your schema types.
        return nil
      }
    }

    """

    buildSubject(config: .mock(.embeddedInTarget(name: "TestTarget", accessModifier: .internal)))
    // when

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 10, ignoringExtraLines: false))
  }

  func test__render_givenCocoapodsCompatibleImportStatements_true__rendersTemplateWithApolloTargetName() throws {
    // given
    let expected = """
    enum SchemaConfiguration: Apollo.SchemaConfiguration {
      static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
        // Implement this function to configure cache key resolution for your schema types.
        return nil
      }
    }

    """

    buildSubject(config: .mock(options: .init(cocoapodsCompatibleImportStatements: true)))
    // when

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 10, ignoringExtraLines: false))
  }

}

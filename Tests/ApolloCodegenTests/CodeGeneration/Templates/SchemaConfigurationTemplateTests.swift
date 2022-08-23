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

  // MARK: Helpers

  private func buildSubject(
    name: String = "testSchema",
    config: ApolloCodegenConfiguration = ApolloCodegenConfiguration.mock()
  ) {
    subject = SchemaConfigurationTemplate(
      schema: IR.Schema(name: name, referencedTypes: .init([])),
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderTemplate() -> String {
    subject.template.description
  }

  private func renderDetachedTemplate() -> String? {
    subject.detachedTemplate?.description
  }

  // MARK: Tests

  func test__render_header__rendersEditableHeaderTemplateWithReason() throws {
    // given
    let expected = """
    // @generated
    // This file was automatically generated and can be edited to
    // configure cache key resolution for objects in your schema.
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

  func test__render_givenSchemaModuleWithLowercaseName__rendersTemplateWithSchemaNameUppercased() throws {
    // given
    let expected = """
    public extension TestSchema.Schema {
      static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
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

}

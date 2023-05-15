import XCTest
@testable import ApolloCodegenLib
import Nimble
import ApolloInternalTestHelpers

class SchemaModuleNamespaceTemplateTests: XCTestCase {

  // MARK: Casing Tests

  func test__render__givenLowercaseSchemaName_generatesCapitalizedEnum() throws {
    // given
    let expected = """
    enum Schema { }
    
    """

    // when
    let subject = SchemaModuleNamespaceTemplate(
      config: .init(config: .mock(schemaNamespace: "schema"))
    )
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenUppercaseSchemaName_generatesUppercasedEnum() throws {
    // given
    let expected = """
    enum SCHEMA { }

    """

    // when
    let subject = SchemaModuleNamespaceTemplate(
      config: .init(config: .mock(schemaNamespace: "SCHEMA"))
    )
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenCapitalizedSchemaName_generatesCapitalizedEnum() throws {
    // given
    let expected = """
    enum MySchema { }

    """

    // when
    let subject = SchemaModuleNamespaceTemplate(
      config: .init(config: .mock(schemaNamespace: "MySchema"))
    )
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: Access Level Tests

  func test__render__givenModuleEmbeddedInTarget_withInternalModifier_rendersTemplate_withInternalAccess() throws {
    // given
    let expected = """
    enum MySchema { }

    """

    // when
    let subject = SchemaModuleNamespaceTemplate(
      config: .init(config: .mock(
        schemaNamespace: "MySchema",
        output: .mock(moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .internal))
      ))
    )
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenModuleEmbeddedInTarget_withPublicModifier_rendersTemplate_withPublicAccess() throws {
    // given
    let expected = """
    public enum MySchema { }

    """

    // when
    let subject = SchemaModuleNamespaceTemplate(
      config: .init(config: .mock(
        schemaNamespace: "MySchema",
        output: .mock(moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .public))
      ))
    )
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

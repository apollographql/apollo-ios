import XCTest
@testable import ApolloCodegenLib
import Nimble
import ApolloInternalTestHelpers

class SchemaModuleNamespaceTemplateTests: XCTestCase {

  // MARK: Casing Tests

  func test__render__givenLowercaseSchemaName_generatesCapitalizedPublicEnum() throws {
    // given
    let expected = """
    public enum Schema { }
    
    """

    // when
    let subject = SchemaModuleNamespaceTemplate(
      config: .init(config: .mock(schemaNamespace: "schema"))
    )
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenUppercaseSchemaName_generatesUppercasedPublicEnum() throws {
    // given
    let expected = """
    public enum SCHEMA { }

    """

    // when
    let subject = SchemaModuleNamespaceTemplate(
      config: .init(config: .mock(schemaNamespace: "SCHEMA"))
    )
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenCapitalizedSchemaName_generatesCapitalizedPublicEnum() throws {
    // given
    let expected = """
    public enum MySchema { }

    """

    // when
    let subject = SchemaModuleNamespaceTemplate(
      config: .init(config: .mock(schemaNamespace: "MySchema"))
    )
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

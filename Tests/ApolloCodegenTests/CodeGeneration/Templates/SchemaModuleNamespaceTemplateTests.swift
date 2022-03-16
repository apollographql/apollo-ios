import XCTest
@testable import ApolloCodegenLib
import Nimble

class SchemaModuleNamespaceTemplateTests: XCTestCase {

  // MARK: Definition Tests

  func test__definition__generatesSchemaModuleEnum() throws {
    // given
    let expected = """
    public enum NamespacedModule { }
    """

    // when
    let actual = SchemaModuleNamespaceTemplate.Definition.render("NamespacedModule")

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

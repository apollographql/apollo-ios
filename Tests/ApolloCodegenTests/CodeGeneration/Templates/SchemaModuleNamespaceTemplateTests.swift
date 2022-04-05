import XCTest
@testable import ApolloCodegenLib
import Nimble
import ApolloTestSupport

class SchemaModuleNamespaceTemplateTests: XCTestCase {

  // MARK: Definition Tests

  func test__boilerplate__generatesPublicEnum() throws {
    // given
    let expected = """
    public enum NamespacedModule { }
    """

    // when
    let subject = SchemaModuleNamespaceTemplate(namespace: "NamespacedModule")
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

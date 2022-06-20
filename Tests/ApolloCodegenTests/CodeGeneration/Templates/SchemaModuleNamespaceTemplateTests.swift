import XCTest
@testable import ApolloCodegenLib
import Nimble
import ApolloInternalTestHelpers

class SchemaModuleNamespaceTemplateTests: XCTestCase {

  // MARK: Definition Tests

  func test__boilerplate__generatesPublicEnumCorectlyCased() throws {
    // given
    let expected = """
    public enum NamespacedModule { }
    """

    // when
    let subject = SchemaModuleNamespaceTemplate(
      namespace: "namespacedModule",
      config: .init(value: .mock())
    )
    let actual = subject.template.description

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class InterfaceTemplateTests: XCTestCase {
  var subject: InterfaceTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject() {
    subject = InterfaceTemplate(
      graphqlInterface: GraphQLInterfaceType.mock("MockInterface", fields: [:], interfaces: [])
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Class Definition Tests

  func test_render_givenSchemaInterface_generatesSwiftClass() throws {
    // given
    buildSubject()

    let expected = """
    public final class MockInterface: Interface { }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

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

  private func buildSubject() {
    subject = InterfaceTemplate(
      graphqlInterface: GraphQLInterfaceType.mock("MockInterface", fields: [:], interfaces: [])
    )
  }

  // MARK: Boilerplate Tests

  func test_render_generatesHeaderComment() {
    // given
    buildSubject()

    let expected = """
    // @generated
    // This file was automatically generated and should not be edited.

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_generatesImportStatement() {
    // given
    buildSubject()

    let expected = """
    import ApolloAPI

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  // MARK: Class Definition Tests

  func test_render_givenSchemaInterface_generatesSwiftClass() throws {
    // given
    buildSubject()

    let expected = """
    public final class MockInterface: Interface { }
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6))
  }
}

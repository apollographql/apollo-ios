import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport
import ApolloAPI

class CustomScalarTemplateTests: XCTestCase {
  var subject: CustomScalarTemplate!

  // MARK: Helpers

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate Tests

  func test__render__givenCustomScalar_shouldGeneratePublicTypealias() throws {
    // given
    subject = CustomScalarTemplate(
      graphqlScalar: GraphQLScalarType.mock(name: "MyCustomScalar")
    )

    let expected = """
      public typealias MyCustomScalar = String
      """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected))
  }

  // MARK: Casing Tests

  func test__render__givenCustomScalar_shouldGenerateTypealiasNameFirstUppercased() throws {
    // given
    subject = CustomScalarTemplate(
      graphqlScalar: GraphQLScalarType.mock(name: "lowercasedScalar")
    )

    let expected = """
      public typealias LowercasedScalar = String
      """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected))
  }
}

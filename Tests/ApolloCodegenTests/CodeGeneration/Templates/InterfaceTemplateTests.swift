import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class InterfaceTemplateTests: XCTestCase {

  func test_render_givenSchemaInterface_generatesSwiftClass() throws {
    // given
    let graphqlInterface = GraphQLInterfaceType.mock(
      "MockInterface",
      fields: [:],
      interfaces: []
    )
    let template = InterfaceTemplate(graphqlInterface: graphqlInterface)

    let expected = """
    import ApolloAPI

    public final class MockInterface: Interface { }
    """

    // when
    let actual = template.render()

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

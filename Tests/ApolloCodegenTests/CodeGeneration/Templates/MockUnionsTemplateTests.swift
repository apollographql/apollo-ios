import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class MockUnionsTemplateTests: XCTestCase {
  var ir: IR!
  var subject: MockUnionsTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(
    unions: OrderedSet<GraphQLUnionType>
  ) {
    let config = ApolloCodegenConfiguration.mock()

    subject = MockUnionsTemplate(
      graphQLUnions: unions,
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate tests

  func test__target__isTestMockFile() {
    buildSubject(unions: [])

    expect(self.subject.target).to(equal(.testMockFile))
  }

  func test_render_givenSingleUnionType_generatesExtensionWithTypealias() {
    // given
    let Pet = GraphQLUnionType.mock("Pet")
    buildSubject(unions: [Pet])

    let expected = """
    public extension MockObject {
      typealias Pet = Union
    }
    
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test_render_givenMultipleUnionTypes_generatesExtensionWithTypealiasesCorrectlyCased() {
    // given
    let UnionA = GraphQLUnionType.mock("UnionA")
    let UnionB = GraphQLUnionType.mock("unionB")
    let UnionC = GraphQLUnionType.mock("Unionc")
    buildSubject(unions: [UnionA, UnionB, UnionC])

    let expected = """
    public extension MockObject {
      typealias UnionA = Union
      typealias UnionB = Union
      typealias UnionC = Union
    }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class MockInterfacesTemplateTests: XCTestCase {
  var ir: IR!
  var subject: MockInterfacesTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(
    interfaces: OrderedSet<GraphQLInterfaceType>
  ) {
    let config = ApolloCodegenConfiguration.mock()

    subject = MockInterfacesTemplate(
      graphQLInterfaces: interfaces,
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate tests

  func test__target__isTestMockFile() {
    buildSubject(interfaces: [])

    expect(self.subject.target).to(equal(.testMockFile))
  }

  func test_render_givenSingleInterfaceType_generatesExtensionWithTypealias() {
    // given
    let Pet = GraphQLInterfaceType.mock("Pet")
    buildSubject(interfaces: [Pet])

    let expected = """
    public extension MockObject {
      typealias Pet = Interface
    }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test_render_givenMultipleInterfaceTypes_generatesExtensionWithTypealiasesCorrectlyCased() {
    // given
    let InterfaceA = GraphQLInterfaceType.mock("InterfaceA")
    let InterfaceB = GraphQLInterfaceType.mock("interfaceB")
    let InterfaceC = GraphQLInterfaceType.mock("Interfacec")
    buildSubject(interfaces: [InterfaceA, InterfaceB, InterfaceC])

    let expected = """
    public extension MockObject {
      typealias InterfaceA = Interface
      typealias InterfaceB = Interface
      typealias Interfacec = Interface
    }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

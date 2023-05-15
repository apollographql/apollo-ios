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

  // MARK: - Helpers

  private func buildSubject(
    interfaces: OrderedSet<GraphQLInterfaceType>,
    testMocks: ApolloCodegenConfiguration.TestMockFileOutput = .swiftPackage()
  ) {
    let config = ApolloCodegenConfiguration.mock(output: .mock(testMocks: testMocks))

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

  // MARK: Typealias Tests

  func test__render__givenSingleInterfaceType_generatesExtensionWithTypealias() {
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

  func test__render__givenMultipleInterfaceTypes_generatesExtensionWithTypealiasesCorrectlyCased() {
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

  // MARK: Access Level Tests

  func test__render__givenInterfaceType_whenTestMocksIsSwiftPackage_shouldRenderWithPublicAccess() throws {
    // given
    buildSubject(interfaces: [GraphQLInterfaceType.mock("Pet")], testMocks: .swiftPackage())

    let expected = """
    public extension MockObject {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenInterfaceType_whenTestMocksAbsolute_withPublicAccessModifier_shouldRenderWithPublicAccess() throws {
    // given
    buildSubject(
      interfaces: [GraphQLInterfaceType.mock("Pet")],
      testMocks: .absolute(path: "", accessModifier: .public)
    )

    let expected = """
    public extension MockObject {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenInterfaceType_whenTestMocksAbsolute_withInternalAccessModifier_shouldRenderWithInternalAccess() throws {
    // given
    buildSubject(
      interfaces: [GraphQLInterfaceType.mock("Pet")],
      testMocks: .absolute(path: "", accessModifier: .internal)
    )

    let expected = """
    extension MockObject {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }
}

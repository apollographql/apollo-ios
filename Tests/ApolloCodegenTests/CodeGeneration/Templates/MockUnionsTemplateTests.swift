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

  // MARK: - Helpers

  private func buildSubject(
    unions: OrderedSet<GraphQLUnionType>,
    testMocks: ApolloCodegenConfiguration.TestMockFileOutput = .swiftPackage()
  ) {
    let config = ApolloCodegenConfiguration.mock(output: .mock(testMocks: testMocks))

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

  // MARK: Typealias Tests

  func test__render__givenSingleUnionType_generatesExtensionWithTypealias() {
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

  func test__render__givenMultipleUnionTypes_generatesExtensionWithTypealiasesCorrectlyCased() {
    // given
    let UnionA = GraphQLUnionType.mock("UnionA")
    let UnionB = GraphQLUnionType.mock("unionB")
    let UnionC = GraphQLUnionType.mock("Unionc")
    buildSubject(unions: [UnionA, UnionB, UnionC])

    let expected = """
    public extension MockObject {
      typealias UnionA = Union
      typealias UnionB = Union
      typealias Unionc = Union
    }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: Access Level Tests

  func test_render_givenUnionType_whenTestMocksIsSwiftPackage_shouldRenderWithPublicAccess() {
    // given
    let Pet = GraphQLUnionType.mock("Pet")
    buildSubject(unions: [Pet], testMocks: .swiftPackage())

    let expected = """
    public extension MockObject {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenUnionType_whenTestMocksAbsolute_withPublicAccessModifier_shouldRenderWithPublicAccess() {
    // given
    let Pet = GraphQLUnionType.mock("Pet")
    buildSubject(unions: [Pet], testMocks: .absolute(path: "", accessModifier: .public))

    let expected = """
    public extension MockObject {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenUnionType_whenTestMocksAbsolute_withInternalAccessModifier_shouldRenderWithInternalAccess() {
    // given
    let Pet = GraphQLUnionType.mock("Pet")
    buildSubject(unions: [Pet], testMocks: .absolute(path: "", accessModifier: .internal))

    let expected = """
    extension MockObject {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }
  
  // MARK: - Reserved Keyword Tests
  
  func test__render__usingReservedKeyword__generatesTypeWithSuffix() {
    let keywords = ["Type", "type"]
    
    keywords.forEach { keyword in
      // given
      let union = GraphQLUnionType.mock(keyword)
      buildSubject(unions: [union])

      let expected = """
      public extension MockObject {
        typealias \(keyword.firstUppercased)_Union = Union
      }
      """

      // when
      let actual = renderSubject()

      // then
      expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
    }
  }
  
}

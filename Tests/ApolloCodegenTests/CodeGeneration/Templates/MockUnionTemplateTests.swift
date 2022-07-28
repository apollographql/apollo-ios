import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class MockUnionTemplateTests: XCTestCase {
  var ir: IR!
  var subject: MockUnionTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(
    name: String = "Pet",
    types: [GraphQLObjectType] = [],
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = .swiftPackageManager
  ) {
    let config = ApolloCodegenConfiguration.mock(moduleType)
    ir = IR.mock(compilationResult: .mock())

    subject = MockUnionTemplate(
      graphqlUnion: GraphQLUnionType.mock(name, types: types),
      config: ApolloCodegen.ConfigurationContext(config: config),
      ir: ir
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate tests

  func test__target__isTestMockFile() {
    buildSubject()

    expect(self.subject.target).to(equal(.testMockFile))
  }

  func test_render_givenSchemaType_generatesExtensionWithTypealias() {
    // given
    buildSubject(name: "Pet")

    let expected = """
    extension Pet: MockFieldValue {
      public typealias MockValueCollectionType = Array<AnyMock>
    }
    
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test_render_givenConfig_SchemaTypeOutputNone_generatesExtensionWithSchemaNamespace() {
    // given
    buildSubject(name: "Pet", moduleType: .embeddedInTarget(name: "MockApplication"))

    let expected = """
    extension TestSchema.Pet: MockFieldValue {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }
}

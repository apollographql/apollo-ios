import XCTest
@testable import ApolloCodegenLib
@testable import ApolloCodegenInternalTestHelpers
import Nimble

class TemplateRenderer_TestMockFile_Tests: XCTestCase {

  // MARK: Helpers

  private func buildConfig(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    schemaNamespace: String = "testSchema",
    operations: ApolloCodegenConfiguration.OperationsFileOutput,
    cocoapodsCompatibleImportStatements: Bool = false
  ) -> ApolloCodegenConfiguration {
    ApolloCodegenConfiguration.mock(
      schemaNamespace: schemaNamespace,
      input: .init(schemaPath: "MockInputPath", operationSearchPaths: []),
      output: .mock(moduleType: moduleType, operations: operations),
      options: .init(cocoapodsCompatibleImportStatements: cocoapodsCompatibleImportStatements)
    )
  }

  private func buildSubject(config: ApolloCodegenConfiguration = .mock()) -> MockFileTemplate {
    MockFileTemplate(target: .testMockFile, config: ApolloCodegen.ConfigurationContext(config: config))
  }

  // MARK: Render Target .schemaFile Tests

  func test__renderTargetTestMockFile__givenAllSchemaTypesOperationsCombinations_shouldIncludeHeaderComment() {
    // given
    let expected = """
    // @generated
    // This file was automatically generated and should not be edited.

    """

    let tests: [(
      schemaTypes: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
      operations: ApolloCodegenConfiguration.OperationsFileOutput
    )] = [
      (schemaTypes: .swiftPackageManager, operations: .relative(subpath: nil)),
      (schemaTypes: .swiftPackageManager, operations: .absolute(path: "path")),
      (schemaTypes: .swiftPackageManager, operations: .inSchemaModule),
      (schemaTypes: .other, operations: .relative(subpath: nil)),
      (schemaTypes: .other, operations: .absolute(path: "path")),
      (schemaTypes: .other, operations: .inSchemaModule),
      (schemaTypes: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: nil)),
      (schemaTypes: .embeddedInTarget(name: "MockApplication"), operations: .absolute(path: "path")),
      (schemaTypes: .embeddedInTarget(name: "MockApplication"), operations: .inSchemaModule)
    ]

    for test in tests {
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
    }
  }

  func test__renderTargetSchemaFile__givenAllSchemaTypesOperationsCombinations_conditionallyImportSchemaModule() {
    // given
    let tests: [(
      schemaTypes: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
      operations: ApolloCodegenConfiguration.OperationsFileOutput,
      importModuleName: String
    )] = [
      (
        schemaTypes: .swiftPackageManager,
        operations: .relative(subpath: nil),
        importModuleName: "TestSchema"
      ),
      (
        schemaTypes: .swiftPackageManager,
        operations: .absolute(path: "path"),
        importModuleName: "TestSchema"
      ),
      (
        schemaTypes: .swiftPackageManager,
        operations: .inSchemaModule,
        importModuleName: "TestSchema"
      ),
      (
        schemaTypes: .other,
        operations: .relative(subpath: nil),
        importModuleName: "TestSchema"
      ),
      (
        schemaTypes: .other,
        operations: .absolute(path: "path"),
        importModuleName: "TestSchema"
      ),
      (
        schemaTypes: .other,
        operations: .inSchemaModule,
        importModuleName: "TestSchema"
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication"),
        operations: .relative(subpath: nil),
        importModuleName: "MockApplication"
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication"),
        operations: .absolute(path: "path"),
        importModuleName: "MockApplication"
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication"),
        operations: .inSchemaModule,
        importModuleName: "MockApplication"
      )
    ]

    for test in tests {
      let expected = """
      import ApolloTestSupport
      import \(test.importModuleName)

      """
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
    }
  }

  func test__renderTargetSchemaFile__given_cocoapodsCompatibleImportStatements_true_importTargetNameIsApollo() {
    // given
    let expected = """
    import Apollo
    import TestSchema

    """
    let config = buildConfig(
      moduleType: .swiftPackageManager,
      operations: .inSchemaModule,
      cocoapodsCompatibleImportStatements: true
    )
    let subject = buildSubject(config: config)

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }
}

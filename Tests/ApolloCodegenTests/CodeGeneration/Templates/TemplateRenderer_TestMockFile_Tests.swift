import XCTest
@testable import ApolloCodegenLib
@testable import ApolloCodegenInternalTestHelpers
import ApolloUtils
import Nimble

class TemplateRenderer_TestMockFile_Tests: XCTestCase {
  private var config: ReferenceWrapped<ApolloCodegenConfiguration>!
  private var subject: MockFileTemplate = .mock(target: .testMockFile)

  override func tearDown() {
    config = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildConfig(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    schemaName: String = "testSchema",
    operations: ApolloCodegenConfiguration.OperationsFileOutput
  ) {
    config = ReferenceWrapped(
      value: ApolloCodegenConfiguration.mock(
        schemaName: schemaName,
        input: .init(schemaPath: "MockInputPath", searchPaths: []),
        output: .mock(moduleType: moduleType, operations: operations)
      )
    )
  }

  private func renderSubject() -> String {
    subject.render(forConfig: config)
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
      buildConfig(moduleType: test.schemaTypes, operations: test.operations)

      // when
      let actual = renderSubject()

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
      buildConfig(moduleType: test.schemaTypes, operations: test.operations)

      // when
      let actual = renderSubject()

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
    }
  }
}

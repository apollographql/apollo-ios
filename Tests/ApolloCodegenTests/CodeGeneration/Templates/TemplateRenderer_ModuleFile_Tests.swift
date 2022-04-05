import XCTest
@testable import ApolloCodegenLib
@testable import ApolloCodegenTestSupport
import ApolloUtils
import Nimble

class TemplateRenderer_ModuleFile_Tests: XCTestCase {
  private var config: ReferenceWrapped<ApolloCodegenConfiguration>!
  private var subject: MockFileTemplate = .mock(target: .moduleFile)

  override func tearDown() {
    config = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildConfig(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    schemaName: String = "TestSchema",
    operations: ApolloCodegenConfiguration.OperationsFileOutput
  ) {
    config = ReferenceWrapped(
      value: ApolloCodegenConfiguration.mock(
        input: .init(schemaPath: "MockInputPath", searchPaths: []),
        output: .mock(moduleType: moduleType, schemaName: schemaName, operations: operations)
      )
    )
  }

  private func renderSubject() -> String {
    subject.render(forConfig: config)
  }

  // MARK: Render Target .moduleFile Tests

  func test__renderTargetModuleFile__givenAllSchemaTypesOperationsCombinations_conditionallyIncludeHeaderComment() {
    // given
    let expectedHeaderAndTemplate = """
    // @generated
    // This file was automatically generated and should not be edited.

    root {
      nested
    }
    """

    let expectedTemplate = """
    root {
      nested
    }
    """

    let tests: [(
      schemaTypes: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
      operations: ApolloCodegenConfiguration.OperationsFileOutput,
      expected: String
    )] = [
      (
        schemaTypes: .swiftPackageManager,
        operations: .relative(subpath: nil),
        expected: expectedTemplate
      ),
      (
        schemaTypes: .swiftPackageManager,
        operations: .absolute(path: "path"),
        expected: expectedTemplate
      ),
      (
        schemaTypes: .swiftPackageManager,
        operations: .inSchemaModule,
        expected: expectedTemplate
      ),
      (
        schemaTypes: .other,
        operations: .relative(subpath: nil),
        expected: expectedTemplate
      ),
      (
        schemaTypes: .other,
        operations: .absolute(path: "path"),
        expected: expectedTemplate
      ),
      (
        schemaTypes: .other,
        operations: .inSchemaModule,
        expected: expectedTemplate
      ),
      (
        schemaTypes: .none,
        operations: .relative(subpath: nil),
        expected: expectedHeaderAndTemplate
      ),
      (
        schemaTypes: .none,
        operations: .absolute(path: "path"),
        expected: expectedHeaderAndTemplate
      ),
      (
        schemaTypes: .none,
        operations: .inSchemaModule,
        expected: expectedHeaderAndTemplate
      )
    ]

    for test in tests {
      buildConfig(moduleType: test.schemaTypes, operations: test.operations)

      // when
      let actual = renderSubject()

      // then
      expect(actual).to(equalLineByLine(test.expected))
    }
  }
}

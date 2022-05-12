import XCTest
@testable import ApolloCodegenLib
@testable import ApolloCodegenInternalTestHelpers
import ApolloUtils
import Nimble

class TemplateRenderer_SchemaFile_Tests: XCTestCase {
  private var config: ReferenceWrapped<ApolloCodegenConfiguration>!
  private var subject: MockFileTemplate = .mock(target: .schemaFile)

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

  func test__renderTargetSchemaFile__givenAllSchemaTypesOperationsCombinations_shouldIncludeHeaderComment() {
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

  func test__renderTargetSchemaFile__givenAllSchemaTypesOperationsCombinations_shouldIncludeImportStatement() {
    // given
    let expected = """
    import ApolloAPI

    """

    let tests: [(
      schemaTypes: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
      operations: ApolloCodegenConfiguration.OperationsFileOutput
    )] = [
      (
        schemaTypes: .swiftPackageManager,
        operations: .relative(subpath: nil)
      ),
      (
        schemaTypes: .swiftPackageManager,
        operations: .absolute(path: "path")
      ),
      (
        schemaTypes: .swiftPackageManager,
        operations: .inSchemaModule
      ),
      (
        schemaTypes: .other,
        operations: .relative(subpath: nil)
      ),
      (
        schemaTypes: .other,
        operations: .absolute(path: "path")
      ),
      (
        schemaTypes: .other,
        operations: .inSchemaModule
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication"),
        operations: .relative(subpath: nil)
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication"),
        operations: .absolute(path: "path")
      ),
      (
        .embeddedInTarget(name: "MockApplication"),
        operations: .inSchemaModule
      )
    ]

    for test in tests {
      buildConfig(moduleType: test.schemaTypes, operations: test.operations)

      // when
      let actual = renderSubject()

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
    }
  }

  func test__renderTargetSchemaFile__givenAllSchemaTypesOperationsCombinations_conditionallyWrapInNamespace() {
    // given
    let expectedNoNamespace = """
    root {
      nested
    }
    """

    let expectedNamespace = """
    public extension TestSchema {
      root {
        nested
      }
    }
    """

    let tests: [(
      schemaTypes: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
      operations: ApolloCodegenConfiguration.OperationsFileOutput,
      expectation: String,
      atLine: Int
    )] = [
      (
        schemaTypes: .swiftPackageManager,
        operations: .relative(subpath: nil),
        expectation: expectedNoNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .swiftPackageManager,
        operations: .absolute(path: "path"),
        expectation: expectedNoNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .swiftPackageManager,
        operations: .inSchemaModule,
        expectation: expectedNoNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .other,
        operations: .relative(subpath: nil),
        expectation: expectedNoNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .other,
        operations: .absolute(path: "path"),
        expectation: expectedNoNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .other,
        operations: .inSchemaModule,
        expectation: expectedNoNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication"),
        operations: .relative(subpath: nil),
        expectation: expectedNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication"),
        operations: .absolute(path: "path"),
        expectation: expectedNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication"),
        operations: .inSchemaModule,
        expectation: expectedNamespace,
        atLine: 6
      )
    ]

    for test in tests {
      buildConfig(moduleType: test.schemaTypes, operations: test.operations)

      // when
      let actual = renderSubject()

      // then
      expect(actual).to(equalLineByLine(test.expectation, atLine: test.atLine))
    }
  }
}

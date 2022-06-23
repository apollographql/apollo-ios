import XCTest
@testable import ApolloCodegenLib
@testable import ApolloCodegenInternalTestHelpers
import ApolloUtils
import Nimble

class TemplateRenderer_SchemaFile_Tests: XCTestCase {

  // MARK: Helpers

  private func buildConfig(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    schemaName: String = "testSchema",
    operations: ApolloCodegenConfiguration.OperationsFileOutput
  ) -> ApolloCodegenConfiguration {
    ApolloCodegenConfiguration.mock(
      schemaName: schemaName,
      input: .init(schemaPath: "MockInputPath", operationSearchPaths: []),
      output: .mock(moduleType: moduleType, operations: operations)
    )
  }

  private func buildSubject(config: ApolloCodegenConfiguration = .mock()) -> MockFileTemplate {
    MockFileTemplate(target: .schemaFile, config: ReferenceWrapped(value: config))
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
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config)

      // when
      let actual = subject.render()

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
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
    }
  }

  func test__renderTargetSchemaFile__givenAllSchemaTypesOperationsCombinations_conditionallyWrapInNamespace() {
    // given
    let expectedNoNamespace = """
    detached {
      nested
    }

    root {
      nested
    }
    """

    let expectedNamespace = """
    detached {
      nested
    }

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
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(test.expectation, atLine: test.atLine))
    }
  }
}

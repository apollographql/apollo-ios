import XCTest
@testable import ApolloCodegenLib
@testable import ApolloCodegenInternalTestHelpers
import Nimble

class TemplateRenderer_SchemaFile_Tests: XCTestCase {

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

  private func buildSubject(
    config: ApolloCodegenConfiguration = .mock(),
    targetFileType: TemplateTarget.SchemaFileType = .schemaMetadata
  ) -> MockFileTemplate {
    MockFileTemplate(
      target: .schemaFile(type: targetFileType),
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
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

  func test__renderTargetSchemaFile__given_cocoapodsCompatibleImportStatements_true_allSchemaTypesOperationsCombinations_shouldIncludeImportStatement() {
    // given
    let expected = """
    import Apollo

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
      let config = buildConfig(
        moduleType: test.schemaTypes,
        operations: test.operations,
        cocoapodsCompatibleImportStatements: true
      )
      let subject = buildSubject(config: config)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
    }
  }

  func test__renderTargetSchemaFile__given_schemaTypeFile_AllSchemaTypesOperationsCombinations_conditionallyWrapInNamespace() {
    // given
    let expectedNoNamespace = """
    detached {
      nested
    }

    root {
      nested
    }
    """

    let expectedPublicNamespace = """
    detached {
      nested
    }

    public extension TestSchema {
      root {
        nested
      }
    }
    """

    let expectedInternalNamespace = """
    detached {
      nested
    }

    extension TestSchema {
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
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .relative(subpath: nil),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .relative(subpath: nil),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .absolute(path: "path"),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .absolute(path: "path"),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .inSchemaModule,
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .inSchemaModule,
        expectation: expectedPublicNamespace,
        atLine: 6
      )
    ]

    for test in tests {
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config, targetFileType: .schemaMetadata)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(test.expectation, atLine: test.atLine))
    }
  }

  func test__renderTargetSchemaFile__given_schemaCacheKeyResolutionExtensionTypeFile_AllSchemaTypesOperationsCombinations_doesNotWrapInNamespace() {
    // given
    let tests: [(
      schemaTypes: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
      operations: ApolloCodegenConfiguration.OperationsFileOutput,
      atLine: Int
    )] = [
      (
        schemaTypes: .swiftPackageManager,
        operations: .relative(subpath: nil),
        atLine: 6
      ),
      (
        schemaTypes: .swiftPackageManager,
        operations: .absolute(path: "path"),
        atLine: 6
      ),
      (
        schemaTypes: .swiftPackageManager,
        operations: .inSchemaModule,
        atLine: 6
      ),
      (
        schemaTypes: .other,
        operations: .relative(subpath: nil),
        atLine: 6
      ),
      (
        schemaTypes: .other,
        operations: .absolute(path: "path"),
        atLine: 6
      ),
      (
        schemaTypes: .other,
        operations: .inSchemaModule,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication"),
        operations: .relative(subpath: nil),
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication"),
        operations: .absolute(path: "path"),
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication"),
        operations: .inSchemaModule,
        atLine: 6
      )
    ]

    let expected = """
    detached {
      nested
    }

    root {
      nested
    }
    """

    for test in tests {
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config, targetFileType: .schemaConfiguration)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(expected, atLine: test.atLine))
    }
  }

  func test__renderTargetSchemaFile__given_enumTypeFile_AllSchemaTypesOperationsCombinations_conditionallyWrapInNamespace() {
    // given
    let expectedNoNamespace = """
    detached {
      nested
    }

    root {
      nested
    }
    """

    let expectedPublicNamespace = """
    detached {
      nested
    }

    public extension TestSchema {
      root {
        nested
      }
    }
    """

    let expectedInternalNamespace = """
    detached {
      nested
    }

    extension TestSchema {
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
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .relative(subpath: nil),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .relative(subpath: nil),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .absolute(path: "path"),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .absolute(path: "path"),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .inSchemaModule,
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .inSchemaModule,
        expectation: expectedInternalNamespace,
        atLine: 6
      )
    ]

    for test in tests {
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config, targetFileType: .enum)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(test.expectation, atLine: test.atLine))
    }
  }

  func test__renderTargetSchemaFile__given_inputObjectTypeFile_AllSchemaTypesOperationsCombinations_conditionallyWrapInNamespace() {
    // given
    let expectedNoNamespace = """
    detached {
      nested
    }

    root {
      nested
    }
    """

    let expectedPublicNamespace = """
    detached {
      nested
    }

    public extension TestSchema {
      root {
        nested
      }
    }
    """

    let expectedInternalNamespace = """
    detached {
      nested
    }

    extension TestSchema {
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
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .relative(subpath: nil),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .relative(subpath: nil),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .absolute(path: "path"),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .absolute(path: "path"),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .inSchemaModule,
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .inSchemaModule,
        expectation: expectedPublicNamespace,
        atLine: 6
      )
    ]

    for test in tests {
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config, targetFileType: .inputObject)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(test.expectation, atLine: test.atLine))
    }
  }

  func test__renderTargetSchemaFile__given_customScalarTypeFile_AllSchemaTypesOperationsCombinations_conditionallyWrapInNamespace() {
    // given
    let expectedNoNamespace = """
    detached {
      nested
    }

    root {
      nested
    }
    """

    let expectedPublicNamespace = """
    detached {
      nested
    }

    public extension TestSchema {
      root {
        nested
      }
    }
    """

    let expectedInternalNamespace = """
    detached {
      nested
    }

    extension TestSchema {
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
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .relative(subpath: nil),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .relative(subpath: nil),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .absolute(path: "path"),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .absolute(path: "path"),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .inSchemaModule,
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .inSchemaModule,
        expectation: expectedInternalNamespace,
        atLine: 6
      )
    ]

    for test in tests {
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config, targetFileType: .customScalar)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(test.expectation, atLine: test.atLine))
    }
  }

  func test__renderTargetSchemaFile__given_objectTypeFile_AllSchemaTypesOperationsCombinations_conditionallyWrapInNamespace() {
    // given
    let expectedNoNamespace = """
    detached {
      nested
    }

    public extension Objects {
      root {
        nested
      }
    }
    """

    let expectedPublicNamespace = """
    detached {
      nested
    }

    public extension TestSchema.Objects {
      root {
        nested
      }
    }
    """

    let expectedInternalNamespace = """
    detached {
      nested
    }

    extension TestSchema.Objects {
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
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .relative(subpath: nil),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .relative(subpath: nil),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .absolute(path: "path"),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .absolute(path: "path"),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .inSchemaModule,
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .inSchemaModule,
        expectation: expectedInternalNamespace,
        atLine: 6
      )
    ]

    for test in tests {
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config, targetFileType: .object)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(test.expectation, atLine: test.atLine))
    }
  }

  func test__renderTargetSchemaFile__given_interfaceTypeFile_AllSchemaTypesOperationsCombinations_conditionallyWrapInNamespace() {
    // given
    let expectedNoNamespace = """
    detached {
      nested
    }

    public extension Interfaces {
      root {
        nested
      }
    }
    """

    let expectedPublicNamespace = """
    detached {
      nested
    }

    public extension TestSchema.Interfaces {
      root {
        nested
      }
    }
    """

    let expectedInternalNamespace = """
    detached {
      nested
    }

    extension TestSchema.Interfaces {
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
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .relative(subpath: nil),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .relative(subpath: nil),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .absolute(path: "path"),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .absolute(path: "path"),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .inSchemaModule,
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .inSchemaModule,
        expectation: expectedInternalNamespace,
        atLine: 6
      )
    ]

    for test in tests {
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config, targetFileType: .interface)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(test.expectation, atLine: test.atLine))
    }
  }

  func test__renderTargetSchemaFile__given_unionTypeFile_AllSchemaTypesOperationsCombinations_conditionallyWrapInNamespace() {
    // given
    let expectedNoNamespace = """
    detached {
      nested
    }

    public extension Unions {
      root {
        nested
      }
    }
    """

    let expectedPublicNamespace = """
    detached {
      nested
    }

    public extension TestSchema.Unions {
      root {
        nested
      }
    }
    """

    let expectedInternalNamespace = """
    detached {
      nested
    }

    extension TestSchema.Unions {
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
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .relative(subpath: nil),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .relative(subpath: nil),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .absolute(path: "path"),
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .absolute(path: "path"),
        expectation: expectedInternalNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
        operations: .inSchemaModule,
        expectation: expectedPublicNamespace,
        atLine: 6
      ),
      (
        schemaTypes: .embeddedInTarget(name: "MockApplication", accessModifier: .internal),
        operations: .inSchemaModule,
        expectation: expectedInternalNamespace,
        atLine: 6
      )
    ]

    for test in tests {
      let config = buildConfig(moduleType: test.schemaTypes, operations: test.operations)
      let subject = buildSubject(config: config, targetFileType: .union)

      // when
      let actual = subject.render()

      // then
      expect(actual).to(equalLineByLine(test.expectation, atLine: test.atLine))
    }
  }

  // MARK: Casing Tests

  func test__casing__givenLowercasedSchemaName_whenSchemaAndComponentNamespace_shouldGenerateFirstUppercasedNamespace() {
    // given
    let config = buildConfig(
      moduleType: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
      schemaNamespace: "testschema",
      operations: .inSchemaModule)

    let subject = buildSubject(config: config, targetFileType: .union)

    // when
    let actual = subject.render()

    // then
    let expected = """
    public extension Testschema.Unions {
    """

    expect(actual).to(equalLineByLine(expected, atLine: 10, ignoringExtraLines: true))
  }

  func test__casing__givenUppercasedSchemaName_whenSchemaAndComponentNamespace_shouldGenerateUppercasedNamespace() {
    // given
    let config = buildConfig(
      moduleType: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
      schemaNamespace: "TESTSCHEMA",
      operations: .inSchemaModule)

    let subject = buildSubject(config: config, targetFileType: .union)

    // when
    let actual = subject.render()

    // then
    let expected = """
    public extension TESTSCHEMA.Unions {
    """

    expect(actual).to(equalLineByLine(expected, atLine: 10, ignoringExtraLines: true))
  }

  func test__casing__givenCapitalizedSchemaName_whenSchemaAndComponentNamespace_shouldGenerateCapitalizedNamespace() {
    // given
    let config = buildConfig(
      moduleType: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
      schemaNamespace: "TestSchema",
      operations: .inSchemaModule)

    let subject = buildSubject(config: config, targetFileType: .union)

    // when
    let actual = subject.render()

    // then
    let expected = """
    public extension TestSchema.Unions {
    """

    expect(actual).to(equalLineByLine(expected, atLine: 10, ignoringExtraLines: true))
  }

  func test__casing__givenLowercasedSchemaName_whenOnlySchemaNamespace_shouldGenerateFirstUppercasedNamespace() {
    // given
    let config = buildConfig(
      moduleType: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
      schemaNamespace: "testschema",
      operations: .inSchemaModule)

    let subject = buildSubject(config: config, targetFileType: .customScalar)

    // when
    let actual = subject.render()

    // then
    let expected = """
    public extension Testschema {
    """

    expect(actual).to(equalLineByLine(expected, atLine: 10, ignoringExtraLines: true))
  }

  func test__casing__givenUppercasedSchemaName_whenOnlySchemaNamespace_shouldGenerateUppercasedNamespace() {
    // given
    let config = buildConfig(
      moduleType: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
      schemaNamespace: "TESTSCHEMA",
      operations: .inSchemaModule)

    let subject = buildSubject(config: config, targetFileType: .customScalar)

    // when
    let actual = subject.render()

    // then
    let expected = """
    public extension TESTSCHEMA {
    """

    expect(actual).to(equalLineByLine(expected, atLine: 10, ignoringExtraLines: true))
  }

  func test__casing__givenCapitalizedSchemaName_whenOnlySchemaNamespace_shouldGenerateCapitalizedNamespace() {
    // given
    let config = buildConfig(
      moduleType: .embeddedInTarget(name: "MockApplication", accessModifier: .public),
      schemaNamespace: "TestSchema",
      operations: .inSchemaModule)

    let subject = buildSubject(config: config, targetFileType: .customScalar)

    // when
    let actual = subject.render()

    // then
    let expected = """
    public extension TestSchema {
    """

    expect(actual).to(equalLineByLine(expected, atLine: 10, ignoringExtraLines: true))
  }
}

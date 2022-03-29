import XCTest
@testable import ApolloCodegenLib
import Nimble
import ApolloCodegenTestSupport
import ApolloUtils

class ImportStatementTemplateTests: XCTestCase {

  var config: ReferenceWrapped<ApolloCodegenConfiguration>!

  override func tearDown() {
    config = nil

    super.tearDown()
  }

  // MARK: Helpers

  func buildConfig(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    operations: ApolloCodegenConfiguration.OperationsFileOutput
  ) {
    config = ReferenceWrapped(value: ApolloCodegenConfiguration.mock(
      output: .mock(
        moduleType: moduleType,
        schemaName: "ImportStatementTestsSchema",
        operations: operations
      )
    ))
  }

  // MARK: Tests for operations generated into the schema module (schema module import not expected)

  func test__operationRender__givenOperationsOutput_inSchemaModule_whenModuleType_none_generatesImportNotIncludingSchemaName() throws {
    // given
    buildConfig(
      moduleType: .none,
      operations: .inSchemaModule
    )

    let expected =
    """
    import ApolloAPI
    """

    // when
    let actual = ImportStatementTemplate.Operation.template(forConfig: config).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__operationRender__givenOperationsOutput_inSchemaModule_whenModuleType_swiftPackageManager_generatesImportNotIncludingSchemaName() throws {
    // given
    buildConfig(
      moduleType: .swiftPackageManager,
      operations: .inSchemaModule
    )

    let expected =
    """
    import ApolloAPI
    """

    // when
    let actual = ImportStatementTemplate.Operation.template(forConfig: config).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__operationRender__givenOperationsOutput_inSchemaModule_whenModuleType_other_generatesImportNotIncludingSchemaName() throws {
    // given
    buildConfig(
      moduleType: .other,
      operations: .inSchemaModule
    )

    let expected =
    """
    import ApolloAPI
    """

    // when
    let actual = ImportStatementTemplate.Operation.template(forConfig: config).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: Tests for operations generated outside the schema module

  func test__operationRender__givenOperationsOutput_relative_whenModuleType_none_generatesImportNotIncludingSchemaName() throws {
    // given
    buildConfig(
      moduleType: .none,
      operations: .relative(subpath: nil)
    )

    let expected =
    """
    import ApolloAPI
    """

    // when
    let actual = ImportStatementTemplate.Operation.template(forConfig: config).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__operationRender__givenOperationsOutput_relative_whenModuleType_swiftPackageManager_generatesImportIncludingSchemaName() throws {
    // given
    buildConfig(
      moduleType: .swiftPackageManager,
      operations: .relative(subpath: nil)
    )

    let expected =
    """
    import ApolloAPI
    import ImportStatementTestsSchema
    """

    // when
    let actual = ImportStatementTemplate.Operation.template(forConfig: config).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__operationRender__givenOperationsOutput_relative_whenModuleType_other_generatesImportIncludingSchemaName() throws {
    // given
    buildConfig(
      moduleType: .other,
      operations: .relative(subpath: nil)
    )

    let expected =
    """
    import ApolloAPI
    import ImportStatementTestsSchema
    """

    // when
    let actual = ImportStatementTemplate.Operation.template(forConfig: config).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__operationRender__givenOperationsOutput_absolute_whenModuleType_none_generatesImportNotIncludingSchemaName() throws {
    // given
    buildConfig(
      moduleType: .none,
      operations: .absolute(path: "path")
    )

    let expected =
    """
    import ApolloAPI
    """

    // when
    let actual = ImportStatementTemplate.Operation.template(forConfig: config).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__operationRender__givenOperationsOutput_absolute_whenModuleType_swiftPackageManager_generatesImportIncludingSchemaName() throws {
    // given
    buildConfig(
      moduleType: .swiftPackageManager,
      operations: .absolute(path: "path")
    )

    let expected =
    """
    import ApolloAPI
    import ImportStatementTestsSchema
    """

    // when
    let actual = ImportStatementTemplate.Operation.template(forConfig: config).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__operationRender__givenOperationsOutput_absolute_whenModuleType_other_generatesImportIncludingSchemaName() throws {
    // given
    buildConfig(
      moduleType: .other,
      operations: .absolute(path: "path")
    )

    let expected =
    """
    import ApolloAPI
    import ImportStatementTestsSchema
    """

    // when
    let actual = ImportStatementTemplate.Operation.template(forConfig: config).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }
}

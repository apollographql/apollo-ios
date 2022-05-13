import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers
import ApolloUtils

class FileGenerator_ResolvePath_Tests: XCTestCase {
  let directoryURL = CodegenTestHelper.outputFolderURL()

  var irFragment: IR.NamedFragment!
  var irOperation: IR.Operation!
  var subject: FileTarget!
  var config: ApolloCodegenConfiguration!

  override func tearDown() {
    irOperation = nil
    irFragment = nil
    subject = nil
    config = nil

    super.tearDown()
  }

  // MARK: - Helpers

  private func buildIR() throws {
    let schemaSDL = """
    type Animal {
      species: String
    }

    type Query {
      animals: [Animal]
    }
    """

    let operationDocument = """
    query AllAnimals {
      animals {
        ...AnimalDetails
      }
    }

    fragment AnimalDetails on Animal {
      species
    }
    """

    let ir = try IR.mock(schema: schemaSDL, document: operationDocument)

    irFragment = ir.build(fragment: ir.compilationResult.fragments[0])
    irFragment.definition.filePath = directoryURL
      .appendingPathComponent("\(UUID().uuidString)/fragment.graphql").path

    irOperation = ir.build(operation: ir.compilationResult.operations[0])
    irOperation.definition.filePath = directoryURL
      .appendingPathComponent("\(UUID().uuidString)/operation.graphql").path
  }

  private func buildConfig(
    module: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    operations: ApolloCodegenConfiguration.OperationsFileOutput,
    testMocks: ApolloCodegenConfiguration.TestMockFileOutput = .none
  ) {
  config = .mock(output: .mock(
      moduleType: module,
      operations: operations,
      testMocks: testMocks,
      path: directoryURL.path
    ))
  }  

  private func deleteLastPathComponent(_ path: String, appending newPath: String? = nil) -> String {
    let result = URL(fileURLWithPath: path).deletingLastPathComponent()

    guard let newPath = newPath else {
      return result.path
    }

    return result.appendingPathComponent(newPath).path
  }

  private func resolvePath() -> String {
    subject.resolvePath(forConfig: ReferenceWrapped(value: config))
  }

  // MARK: - Resolving Schema Path Tests

  // MARK: .object

  func test__resolvePath__givenFileTargetObject_when_moduleSwiftPackageManager_operationsInSchemaModule_shouldReturnSchemaObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .swiftPackageManager, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetObject_when_moduleSwiftPackageManager_operationsAbsolutePath_shouldReturnObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .swiftPackageManager, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetObject_when_moduleSwiftPackageManager_operationsRelativeSubpathNil_shouldReturnObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetObject_when_moduleSwiftPackageManager_operationsRelativeSubpath_shouldReturnObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetObject_when_moduleNone_operationsInSchemaModule_shouldReturnSchemaObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetObject_when_moduleNone_operationsAbsolutePath_shouldReturnObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetObject_when_moduleNone_operationsRelativeSubpathNil_shouldReturnObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetObject_when_moduleNone_operationsRelativeSubpath_shouldReturnObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetObject_when_moduleOther_operationsInSchemaModule_shouldReturnSchemaObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .other, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetObject_when_moduleOther_operationsAbsolutePath_shouldReturnObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .other, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetObject_when_moduleOther_operationsRelativeSubpathNil_shouldReturnObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .other, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetObject_when_moduleOther_operationsRelativeSubpath_shouldReturnObjectsSubpath() {
    // given
    subject = .object

    // when
    buildConfig(module: .other, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Objects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  // MARK: .enum

  func test__resolvePath__givenFileTargetEnum_when_moduleSwiftPackageManager_operationsInSchemaModule_shouldReturnSchemaEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .swiftPackageManager, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetEnum_when_moduleSwiftPackageManager_operationsAbsolutePath_shouldReturnEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .swiftPackageManager, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetEnum_when_moduleSwiftPackageManager_operationsRelativeSubpathNil_shouldReturnEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetEnum_when_moduleSwiftPackageManager_operationsRelativeSubpath_shouldReturnEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetEnum_when_moduleNone_operationsInSchemaModule_shouldReturnSchemaEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetEnum_when_moduleNone_operationsAbsolutePath_shouldReturnEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetEnum_when_moduleNone_operationsRelativeSubpathNil_shouldReturnEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetEnum_when_moduleNone_operationsRelativeSubpath_shouldReturnEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetEnum_when_moduleOther_operationsInSchemaModule_shouldReturnSchemaEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .other, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetEnum_when_moduleOther_operationsAbsolutePath_shouldReturnEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .other, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetEnum_when_moduleOther_operationsRelativeSubpathNil_shouldReturnEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .other, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetEnum_when_moduleOther_operationsRelativeSubpath_shouldReturnEnumsSubpath() {
    // given
    subject = .enum

    // when
    buildConfig(module: .other, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Enums")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  // MARK: .interface

  func test__resolvePath__givenFileTargetInterface_when_moduleSwiftPackageManager_operationsInSchemaModule_shouldReturnSchemaInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .swiftPackageManager, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInterface_when_moduleSwiftPackageManager_operationsAbsolutePath_shouldReturnInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .swiftPackageManager, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInterface_when_moduleSwiftPackageManager_operationsRelativeSubpathNil_shouldReturnInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInterface_when_moduleSwiftPackageManager_operationsRelativeSubpath_shouldReturnInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInterface_when_moduleNone_operationsInSchemaModule_shouldReturnSchemaInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInterface_when_moduleNone_operationsAbsolutePath_shouldReturnInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInterface_when_moduleNone_operationsRelativeSubpathNil_shouldReturnInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInterface_when_moduleNone_operationsRelativeSubpath_shouldReturnInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInterface_when_moduleOther_operationsInSchemaModule_shouldReturnSchemaInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .other, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInterface_when_moduleOther_operationsAbsolutePath_shouldReturnInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .other, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInterface_when_moduleOther_operationsRelativeSubpathNil_shouldReturnInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .other, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInterface_when_moduleOther_operationsRelativeSubpath_shouldReturnInterfacesSubpath() {
    // given
    subject = .interface

    // when
    buildConfig(module: .other, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Interfaces")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  // MARK: .union

  func test__resolvePath__givenFileTargetUnion_when_moduleSwiftPackageManager_operationsInSchemaModule_shouldReturnSchemaUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .swiftPackageManager, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetUnion_when_moduleSwiftPackageManager_operationsAbsolutePath_shouldReturnUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .swiftPackageManager, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetUnion_when_moduleSwiftPackageManager_operationsRelativeSubpathNil_shouldReturnUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetUnion_when_moduleSwiftPackageManager_operationsRelativeSubpath_shouldReturnUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetUnion_when_moduleNone_operationsInSchemaModule_shouldReturnSchemaUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetUnion_when_moduleNone_operationsAbsolutePath_shouldReturnUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetUnion_when_moduleNone_operationsRelativeSubpathNil_shouldReturnUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetUnion_when_moduleNone_operationsRelativeSubpath_shouldReturnUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetUnion_when_moduleOther_operationsInSchemaModule_shouldReturnSchemaUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .other, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetUnion_when_moduleOther_operationsAbsolutePath_shouldReturnUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .other, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetUnion_when_moduleOther_operationsRelativeSubpathNil_shouldReturnUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .other, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetUnion_when_moduleOther_operationsRelativeSubpath_shouldReturnUnionsSubpath() {
    // given
    subject = .union

    // when
    buildConfig(module: .other, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("Unions")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  // MARK: .inputObjects

  func test__resolvePath__givenFileTargetInputObject_when_moduleSwiftPackageManager_operationsInSchemaModule_shouldReturnSchemaInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .swiftPackageManager, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInputObject_when_moduleSwiftPackageManager_operationsAbsolutePath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .swiftPackageManager, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInputObject_when_moduleSwiftPackageManager_operationsRelativeSubpathNil_shouldReturnInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInputObject_when_moduleSwiftPackageManager_operationsRelativeSubpath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInputObject_when_moduleNone_operationsInSchemaModule_shouldReturnSchemaInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInputObject_when_moduleNone_operationsAbsolutePath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInputObject_when_moduleNone_operationsRelativeSubpathNil_shouldReturnInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInputObject_when_moduleNone_operationsRelativeSubpath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInputObject_when_moduleOther_operationsInSchemaModule_shouldReturnSchemaInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .other, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInputObject_when_moduleOther_operationsAbsolutePath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .other, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInputObject_when_moduleOther_operationsRelativeSubpathNil_shouldReturnInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .other, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetInputObject_when_moduleOther_operationsRelativeSubpath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .inputObject

    // when
    buildConfig(module: .other, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("InputObjects")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  // MARK: .customScalar

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleSwiftPackageManager_operationsInSchemaModule_shouldReturnSchemaInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .swiftPackageManager, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleSwiftPackageManager_operationsAbsolutePath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .swiftPackageManager, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleSwiftPackageManager_operationsRelativeSubpathNil_shouldReturnInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleSwiftPackageManager_operationsRelativeSubpath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleNone_operationsInSchemaModule_shouldReturnSchemaInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleNone_operationsAbsolutePath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleNone_operationsRelativeSubpathNil_shouldReturnInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleNone_operationsRelativeSubpath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleOther_operationsInSchemaModule_shouldReturnSchemaInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .other, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleOther_operationsAbsolutePath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .other, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleOther_operationsRelativeSubpathNil_shouldReturnInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .other, operations: .relative(subpath: nil))

    let expected = directoryURL
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetCustomScalar_when_moduleOther_operationsRelativeSubpath_shouldReturnInputObjectsSubpath() {
    // given
    subject = .customScalar

    // when
    buildConfig(module: .other, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .appendingPathComponent("CustomScalars")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  // MARK: .schema

  func test__resolvePath__givenFileTargetSchema_when_moduleSwiftPackageManager_operationsInSchemaModule_shouldReturnSchemaSubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .swiftPackageManager, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetSchema_when_moduleSwiftPackageManager_operationsAbsolutePath_shouldReturnEmptySubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .swiftPackageManager, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetSchema_when_moduleSwiftPackageManager_operationsRelativeSubpathNil_shouldReturnEmptySubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: nil))

    let expected = directoryURL
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetSchema_when_moduleSwiftPackageManager_operationsRelativeSubpath_shouldReturnEmptySubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetSchema_when_moduleNone_operationsInSchemaModule_shouldReturnSchemaSubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetSchema_when_moduleNone_operationsAbsolutePath_shouldReturnEmptySubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetSchema_when_moduleNone_operationsRelativeSubpathNil_shouldReturnEmptySubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: nil))

    let expected = directoryURL
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetSchema_when_moduleNone_operationsRelativeSubpath_shouldReturnEmptySubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetSchema_when_moduleOther_operationsInSchemaModule_shouldReturnSchemaSubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .other, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Schema")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetSchema_when_moduleOther_operationsAbsolutePath_shouldReturnEmptySubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .other, operations: .absolute(path: "NewPath"))

    let expected = directoryURL
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetSchema_when_moduleOther_operationsRelativeSubpathNil_shouldReturnEmptySubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .other, operations: .relative(subpath: nil))

    let expected = directoryURL
      .standardizedFileURL.path
    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetSchema_when_moduleOther_operationsRelativeSubpath_shouldReturnEmptySubpath() {
    // given
    subject = .schema

    // when
    buildConfig(module: .other, operations: .relative(subpath: "NewPath"))

    let expected = directoryURL
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  // MARK: .fragment

  func test__resolvePath__givenFileTargetFragment_when_moduleSwiftPackageManager_operationsInSchemaModule_shouldReturnOperationsSubpath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    buildConfig(module: .swiftPackageManager, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Operations")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetFragment_when_moduleSwiftPackageManager_operationsAbsolutePath_shouldReturnAbsolutePath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    let path = "New/Path"
    buildConfig(module: .swiftPackageManager, operations: .absolute(path: path))

    // then
    let actual = resolvePath()

    expect(actual).to(equal(path))
  }

  func test__resolvePath__givenFileTargetFragment_when_moduleSwiftPackageManager_operationsRelativeSubpathNil_shouldReturnFilePath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: nil))

    let expected = deleteLastPathComponent(irFragment.definition.filePath)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetFragment_when_moduleSwiftPackageManager_operationsRelativeSubpath_shouldReturnRelativeSubpath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    let path = "NewPath"
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: path))

    let expected = deleteLastPathComponent(irFragment.definition.filePath, appending: path)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetFragment_when_moduleNone_operationsInSchemaModule_shouldReturnOperationsSubpath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Operations")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetFragment_when_moduleNone_operationsAbsolutePath_shouldReturnAbsoluteSubpath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    let path = "New/Path"
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .absolute(path: path))

    // then
    let actual = resolvePath()

    expect(actual).to(equal(path))
  }

  func test__resolvePath__givenFileTargetFragment_when_moduleNone_operationsRelativeSubpathNil_shouldReturnFilePath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: nil))

    let expected = deleteLastPathComponent(irFragment.definition.filePath)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetFragment_when_moduleNone_operationsRelativeSubpath_shouldReturnRelativeSubpath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    let path = "NewPath"

    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: path))

    let expected = deleteLastPathComponent(irFragment.definition.filePath, appending: path)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetFragment_when_moduleOther_operationsInSchemaModule_shouldReturnOperationsSubpath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    buildConfig(module: .other, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Operations")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetFragment_when_moduleOther_operationsAbsolutePath_shouldReturnAbsoluteSubpath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    let path = "New/Path"

    buildConfig(module: .other, operations: .absolute(path: path))

    // then
    let actual = resolvePath()

    expect(actual).to(equal(path))
  }

  func test__resolvePath__givenFileTargetFragment_when_moduleOther_operationsRelativeSubpathNil_shouldReturnFilePath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    buildConfig(module: .other, operations: .relative(subpath: nil))

    let expected = deleteLastPathComponent(irFragment.definition.filePath)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetFragment_when_moduleOther_operationsRelativeSubpath_shouldReturnRelativeSubpath() throws {
    // given
    try buildIR()
    subject = .fragment(irFragment.definition)

    // when
    let path = "NewPath"

    buildConfig(module: .other, operations: .relative(subpath: path))

    let expected = deleteLastPathComponent(irFragment.definition.filePath, appending: path)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  // MARK: .operation

  func test__resolvePath__givenFileTargetOperation_when_moduleSwiftPackageManager_operationsInSchemaModule_shouldReturnOperationsSubpath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    buildConfig(module: .swiftPackageManager, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Operations")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetOperation_when_moduleSwiftPackageManager_operationsAbsolutePath_shouldReturnAbsolutePath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    let path = "New/Path"
    buildConfig(module: .swiftPackageManager, operations: .absolute(path: path))

    // then
    let actual = resolvePath()

    expect(actual).to(equal(path))
  }

  func test__resolvePath__givenFileTargetOperation_when_moduleSwiftPackageManager_operationsRelativeSubpathNil_shouldReturnFilePath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: nil))

    let expected = deleteLastPathComponent(irOperation.definition.filePath)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetOperation_when_moduleSwiftPackageManager_operationsRelativeSubpath_shouldReturnRelativeSubpath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    let path = "NewPath"
    buildConfig(module: .swiftPackageManager, operations: .relative(subpath: path))

    let expected = deleteLastPathComponent(irOperation.definition.filePath, appending: path)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetOperation_when_moduleNone_operationsInSchemaModule_shouldReturnOperationsSubpath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Operations")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetOperation_when_moduleNone_operationsAbsolutePath_shouldReturnAbsoluteSubpath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    let path = "New/Path"
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .absolute(path: path))

    // then
    let actual = resolvePath()

    expect(actual).to(equal(path))
  }

  func test__resolvePath__givenFileTargetOperation_when_moduleNone_operationsRelativeSubpathNil_shouldReturnFilePath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: nil))

    let expected = deleteLastPathComponent(irOperation.definition.filePath)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetOperation_when_moduleNone_operationsRelativeSubpath_shouldReturnRelativeSubpath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    let path = "NewPath"

    buildConfig(module: .embeddedInTarget(name: "MockApplication"), operations: .relative(subpath: path))

    let expected = deleteLastPathComponent(irOperation.definition.filePath, appending: path)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetOperation_when_moduleOther_operationsInSchemaModule_shouldReturnOperationsSubpath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    buildConfig(module: .other, operations: .inSchemaModule)

    let expected = directoryURL
      .appendingPathComponent("Operations")
      .standardizedFileURL.path

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetOperation_when_moduleOther_operationsAbsolutePath_shouldReturnAbsoluteSubpath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    let path = "New/Path"

    buildConfig(module: .other, operations: .absolute(path: path))

    // then
    let actual = resolvePath()

    expect(actual).to(equal(path))
  }

  func test__resolvePath__givenFileTargetOperation_when_moduleOther_operationsRelativeSubpathNil_shouldReturnFilePath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    buildConfig(module: .other, operations: .relative(subpath: nil))

    let expected = deleteLastPathComponent(irOperation.definition.filePath)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetOperation_when_moduleOther_operationsRelativeSubpath_shouldReturnRelativeSubpath() throws {
    // given
    try buildIR()
    subject = .operation(irOperation.definition)

    // when
    let path = "NewPath"

    buildConfig(module: .other, operations: .relative(subpath: path))

    let expected = deleteLastPathComponent(irOperation.definition.filePath, appending: path)

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

  // MARK: .testMock

  func test__resolvePath__givenFileTargetTestMock_when_moduleSwiftPackageManager_mocksInSwiftPackage_shouldReturn_____________() {
    fail()
//    // given
//    subject = .testMock
//
//    // when
//    buildConfig(module: .swiftPackageManager, operations: .inSchemaModule)
//
//    let expected = directoryURL
//      .appendingPathComponent("Schema")
//      .appendingPathComponent("Objects")
//      .standardizedFileURL.path
//
//    // then
//    let actual = resolvePath()
//
//    expect(actual).to(equal(expected))
  }

  func test__resolvePath__givenFileTargetTestMock_mocksAbsolutePath_shouldReturnPath() {
    // given
    subject = .testMock

    let expected = directoryURL
      .appendingPathComponent("AbsoluteTestMocks")
      .standardizedFileURL.path

    // when
    buildConfig(
      module: .embeddedInTarget(name: "MockApplication"),
      operations: .inSchemaModule,
      testMocks: .absolute(path: expected)
    )

    // then
    let actual = resolvePath()

    expect(actual).to(equal(expected))
  }

}

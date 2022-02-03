import XCTest
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib
import Nimble

class ApolloCodegenConfiguration_ResolvePath_Tests: XCTestCase {
  let directoryURL = CodegenTestHelper.outputFolderURL()

  var config: ApolloCodegenConfiguration.FileOutput!

  private func buildOutputConfig(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = .manuallyLinked(namespace: "TestAPI"),
    operations: ApolloCodegenConfiguration.OperationsFileOutput
  ) {
    config = .mock(moduleType: moduleType, operations: operations, path: directoryURL.path)
  }

  // MARK: OperationsFileOutput.relative
  //
  // <graphql path>/file.swift
  // <schema path>/<NamedType>/file.swift

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSchemaObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let expected: String = directoryURL.appendingPathComponent("Objects").path

    //when
    let actual = config.resolvePath(.object)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSchemaEnumToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let expected: String = directoryURL.appendingPathComponent("Enums").path

    //when
    let actual = config.resolvePath(.enum)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSchemaInterfaceToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let expected: String = directoryURL.appendingPathComponent("Interfaces").path

    //when
    let actual = config.resolvePath(.interface)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSchemaUnionToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let expected: String = directoryURL.appendingPathComponent("Unions").path

    //when
    let actual = config.resolvePath(.union)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSchemaInputObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let expected: String = directoryURL.appendingPathComponent("InputObjects").path

    //when
    let actual = config.resolvePath(.inputObject)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputOperationToRelativeSubpath() throws {
    XCTFail()
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputFragmentToRelativeSubpath() throws {
    XCTFail()
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSchemaObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let expected: String = directoryURL.appendingPathComponent("Objects").path

    //when
    let actual = config.resolvePath(.object)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSchemaEnumToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let expected: String = directoryURL.appendingPathComponent("Enums").path

    //when
    let actual = config.resolvePath(.enum)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSchemaInterfaceToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let expected: String = directoryURL.appendingPathComponent("Interfaces").path

    //when
    let actual = config.resolvePath(.interface)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSchemaUnionToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let expected: String = directoryURL.appendingPathComponent("Unions").path

    //when
    let actual = config.resolvePath(.union)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSchemaInputObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let expected: String = directoryURL.appendingPathComponent("InputObjects").path

    //when
    let actual = config.resolvePath(.inputObject)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputOperationToRelativePath() throws {
    XCTFail()
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputFragmentToRelativePath() throws {
    XCTFail()
  }

  // MARK: OperationsFileOutput.absolute
  //
  // <absolute path>/file.swift
  // <schema path>/<NamedType>/file.swift

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSchemaObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let expected: String = directoryURL.appendingPathComponent("Objects").path

    //when
    let actual = config.resolvePath(.object)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSchemaEnumToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let expected: String = directoryURL.appendingPathComponent("Enums").path

    //when
    let actual = config.resolvePath(.enum)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSchemaInterfaceToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let expected: String = directoryURL.appendingPathComponent("Interfaces").path

    //when
    let actual = config.resolvePath(.interface)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSchemaUnionToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let expected: String = directoryURL.appendingPathComponent("Unions").path

    //when
    let actual = config.resolvePath(.union)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSchemaInputObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let expected: String = directoryURL.appendingPathComponent("InputObjects").path

    //when
    let actual = config.resolvePath(.inputObject)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputOperationToAbsolutePath() throws {
    XCTFail()
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputFragmentToAbsolutePath() throws {
    XCTFail()
  }

  // MARK: OperationsFileOutput.inSchemaModule
  //
  // <schema path> /Operations/file.swift /Fragments/file.swift
  // <schema path>/AnimalKingdomAPI/<NamedType>/file.swift

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSchemaObjectToSchemaSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let expected: String = directoryURL.appendingPathComponent("TestAPI/Objects").path

    //when
    let actual = config.resolvePath(.object)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSchemaEnumToSchemaSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let expected: String = directoryURL.appendingPathComponent("TestAPI/Enums").path

    //when
    let actual = config.resolvePath(.enum)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSchemaInterfaceToSchemaSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let expected: String = directoryURL.appendingPathComponent("TestAPI/Interfaces").path

    //when
    let actual = config.resolvePath(.interface)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSchemaUnionToSchemaSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let expected: String = directoryURL.appendingPathComponent("TestAPI/Unions").path

    //when
    let actual = config.resolvePath(.union)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSchemaInputObjectToSchemaSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let expected: String = directoryURL.appendingPathComponent("TestAPI/InputObjects").path

    //when
    let actual = config.resolvePath(.inputObject)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputOperationToAbsoluteSubpath() throws {
    XCTFail()
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputFragmentToAbsoluteSubpath() throws {
    XCTFail()
  }
}

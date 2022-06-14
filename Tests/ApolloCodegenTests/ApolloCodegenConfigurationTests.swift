import XCTest
@testable import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib
import Nimble

class ApolloCodegenConfigurationTests: XCTestCase {
  let directoryURL = CodegenTestHelper.outputFolderURL().appendingPathComponent("Configuration")

  var filename: String!
  var fileURL: URL!
  var input: ApolloCodegenConfiguration.FileInput!
  var output: ApolloCodegenConfiguration.FileOutput!
  var config: ApolloCodegenConfiguration!

  // MARK: Lifecycle

  override func setUpWithError() throws {
    try super.setUpWithError()
    try FileManager.default.apollo.createDirectoryIfNeeded(atPath: directoryURL.path)

    filename = UUID().uuidString
    fileURL = directoryURL.appendingPathComponent(filename)

    input = .init(schemaPath: fileURL.path)
    output = .init(schemaTypes: .init(path: directoryURL.path, moduleType: .embeddedInTarget(name: "MockApplication")))
  }

  override func tearDownWithError() throws {
    config = nil
    output = nil
    input = nil
    fileURL = nil
    filename = nil

    try FileManager.default.apollo.deleteDirectory(atPath: directoryURL.path)
    try super.tearDownWithError()
  }

  // MARK: Test Helpers

  func buildConfig() {
    config = ApolloCodegenConfiguration.mock(      
      input: input,
      output: output
    )
  }

  // MARK: Initializer Tests

  func test__initializer__givenMinimalFileInput_buildsDefaults() {
    // given
    let input = ApolloCodegenConfiguration.FileInput(schemaPath: fileURL.path)

    // then
    expect(input.searchPaths).to(equal(["**/*.graphql"]))
  }

  func test__initializer__givenMinimalFileOutput_buildsCorrectDefaults() {
    // given
    let output = ApolloCodegenConfiguration.FileOutput(
      schemaTypes: .init(path: directoryURL.path, moduleType: .other)
    )

    // then
    expect(output.operationIdentifiersPath).to(beNil())
    expect(output.operations).to(equal(.relative(subpath: nil)))
  }

  func test__initializer__givenMinimalApolloCodegenConfiguration_buildsCorrectDefaults() {
    // given
    let config = ApolloCodegenConfiguration(
      schemaName: "MockSchema",
      input: .init(schemaPath: fileURL.path),
      output: .init(schemaTypes: .init(path: directoryURL.path, moduleType: .other))
    )

    // then
    expect(config.options.additionalInflectionRules).to(beEmpty())
    expect(config.options.queryStringLiteralFormat).to(equal(.multiline))
    expect(config.options.deprecatedEnumCases).to(equal(.include))
    expect(config.options.schemaDocumentation).to(equal(.include))
    expect(config.options.apqs).to(equal(.disabled))
  }

  // MARK: Validation Tests

  func test_validation_givenSchemaFilename_doesNotExist_shouldThrow() throws {
    // given
    buildConfig()

    // then
    expect { try self.config.validate() }.to(
      throwError(ApolloCodegenConfiguration.Error.notAFile(.schema))
    )
  }

  func test_validation_givenSchemaPath_doesNotExist_shouldThrow() throws {
    // given
    buildConfig()

    // then
    expect { try self.config.validate() }.to(
      throwError(ApolloCodegenConfiguration.Error.notAFile(.schema))
    )
  }

  func test_validation_givenSchemaPath_isDirectory_shouldThrow() throws {
    // given
    input = .init(schemaPath: directoryURL.path)

    buildConfig()

    // then
    expect { try self.config.validate() }.to(
      throwError(ApolloCodegenConfiguration.Error.notAFile(.schema))
    )
  }

  func test_validation_givenSchemaTypesPath_isFile_shouldThrow() throws {
    // given
    output = .init(schemaTypes: .init(path: fileURL.path, moduleType: .embeddedInTarget(name: "MockApplication")))

    buildConfig()

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try self.config.validate() }.to(
      throwError(ApolloCodegenConfiguration.Error.notADirectory(.schemaTypes))
    )
  }

  func test_validation_givenSchemaTypesPath_isInvalidPath_shouldThrow() throws {
    // given
    let invalidURL = fileURL.appendingPathComponent("nested")
    output = .init(schemaTypes: .init(path: invalidURL.path, moduleType: .embeddedInTarget(name: "MockApplication")))

    buildConfig()

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try self.config.validate() }.to(
      throwError { error in
        guard case let ApolloCodegenConfiguration.Error
                .folderCreationFailed(pathType, _) = error else {
                  fail()
                  return
                }
        expect(pathType).to(equal(.schemaTypes))
      }
    )
  }

  func test_validation_givenOperations_absolutePath_isFile_shouldThrow() throws {
    // given
    output = .init(
      schemaTypes: .init(path: directoryURL.path, moduleType: .embeddedInTarget(name: "MockApplication")),
      operations: .absolute(path: fileURL.path)
    )

    buildConfig()

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try self.config.validate() }.to(
      throwError(ApolloCodegenConfiguration.Error.notADirectory(.operations))
    )
  }

  func test_validation_givenOperations_absolutePath_isInvalidPath_shouldThrow() throws {
    // given
    let invalidURL = fileURL.appendingPathComponent("nested")

    output = .init(
      schemaTypes: .init(path: directoryURL.path, moduleType: .embeddedInTarget(name: "MockApplication")),
      operations: .absolute(path: invalidURL.path)
    )

    buildConfig()

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try self.config.validate() }.to(
      throwError { error in
        guard case let ApolloCodegenConfiguration.Error
                .folderCreationFailed(pathType, _) = error else {
                  fail()
                  return
                }
        expect(pathType).to(equal(.operations))
      }
    )
  }

  // failing - operations identifier output path as directory
  func test_validation_givenOperationIdentifiersPath_isDirectory_shouldThrow() throws {
    // given
    output = .init(
      schemaTypes: .init(path: directoryURL.path, moduleType: .embeddedInTarget(name: "MockApplication")),
      operations: .relative(subpath: nil),
      operationIdentifiersPath: directoryURL.path
    )

    buildConfig()

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try self.config.validate() }.to(
      throwError(ApolloCodegenConfiguration.Error.notAFile(.operationIdentifiers))
    )
  }

  // failing - test mocks in swift package with no swift package schema module
  func test_validation_givenTestMocks_swiftPackage_schemaModuleTypeNotSwiftPackageManager_shouldThrow() throws {
    // given
    output = .init(
      schemaTypes: .init(path: directoryURL.path, moduleType: .embeddedInTarget(name: "MockApplication")),
      operations: .relative(subpath: nil),
      testMocks: .swiftPackage()
    )

    buildConfig()

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try self.config.validate() }.to(
      throwError(ApolloCodegenConfiguration.Error.testMocksInvalidSwiftPackageConfiguration)
    )
  }
}

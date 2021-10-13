import XCTest
import ApolloCodegenTestSupport
import ApolloCodegenLib
import Nimble

class ApolloCodegenConfigurationTests: XCTestCase {
  let directoryURL = CodegenTestHelper.outputFolderURL().appendingPathComponent("Configuration")

  override func setUpWithError() throws {
    try FileManager.default.apollo.createFolderIfNeeded(at: directoryURL)
  }

  override func tearDownWithError() throws {
    try FileManager.default.apollo.deleteFolder(at: directoryURL)
  }

  func test_init_givenBasePathAndSchemaFilename_shouldBuildDefaultPaths() {
    // given
    let filename = "could_be_anything"
    let expectedSchemaURL = directoryURL.appendingPathComponent(filename)
    let config = ApolloCodegenConfiguration(basePath: directoryURL.path, schemaFilename: filename)

    // then
    expect(config.input.schemaPath).to(
      match(expectedSchemaURL.path)
    )
    expect(config.output.schemaTypes.path).to(match(directoryURL.path))
  }

  func test_validation_givenSchemaFilename_doesNotExist_shouldThrow() throws {
    // given
    let filename = UUID().uuidString
    let config = ApolloCodegenConfiguration(basePath: directoryURL.path, schemaFilename: filename)

    // then
    expect { try ApolloCodegen.build(with: config) }.to(
      throwError(ApolloCodegen.Error.pathNotFound(config.input.schemaPath))
    )
  }

  func test_validation_givenSchemaPath_doesNotExist_shouldThrow() throws {
    // given
    let schemaPath = directoryURL.appendingPathComponent(UUID().uuidString)
    let config = ApolloCodegenConfiguration(input: .init(schemaPath: schemaPath.path),
                                            output: .init(schemaTypes: .init(path: directoryURL.path)))

    // then
    expect { try ApolloCodegen.build(with: config) }.to(
      throwError(ApolloCodegen.Error.pathNotFound(config.input.schemaPath))
    )
  }

  func test_validation_givenSchemaPath_isDirectory_shouldThrow() throws {
    // given
    let config = ApolloCodegenConfiguration(input: .init(schemaPath: directoryURL.path),
                                            output: .init(schemaTypes: .init(path: directoryURL.path)))

    // then
    expect { try ApolloCodegen.build(with: config) }.to(
      throwError(ApolloCodegen.Error.pathNotAFile(config.input.schemaPath))
    )
  }

  func test_validation_givenSchemaFilename_doesExist_shouldNotThrow() throws {
    // given
    let filename = UUID().uuidString
    let config = ApolloCodegenConfiguration(basePath: directoryURL.path, schemaFilename: filename)

    // when
    let expectedSchemaURL = directoryURL.appendingPathComponent(filename)
    try FileManager.default.apollo.createFile(at: expectedSchemaURL)

    // then
    expect { try ApolloCodegen.build(with:config) }.notTo(throwError())
  }

  func test_validation_givenSchemaPath_doesExist_shouldNotThrow() throws {
    // given
    let schemaURL = directoryURL.appendingPathComponent(UUID().uuidString)
    let config = ApolloCodegenConfiguration(input: .init(schemaPath: schemaURL.path),
                                            output: .init(schemaTypes: .init(path: directoryURL.path)))

    // when
    try FileManager.default.apollo.createFile(at: schemaURL)

    // then
    expect { try ApolloCodegen.build(with:config) }.notTo(throwError())
  }
}

import XCTest
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib
import Nimble

class ApolloCodegenConfigurationTests: XCTestCase {
  let directoryURL = CodegenTestHelper.outputFolderURL().appendingPathComponent("Configuration")

  override func setUpWithError() throws {
    try FileManager.default.apollo.createDirectoryIfNeeded(atPath: directoryURL.path)
  }

  override func tearDownWithError() throws {
    try FileManager.default.apollo.deleteDirectory(atPath: directoryURL.path)
  }

  func test_init_givenBasePathAndSchemaFilename_shouldBuildDefaultPaths() {
    // given
    let schemafilename = "could_be_anything"
    let includeFilename = "file.ext"
    let expectedSchemaURL = directoryURL.appendingPathComponent(schemafilename)
    let expectedIncludeURL = directoryURL.appendingPathComponent(includeFilename)
    let config = ApolloCodegenConfiguration(basePath: directoryURL.path,
                                            schemaFilename: schemafilename,
                                            searchPattern: includeFilename)

    // then
    expect(config.input.schemaPath).to(equal(expectedSchemaURL.path))
    expect(config.input.searchPaths).to(equal([expectedIncludeURL.path]))
    expect(config.output.schemaTypes.path).to(equal(directoryURL.path))
  }

  func test_validation_givenSchemaFilename_doesNotExist_shouldThrow() throws {
    // given
    let filename = UUID().uuidString
    let config = ApolloCodegenConfiguration(basePath: directoryURL.path, schemaFilename: filename)

    // then
    expect { try config.validate() }.to(
      throwError(ApolloCodegenConfiguration.PathError.notAFile(.schema))
    )
  }

  func test_validation_givenSchemaPath_doesNotExist_shouldThrow() throws {
    // given
    let schemaPath = directoryURL.appendingPathComponent(UUID().uuidString)
    let config = ApolloCodegenConfiguration(input: .init(schemaPath: schemaPath.path,
                                                         searchPaths: ["**/*.graphql"]),
                                            output: .init(schemaTypes: .init(path: directoryURL.path)))

    // then
    expect { try config.validate() }.to(
      throwError(ApolloCodegenConfiguration.PathError.notAFile(.schema))
    )
  }

  func test_validation_givenSchemaPath_isDirectory_shouldThrow() throws {
    // given
    let config = ApolloCodegenConfiguration(input: .init(schemaPath: directoryURL.path,
                                                         searchPaths: ["**/*.graphql"]),
                                            output: .init(schemaTypes: .init(path: directoryURL.path)))

    // then
    expect { try config.validate() }.to(
      throwError(ApolloCodegenConfiguration.PathError.notAFile(.schema))
    )
  }

  func test_validation_givenSchemaTypesPath_isFile_shouldThrow() throws {
    // given
    let fileURL = directoryURL.appendingPathComponent(UUID().uuidString)
    let config = ApolloCodegenConfiguration(input: .init(schemaPath: fileURL.path,
                                                         searchPaths: ["**/*.graphql"]),
                                            output: .init(schemaTypes: .init(path: fileURL.path)))

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try config.validate() }.to(
      throwError(ApolloCodegenConfiguration.PathError.notADirectory(.schemaTypes))
    )
  }

  func test_validation_givenSchemaTypesPath_isInvalidPath_shouldThrow() throws {
    // given
    let fileURL = directoryURL.appendingPathComponent(UUID().uuidString)
    let invalidURL = fileURL.appendingPathComponent("nested")
    let config = ApolloCodegenConfiguration(input: .init(schemaPath: fileURL.path,
                                                         searchPaths: ["**/*.graphql"]),
                                            output: .init(schemaTypes: .init(path: invalidURL.path)))

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try config.validate() }.to(
      throwError { error in
        guard case let ApolloCodegenConfiguration.PathError
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
    let fileURL = directoryURL.appendingPathComponent(UUID().uuidString)
    let config = ApolloCodegenConfiguration(input: .init(schemaPath: fileURL.path,
                                                         searchPaths: ["**/*.graphql"]),
                                            output: .init(schemaTypes: .init(path: directoryURL.path),
                                                          operations: .absolute(path: fileURL.path),
                                                          operationIdentifiersPath: nil))

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try config.validate() }.to(
      throwError(ApolloCodegenConfiguration.PathError.notADirectory(.operations))
    )
  }

  func test_validation_givenOperations_absolutePath_isInvalidPath_shouldThrow() throws {
    // given
    let fileURL = directoryURL.appendingPathComponent(UUID().uuidString)
    let invalidURL = fileURL.appendingPathComponent("nested")
    let config = ApolloCodegenConfiguration(input: .init(schemaPath: fileURL.path,
                                                         searchPaths: ["**/*.graphql"]),
                                            output: .init(schemaTypes: .init(path: directoryURL.path),
                                                          operations: .absolute(path: invalidURL.path),
                                                          operationIdentifiersPath: nil))

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try config.validate() }.to(
      throwError { error in        
        guard case let ApolloCodegenConfiguration.PathError
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
    let fileURL = directoryURL.appendingPathComponent(UUID().uuidString)
    let config = ApolloCodegenConfiguration(input: .init(schemaPath: fileURL.path,
                                                         searchPaths: ["**/*.graphql"]),
                                            output: .init(schemaTypes: .init(path: directoryURL.path),
                                                          operations: .relative(subpath: nil),
                                                          operationIdentifiersPath: directoryURL.path))

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try config.validate() }.to(
      throwError(ApolloCodegenConfiguration.PathError.notAFile(.operationIdentifiers))
    )
  }

  func test_validation_givenValidConfiguration_convenienceInitializer_shouldNotThrow() throws {
    // given
    let filename = UUID().uuidString
    let config = ApolloCodegenConfiguration(basePath: directoryURL.path, schemaFilename: filename)

    // when
    let expectedSchemaURL = directoryURL.appendingPathComponent(filename)
    try FileManager.default.apollo.createFile(atPath: expectedSchemaURL.path)

    // then
    expect { try config.validate() }.notTo(throwError())
  }

  func test_validation_givenValidConfiguration_designatedInitializer_shouldNotThrow() throws {
    // given
    let fileURL = directoryURL.appendingPathComponent(UUID().uuidString)
    let config = ApolloCodegenConfiguration(input: .init(schemaPath: fileURL.path,
                                                         searchPaths: ["**/*.graphql"]),
                                            output: .init(schemaTypes: .init(path: directoryURL.path),
                                                          operations: .absolute(path: directoryURL.path),
                                                          operationIdentifiersPath: fileURL.path))

    // when
    try FileManager.default.apollo.createFile(atPath: fileURL.path)

    // then
    expect { try config.validate() }.notTo(throwError())
  }
}

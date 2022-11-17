import XCTest
import Nimble
@testable import CodegenCLI
import ArgumentParser
import ApolloCodegenLib

class FetchSchemaTests: XCTestCase {

  // MARK: - Test Helpers

  func parse(_ options: [String]?) throws -> FetchSchema {
    try FetchSchema.parse(options)
  }

  // MARK: - Parsing Tests

  func test__parsing__givenParameters_none_shouldUseDefaults() throws {
    // when
    let command = try parse([])

    // then
    expect(command.inputs.path).to(equal(Constants.defaultFilePath))
    expect(command.inputs.string).to(beNil())
    expect(command.inputs.verbose).to(beFalse())
  }

  // MARK: - FetchSchema Tests

  func test__fetchSchema__givenParameters_pathCustom_shouldBuildWithFileData() throws {
    // given
    let inputPath = "./config.json"

    let options = [
      "--path=\(inputPath)"
    ]

    let mockConfiguration = ApolloCodegenConfiguration.mock()
    let mockFileManager = MockApolloFileManager(strict: true)

    mockFileManager.mock(closure: .contents({ path in
      let actualPath = URL(fileURLWithPath: path).standardizedFileURL.path
      let expectedPath = URL(fileURLWithPath: inputPath).standardizedFileURL.path

      expect(actualPath).to(equal(expectedPath))

      return try! JSONEncoder().encode(mockConfiguration)
    }))

    var didCallFetch = false
    MockApolloSchemaDownloader.fetchHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration.schemaDownloadConfiguration))

      didCallFetch = true
    }

    // when
    let command = try parse(options)

    try command._run(
      fileManager: mockFileManager.base,
      schemaDownloadProvider: MockApolloSchemaDownloader.self
    )

    // then
    expect(didCallFetch).to(beTrue())
  }

  func test__fetchSchema__givenParameters_stringCustom_shouldBuildWithStringData() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)"
    ]

    var didCallFetch = false
    MockApolloSchemaDownloader.fetchHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration.schemaDownloadConfiguration))

      didCallFetch = true
    }

    // when
    let command = try parse(options)

    try command._run(schemaDownloadProvider: MockApolloSchemaDownloader.self)

    // then
    expect(didCallFetch).to(beTrue())
  }

  func test__fetchSchema__givenParameters_bothPathAndString_shouldBuildWithStringData() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--path=./path/to/file",
      "--string=\(jsonString)"
    ]

    var didCallFetch = false
    MockApolloSchemaDownloader.fetchHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration.schemaDownloadConfiguration))

      didCallFetch = true
    }

    // when
    let command = try parse(options)

    try command._run(schemaDownloadProvider: MockApolloSchemaDownloader.self)

    // then
    expect(didCallFetch).to(beTrue())
  }

  func test__fetchSchema__givenDefaultParameter_verbose_shouldSetLogLevelWarning() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)"
    ]

    MockApolloSchemaDownloader.fetchHandler = { configuration in }

    var level: CodegenLogger.LogLevel?
    MockLogLevelSetter.levelHandler = { value in
      level = value
    }

    // when
    let command = try parse(options)

    try command._run(
      schemaDownloadProvider: MockApolloSchemaDownloader.self,
      logger: CodegenLogger.mock
    )

    // then
    expect(level).toEventually(equal(.warning))
  }

  func test__fetchSchema__givenParameter_verbose_shouldSetLogLevelDebug() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)",
      "--verbose"
    ]

    MockApolloSchemaDownloader.fetchHandler = { configuration in }

    var level: CodegenLogger.LogLevel?
    MockLogLevelSetter.levelHandler = { value in
      level = value
    }

    // when
    let command = try parse(options)

    try command._run(
      schemaDownloadProvider: MockApolloSchemaDownloader.self,
      logger: CodegenLogger.mock
    )

    // then
    expect(level).toEventually(equal(.debug))
  }
}

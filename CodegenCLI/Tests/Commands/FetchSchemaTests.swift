import XCTest
import Nimble
@testable import apollo_ios_cli
import ArgumentParser
import ApolloCodegenLib

class FetchSchemaTests: XCTestCase {

  // MARK: - Test Helpers

  func parseAsRoot(options: [String]?) throws -> FetchSchema {
    try CodegenCLI.parseAsRoot(options) as! FetchSchema
  }

  // MARK: - Parsing Tests

  func test__parsing__givenParameters_none_shouldUseDefaults() throws {
    // given
    let options = ["fetch-schema"]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.inputs.path).to(equal(Constants.defaultFilePath))
    expect(command.inputs.string).to(beNil())
  }

  func test__parsing__givenParameters_pathLongFormat_shouldParse() throws {
    // given
    let path = "/custom/path"

    let options = [
      "fetch-schema",
      "--path=\(path)"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.inputs.path).to(equal(path))
  }

  func test__parsing__givenParameters_pathShortFormat_shouldParse() throws {
    // given
    let path = "/custom/path"

    let options = [
      "fetch-schema",
      "-p=\(path)"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.inputs.path).to(equal(path))
  }

  func test__parsing__givenParameters_stringLongFormat_shouldParse() throws {
    // given
    let string = "could-be-anything"

    let options = [
      "fetch-schema",
      "--string=\(string)"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.inputs.string).to(equal(string))
  }

  func test__parsing__givenParameters_stringShortFormat_shouldParse() throws {
    // given
    let string = "could-be-anything"

    let options = [
      "fetch-schema",
      "-s=\(string)"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.inputs.string).to(equal(string))
  }

  func test__parsing__givenParameters_unknown_shouldThrow() throws {
    // given
    let options = [
      "fetch-schema",
      "--unknown"
    ]

    // then
    expect(try self.parseAsRoot(options: options))
      .to(throwUnknownOptionError())
  }

  // MARK: - FetchSchema Tests

  func test__fetchSchema__givenParameters_pathCustom_shouldBuildWithFileData() throws {
    // given
    let inputPath = "./config.json"

    let options = [
      "fetch-schema",
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
    let command = try parseAsRoot(options: options)

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
      "fetch-schema",
      "--string=\(jsonString)"
    ]

    var didCallFetch = false
    MockApolloSchemaDownloader.fetchHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration.schemaDownloadConfiguration))

      didCallFetch = true
    }

    // when
    let command = try parseAsRoot(options: options)

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
      "fetch-schema",
      "--path=./path/to/file",
      "--string=\(jsonString)"
    ]

    var didCallFetch = false
    MockApolloSchemaDownloader.fetchHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration.schemaDownloadConfiguration))

      didCallFetch = true
    }

    // when
    let command = try parseAsRoot(options: options)

    try command._run(schemaDownloadProvider: MockApolloSchemaDownloader.self)

    // then
    expect(didCallFetch).to(beTrue())
  }
}

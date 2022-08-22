import XCTest
import Nimble
@testable import CodegenCLI
import ArgumentParser
import ApolloCodegenLib

class GenerateTests: XCTestCase {

  // MARK: - Test Helpers

  func parse(_ options: [String]?) throws -> Generate {
    try Generate.parse(options)
  }

  // MARK: - Parsing Tests

  func test__parsing__givenParameters_none_shouldUseDefaults() throws {
    // when
    let command = try parse([])

    // then
    expect(command.inputs.path).to(equal(Constants.defaultFilePath))
    expect(command.inputs.string).to(beNil())
  }

  func test__parsing__givenParameters_pathLongFormat_shouldParse() throws {
    // given
    let path = "/custom/path"

    let options = [
      "--path=\(path)"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.inputs.path).to(equal(path))
  }

  func test__parsing__givenParameters_pathShortFormat_shouldParse() throws {
    // given
    let path = "/custom/path"

    let options = [
      "-p=\(path)"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.inputs.path).to(equal(path))
  }

  func test__parsing__givenParameters_stringLongFormat_shouldParse() throws {
    // given
    let string = "could-be-anything"

    let options = [
      "--string=\(string)"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.inputs.string).to(equal(string))
  }

  func test__parsing__givenParameters_stringShortFormat_shouldParse() throws {
    // given
    let string = "could-be-anything"

    let options = [
      "-s=\(string)"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.inputs.string).to(equal(string))
  }

  func test__parsing__givenParameters_fetchSchemaLongFormat_shouldParse() throws {
    // given
    let options = [
      "--fetch-schema"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.fetchSchema).to(beTrue())
  }

  func test__parsing__givenParameters_fetchSchemaShortFormat_shouldParse() throws {
    // given
    let options = [
      "-f"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.fetchSchema).to(beTrue())
  }

  func test__parsing__givenParameters_unknown_shouldThrow() throws {
    // given
    let options = [
      "--unknown"
    ]

    // then
    expect(try self.parse(options))
      .to(throwUnknownOptionError())
  }

  // MARK: - Generate Tests

  func test__generate__givenParameters_pathCustom_shouldBuildWithFileData() throws {
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

    var didCallBuild = false
    MockApolloCodegen.buildHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration))

      didCallBuild = true
    }

    // when
    let command = try parse(options)

    try command._run(fileManager: mockFileManager.base, codegenProvider: MockApolloCodegen.self)

    // then
    expect(didCallBuild).to(beTrue())
  }

  func test__generate__givenParameters_stringCustom_shouldBuildWithStringData() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)"
    ]

    var didCallBuild = false
    MockApolloCodegen.buildHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration))

      didCallBuild = true
    }

    // when
    let command = try parse(options)

    try command._run(codegenProvider: MockApolloCodegen.self)

    // then
    expect(didCallBuild).to(beTrue())
  }

  func test__generate__givenParameters_bothPathAndString_shouldBuildWithStringData() throws {
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

    var didCallBuild = false
    MockApolloCodegen.buildHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration))

      didCallBuild = true
    }

    // when
    let command = try parse(options)

    try command._run(codegenProvider: MockApolloCodegen.self)

    // then
    expect(didCallBuild).to(beTrue())
  }

  func test__generate__givenParameters_fetchDefault_shouldNotFetchSchema() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)"
    ]

    var didCallBuild = false
    MockApolloCodegen.buildHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration))

      didCallBuild = true
    }

    var didCallFetch = false
    MockApolloSchemaDownloader.fetchHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration.schemaDownloadConfiguration))

      didCallFetch = true
    }

    // when
    let command = try parse(options)

    try command._run(
      codegenProvider: MockApolloCodegen.self,
      schemaDownloadProvider: MockApolloSchemaDownloader.self
    )

    // then
    expect(didCallBuild).to(beTrue())
    expect(didCallFetch).to(beFalse())
  }

  func test__generate__givenParameters_fetchTrue_shouldFetchSchema() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)",
      "--fetch-schema"
    ]

    var didCallBuild = false
    MockApolloCodegen.buildHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration))

      didCallBuild = true
    }

    var didCallFetch = false
    MockApolloSchemaDownloader.fetchHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration.schemaDownloadConfiguration))

      didCallFetch = true
    }

    // when
    let command = try parse(options)

    try command._run(
      codegenProvider: MockApolloCodegen.self,
      schemaDownloadProvider: MockApolloSchemaDownloader.self
    )

    // then
    expect(didCallBuild).to(beTrue())
    expect(didCallFetch).to(beTrue())
  }

  func test__generate__givenParameters_fetchTrue_whenNilSchemaDownloadConfiguration_shouldThrow() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.init(
      schemaName: "MockSchema",
      input: .init(
        schemaPath: "./schema.graphqls"
      ),
      output: .init(
        schemaTypes: .init(path: ".", moduleType: .swiftPackageManager)
      )
    )

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)",
      "--fetch-schema"
    ]

    var didCallBuild = false
    MockApolloCodegen.buildHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration))

      didCallBuild = true
    }

    var didCallFetch = false
    MockApolloSchemaDownloader.fetchHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration.schemaDownloadConfiguration))

      didCallFetch = true
    }

    // when
    let command = try parse(options)

    // then
    expect(try command._run(
      codegenProvider: MockApolloCodegen.self,
      schemaDownloadProvider: MockApolloSchemaDownloader.self
    )).to(throwError(
      localizedDescription: "Missing schema download configuration.",
      ignoringExtraCharacters: true
    ))

    expect(didCallBuild).to(beFalse())
    expect(didCallFetch).to(beFalse())
  }
}

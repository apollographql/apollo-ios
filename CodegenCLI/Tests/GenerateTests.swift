import XCTest
import Nimble
@testable import apollo_ios_codegen
import ArgumentParser
import ApolloCodegenLib

class GenerateTests: XCTestCase {

  // MARK: - Test Helpers

  func parseAsRoot(options: [String]?) throws -> Generate {
    try CodegenCLI.parseAsRoot(options) as! Generate
  }

  // MARK: - Parsing Tests

  func test__parsing__givenParameters_none_shouldUseDefaults() throws {
    // given
    let options = ["generate"]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.input).to(equal(.file))
    expect(command.path).to(equal(Constants.defaultFilePath))
    expect(command.string).to(beNil())
  }

  func test__parsing__givenParameters_inputLongFormat_shouldParse() throws {
    // given
    let options = [
      "generate",
      "--input=string",
      "--string=text"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.input).to(equal(.string))
  }

  func test__parsing__givenParameters_inputShortFormat_shouldParse() throws {
    // given
    let options = [
      "generate",
      "-i=string",
      "--string=text"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.input).to(equal(.string))
  }

  func test__parsing__givenParameters_pathLongFormat_shouldParse() throws {
    // given
    let path = "/custom/path"

    let options = [
      "generate",
      "--path=\(path)"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.path).to(equal(path))
  }

  func test__parsing__givenParameters_pathShortFormat_shouldParse() throws {
    // given
    let path = "/custom/path"

    let options = [
      "generate",
      "-p=\(path)"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.path).to(equal(path))
  }

  func test__parsing__givenParameters_stringLongFormat_shouldParse() throws {
    // given
    let string = "could-be-anything"

    let options = [
      "generate",
      "--string=\(string)"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.string).to(equal(string))
  }

  func test__parsing__givenParameters_stringShortFormat_shouldParse() throws {
    // given
    let string = "could-be-anything"

    let options = [
      "generate",
      "-s=\(string)"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.string).to(equal(string))
  }

  func test__parsing__givenParameters_inputString_stringNone_shouldThrow() throws {
    // given
    let options = [
      "generate",
      "--input=string"
    ]

    // then
    expect(
      try self.parseAsRoot(options: options)
    ).to(throwUserValidationError(
      ValidationError("Missing input string. Hint: --string cannot be empty and must be in JSON format.")
    ))
  }

  func test__parsing__givenParameters_unknown_shouldThrow() throws {
    // given
    let options = [
      "generate",
      "--unknown"
    ]

    // then
    expect(try self.parseAsRoot(options: options))
      .to(throwUnknownOptionError())
  }

  // MARK: - Generate Tests

  func test__generate__givenParameters_inputFile_pathCustom_shouldBuildWithFileData() throws {
    // given
    let inputPath = "./config.json"

    let options = [
      "generate",
      "--input=file",
      "--path=\(inputPath)"
    ]

    let mockConfiguration = ApolloCodegenConfiguration.mock()
    let mockFileManager = MockFileManager(strict: true)

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
    let command = try parseAsRoot(options: options)

    try command._run(fileManager: mockFileManager, codegenProvider: MockApolloCodegen.self)

    // then
    expect(didCallBuild).to(beTrue())
  }

  func test__generate__givenParameters_inputString_shouldBuildWithStringData() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "generate",
      "--input=string",
      "--string=\(jsonString)"
    ]

    var didCallBuild = false
    MockApolloCodegen.buildHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration))

      didCallBuild = true
    }

    // when
    let command = try parseAsRoot(options: options)

    try command._run(codegenProvider: MockApolloCodegen.self)

    // then
    expect(didCallBuild).to(beTrue())
  }
}

// MARK: - Private Extensions

fileprivate extension ApolloCodegenConfiguration {
  static func mock() -> Self {
    return self.init(
      schemaName: "MockSchema",
      input: .init(schemaPath: "./schema.graphqls"),
      output: .init(schemaTypes: .init(path: ".", moduleType: .swiftPackageManager))
    )
  }
}

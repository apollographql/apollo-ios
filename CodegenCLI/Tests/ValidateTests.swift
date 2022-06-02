import XCTest
import Nimble
@testable import apollo_ios_cli
import ArgumentParser
import ApolloCodegenLib

class ValidateTests: XCTestCase {

  // MARK: - Test Helpers

  func parseAsRoot(options: [String]?) throws -> Validate {
    try CodegenCLI.parseAsRoot(options) as! Validate
  }

  // MARK: - Parsing Tests

  func test__parsing__givenParameters_none_shouldUseDefaults() throws {
    // given
    let options = ["validate"]

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
      "validate",
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
      "validate",
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
      "validate",
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
      "validate",
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
      "validate",
      "--unknown"
    ]

    // then
    expect(try self.parseAsRoot(options: options))
      .to(throwUnknownOptionError())
  }

  // MARK: - Generate Tests

  func test__validate__givenParameters_pathCustom_shouldReadContentsFromPath() throws {
    // given
    let inputPath = "./config.file"

    let options = [
      "validate",
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

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(try command._run(fileManager: mockFileManager))
      .to(throwError { error in
        guard
          case let ApolloCodegenLib.ApolloCodegenConfiguration.Error.notAFile(path) = error,
          case ApolloCodegenLib.ApolloCodegenConfiguration.PathType.schema = path
        else {
          fail("Expected notAFile(schema) error, got \(error)")
          return
        }
      })

    expect(mockFileManager.allClosuresCalled).to(beTrue())
  }
}

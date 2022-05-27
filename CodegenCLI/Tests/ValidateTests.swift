import XCTest
import Nimble
@testable import apollo_ios_cli
import ArgumentParser

class ValidateTests: XCTestCase {

  // MARK: - Test Helpers

  func parseAsRoot(options: [String]?) throws -> Validate {
    try CodegenCLI.parseAsRoot(options) as! Validate
  }

  // MARK: - Parsing Tests

  func test__parsing__givenParameters_none_shouldThrow() throws {
    // given
    let options = ["validate"]

    // then
    expect(try self.parseAsRoot(options: options))
      .to(throwError())
  }

  func test__parsing__givenParameters_inputFile_pathNone_shouldThrow() throws {
    // given
    let options = [
      "validate",
      "--input=file"
    ]

    // then
    expect(
      try self.parseAsRoot(options: options)
    ).to(throwUserValidationError(
      ValidationError("Missing input file. Hint: --path cannot be empty and must be a JSON formatted configuration file.")
    ))
  }

  func test__parsing__givenParameters_inputString_stringNone_shouldThrow() throws {
    // given
    let options = [
      "validate",
      "--input=string"
    ]

    // then
    expect(
      try self.parseAsRoot(options: options)
    ).to(throwUserValidationError(
      ValidationError("Missing input string. Hint: --string cannot be empty and must be in JSON format.")
    ))
  }

  func test__parsing__givenParameters_inputLongFormat_shouldParse() throws {
    // given
    let options = [
      "validate",
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
      "validate",
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
      "validate",
      "--input=file",
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
      "validate",
      "--input=file",
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
      "validate",
      "--input=string",
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
      "validate",
      "--input=string",
      "-s=\(string)"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.string).to(equal(string))
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
}

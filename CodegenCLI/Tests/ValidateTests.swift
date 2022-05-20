import XCTest
import Nimble
@testable import apollo_ios_codegen
@testable import ArgumentParser

class ValidateTests: XCTestCase {

  // MARK: - Test Helpers

  func parse(options: [String]?) throws -> Validate {
    try CodegenCLI.parseAsRoot(options) as! Validate
  }

  // MARK: - Parsing Tests

  func test__parsing__givenPathShortFormat_shouldParse() throws {
    // given
    let path = "file.json"

    let options = [
      "validate",
      "-p=\(path)"
    ]

    // when
    let command = try parse(options: options)

    // then
    expect(command.path).to(equal(path))
    expect(command.json).to(beNil())
  }

  func test__parsing__givenPathLongFormat_shouldParse() throws {
    // given
    let path = "file.json"

    let options = [
      "validate",
      "--path=\(path)"
    ]

    // when
    let command = try parse(options: options)

    // then
    expect(command.path).to(equal(path))
    expect(command.json).to(beNil())
  }

  func test__parsing__givenJsonShortFormat_shouldParse() throws {
    // given
    let json = "a_string_of_json"

    let options = [
      "validate",
      "-j=\(json)"
    ]

    // when
    let command = try parse(options: options)

    // then
    expect(command.path).to(beNil())
    expect(command.json).to(equal(json))
  }

  func test__parsing__givenJsonLongFormat_shouldParse() throws {
    // given
    let json = "a_string_of_json"

    let options = [
      "validate",
      "--json=\(json)"
    ]

    // when
    let command = try parse(options: options)

    // then
    expect(command.path).to(beNil())
    expect(command.json).to(equal(json))
  }

  func test__parsing__givenNoOptions_shouldThrow() throws {
    // given
    let options = ["validate"]

    // then
    expect(try self.parse(options: options))
      .to(throwUserValidationError(
        ValidationError("You must specify at least one valid option.")
      ))
  }
#warning("Should we have tests for data validation?")
}

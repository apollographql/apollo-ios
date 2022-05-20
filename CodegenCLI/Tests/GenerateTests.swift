import XCTest
import Nimble
@testable import apollo_ios_codegen
@testable import ArgumentParser

class GenerateTests: XCTestCase {

  // MARK: - Test Helpers

  func parse(options: [String]?) throws -> Generate {
    try CodegenCLI.parseAsRoot(options) as! Generate
  }

  // MARK: - Parsing Tests

  func test__parsing__givenPathShortFormat_shouldParse() throws {
    // given
    let path = "file.json"

    let options = [
      "generate",
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
      "generate",
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
      "generate",
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
      "generate",
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
    let options = ["generate"]

    // then
    expect(try self.parse(options: options))
      .to(throwUserValidationError(
        ValidationError("You must specify a configuration source.")
      ))
  }

  func test__parsing__givenBothOptions_shouldThrow() throws {
    // given
    let options = [
      "generate",
      "--path=file.json",
      "--json=a_string_of_json"
    ]

    // then
    expect(try self.parse(options: options))
      .to(throwUserValidationError(
        ValidationError("You can only specify one configuration source.")
      ))
  }
#warning("Should we have tests for data validation?")
}

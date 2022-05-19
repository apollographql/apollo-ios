import XCTest
import Nimble
@testable import apollo_ios_codegen
@testable import ArgumentParser

class InitializeTests: XCTestCase {

  // MARK: - Test Helpers

  func parse(options: [String]?) throws -> Initialize {
    try CodegenCLI.parseAsRoot(options) as! Initialize
  }

  // MARK: - Parsing Tests

  func test__parsing__givenPath_shouldParse() throws {
    // given
    let path = "./config.json"

    let options = [
      "init",
      "--path=\(path)"
    ]

    // when
    let command = try parse(options: options)

    // then
    expect(command.path).to(equal(path))
    expect(command.print).to(beFalse())
  }

  func test__parsing__givenPrint_shouldParse() throws {
    // given
    let options = [
      "init",
      "--print"
    ]

    // when
    let command = try parse(options: options)

    // then
    expect(command.path).to(beNil())
    expect(command.print).to(beTrue())
  }

  func test__parsing__givenNoOptions_shouldThrow() throws {
    // given
    let options = ["init"]

    // then
    expect(try self.parse(options: options))
      .to(throwError(CommandError(
        commandStack: [
          CodegenCLI.self,
          Initialize.self
        ],
        parserError: .userValidationError(ValidationError("You must specify at least one option."))
      )))
  }

  func test__parsing__givenShortFormat_shouldThrow() throws {
    // given
    let options = [
      "init",
      "-p"
    ]

    // then
    expect(try self.parse(options: options))
      .to(throwError(CommandError(
        commandStack: [
          CodegenCLI.self,
          Initialize.self
        ],
        parserError: .userValidationError(ValidationError("You must specify at least one option."))
      )))
  }

#warning("Should we have tests for FileManager - validate path, etc.")

}

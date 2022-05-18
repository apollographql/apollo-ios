import XCTest
import Nimble
@testable import apollo_ios_codegen
@testable import ArgumentParser

class InitializeTests: XCTestCase {

  func parse(options: [String]?) throws -> Initialize {
    try XCTUnwrap(CodegenCLI.parseAsRoot(options) as? Initialize)
  }

  func test__parsing__givenNoOptions_shouldNotThrow() throws {
    // when
    let command = try parse(options: ["init"])

    // then
    expect(command.path).to(beNil())
    expect(command.print).to(beFalse())
  }

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

  func test__parsing__givenShortFormat_shouldThrow() throws {
    // given
    let options = [
      "init",
      "-p"
    ]

    // then
    expect(
      try CodegenCLI.parseAsRoot(options)
    ).to(throwError { error in
      guard
        let commandError = error as? CommandError,
        case ArgumentParser.ParserError.unknownOption = commandError.parserError
      else {
        fail("Expected ParserError.unknownOption, got \(error)")
        return
      }
    })
  }

#warning("Do we need tests for FileManager - validate path, etc.")

}

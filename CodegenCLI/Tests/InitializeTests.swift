import XCTest
import Nimble
@testable import apollo_ios_codegen
@testable import ArgumentParser

class InitializeTests: XCTestCase {

  // MARK: - Test Helpers

  func parse(options: [String]?) throws -> Initialize {
    try CodegenCLI.parseAsRoot(options) as! Initialize
  }

  func buildProcess(arguments: [String]?) -> Process {
    let process = Process()
    process.executableURL = TestSupport.productsDirectory.appendingPathComponent("apollo-ios-codegen")
    process.arguments = arguments

    return process
  }

  // MARK: - Parsing Tests

  func test__parsing__givenPath_shouldParse() throws {
    // given
    let path = "./configuration.json"

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
      .to(throwUserValidationError(
        ValidationError("You must specify at least one valid option.")
      ))
  }

  func test__parsing__givenShortFormat_shouldThrow() throws {
    // given
    let options = [
      "init",
      "-p"
    ]

    // then
    expect(try self.parse(options: options))
      .to(throwUserValidationError(
        ValidationError("You must specify at least one valid option.")
      ))
  }

  // MARK: - Output Tests

  let expectedJSON = """
  {
    "schemaName" : "GraphQLSchemaName",
    "options" : {
      "schemaDocumentation" : "include",
      "deprecatedEnumCases" : "include",
      "apqs" : "disabled",
      "additionalInflectionRules" : [

      ],
      "queryStringLiteralFormat" : "multiline"
    },
    "input" : {
      "searchPaths" : [
        "**\\/*.graphql"
      ],
      "schemaPath" : "schema.graphqls"
    },
    "output" : {
      "testMocks" : {
        "none" : {

        }
      },
      "schemaTypes" : {
        "path" : ".\\/",
        "moduleType" : {
          "swiftPackageManager" : {

          }
        }
      },
      "operations" : {
        "relative" : {

        }
      }
    },
    "experimentalFeatures" : {
      "clientControlledNullability" : false
    }
  }
  """

  func test__output__givenPath_shouldWriteToFile() throws {
    // given
    let path = TestSupport.productsDirectory.appendingPathComponent("test-configuration.json").path

    let subject = buildProcess(arguments: [
      "init",
      "--path=\(path)"
    ])

    // when
    try subject.run()
    subject.waitUntilExit()

    let output = try String(contentsOfFile: path)

    // then
    expect(output).to(equal(expectedJSON))
  }

  func test__output__givenPrint_shouldPrintToStandardOutput() throws {
    // given
    let subject = buildProcess(arguments: [
      "init",
      "--print"
    ])

    let pipe = Pipe()
    subject.standardOutput = pipe

    // when
    try subject.run()
    subject.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)

    // Printing to STDOUT appends a newline
    let expected = expectedJSON + "\n"

    // then
    expect(output).to(equal(expected))
  }
}

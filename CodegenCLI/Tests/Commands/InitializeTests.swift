import XCTest
import Nimble
@testable import apollo_ios_cli
import ArgumentParser

class InitializeTests: XCTestCase {

  var mockFileManager: MockFileManager!

  override func setUp() {
    super.setUp()

    mockFileManager = MockFileManager(strict: true)
  }

  override func tearDown() {
    mockFileManager = nil

    super.tearDown()
  }

  // MARK: - Test Helpers

  func parseAsRoot(options: [String]?) throws -> Initialize {
    try CodegenCLI.parseAsRoot(options) as! Initialize
  }

  // MARK: - Parsing Tests

  func test__parsing__givenParameters_none_shouldUseDefaults() throws {
    // given
    let options = ["init"]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.path).to(equal(Constants.defaultFilePath))
    expect(command.overwrite).to(beFalse())
    expect(command.print).to(beFalse())
  }

  func test__parsing__givenParameters_pathLongFormat_shouldParse() throws {
    // given
    let path = "./configuration.json"

    let options = [
      "init",
      "--path=\(path)"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.path).to(equal(path))
  }

  func test__parsing__givenParameters_pathShortFormat_shouldParse() throws {
    // given
    let path = "./configuration.json"

    let options = [
      "init",
      "-p=\(path)"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.path).to(equal(path))
  }

  func test__parsing__givenParameters_overwriteLongFormat_shouldParse() throws {
    // given
    let options = [
      "init",
      "--overwrite"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.overwrite).to(beTrue())
  }

  func test__parsing__givenParameters_overwriteShortFormat_shouldParse() throws {
    // given
    let options = [
      "init",
      "-w"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.overwrite).to(beTrue())
  }

  func test__parsing__givenParameters_printLongFormat_shouldParse() throws {
    // given
    let options = [
      "init",
      "--print"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.print).to(beTrue())
  }

  func test__parsing__givenParameters_printShortFormat_shouldParse() throws {
    // given
    let options = [
      "init",
      "-s"
    ]

    // when
    let command = try parseAsRoot(options: options)

    // then
    expect(command.print).to(beTrue())
  }

  func test__parsing__givenParameters_unknown_shouldThrow() throws {
    // given
    let options = [
      "init",
      "--unknown"
    ]

    // then
    expect(try self.parseAsRoot(options: options))
      .to(throwUnknownOptionError())
  }

  // MARK: - Output Tests

  let expectedJSON = """
  {
    "schemaName" : "GraphQLSchemaName",
    "options" : {
      "schemaDocumentation" : "include",
      "warningsOnDeprecatedUsage" : "include",
      "deprecatedEnumCases" : "include",
      "apqs" : "disabled",
      "additionalInflectionRules" : [

      ],
      "queryStringLiteralFormat" : "multiline"
    },
    "input" : {
      "operationSearchPaths" : [
        "**\\/*.graphql"
      ],
      "schemaSearchPaths" : [
        "schema.graphqls"
      ]
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
      "clientControlledNullability" : false,
      "legacySafelistingCompatibleOperations" : false
    }
  }
  """

  func test__output__givenParameters_pathCustom_overwriteDefault_whenNoExistingFile_shouldWriteToPath() throws {
    // given
    let outputPath = "./path/to/output.file"

    let options = [
      "init",
      "--path=\(outputPath)"
    ]

    let subject = try parseAsRoot(options: options)

    // when
    mockFileManager.mock(closure: .fileExists({ path, isDirectory in
      return false
    }))

    mockFileManager.mock(closure: .createDirectory({ path, intermediateDirectories, fileAttributes in
      // no-op
    }))

    mockFileManager.mock(closure: .createFile({ path, data, fileAttributes in
      let actualPath = URL(fileURLWithPath: path).standardizedFileURL.path
      let expectedPath = URL(fileURLWithPath: outputPath).standardizedFileURL.path

      expect(actualPath).to(equal(expectedPath))
      expect(data?.asString).to(equal(self.expectedJSON))

      return true
    }))

    try subject._run(fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__output__givenParameters_pathCustom_overwriteDefault_whenFileExists_shouldThrow() throws {
    // given
    let outputPath = "./path/to/output.file"

    let options = [
      "init",
      "--path=\(outputPath)"
    ]

    let subject = try parseAsRoot(options: options)

    // when
    mockFileManager.mock(closure: .fileExists({ path, isDirectory in
      return true
    }))

    mockFileManager.mock(closure: .createDirectory({ path, intermediateDirectories, fileAttributes in
      // no-op
    }))

    // then
    expect(
      try subject._run(fileManager: self.mockFileManager)
    ).to(throwError(
      localizedDescription: "File already exists at \(outputPath).",
      ignoringExtraCharacters: true
    ))
  }

  func test__output__givenParameters_pathCustom_overwriteTrue_whenFileExists_shouldWriteToPath() throws {
    // given
    let outputPath = "./path/to/output.file"

    let options = [
      "init",
      "--path=\(outputPath)",
      "--overwrite"
    ]

    let subject = try parseAsRoot(options: options)

    // when
    mockFileManager.mock(closure: .fileExists({ path, isDirectory in
      return true
    }))

    mockFileManager.mock(closure: .createDirectory({ path, intermediateDirectories, fileAttributes in
      // no-op
    }))

    mockFileManager.mock(closure: .createFile({ path, data, fileAttributes in
      let actualPath = URL(fileURLWithPath: path).standardizedFileURL.path
      let expectedPath = URL(fileURLWithPath: outputPath).standardizedFileURL.path

      expect(actualPath).to(equal(expectedPath))
      expect(data?.asString).to(equal(self.expectedJSON))

      return true
    }))

    try subject._run(fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__output__givenParameters_printTrue_shouldPrintToStandardOutput() throws {
    // given
    let executable = TestSupport.productsDirectory.appendingPathComponent("apollo-ios-cli")

    let subject = Process()
    subject.executableURL = executable
    subject.arguments = [
      "init",
      "--print"
    ]

    let pipe = Pipe()
    subject.standardOutput = pipe

    // when
    try subject.run()
    subject.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    // Printing to STDOUT appends a newline
    let expected = expectedJSON + "\n"

    // then
    expect(data.asString).to(equal(expected))
  }

  func test__output__givenParameters_bothPathAndPrint_shouldPrintToStandardOutput() throws {
    // given
    let executable = TestSupport.productsDirectory.appendingPathComponent("apollo-ios-cli")

    let subject = Process()
    subject.executableURL = executable
    subject.arguments = [
      "init",
      "--path=./path/to/file",
      "--print"
    ]

    let pipe = Pipe()
    subject.standardOutput = pipe

    // when
    try subject.run()
    subject.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    // Printing to STDOUT appends a newline
    let expected = expectedJSON + "\n"

    // then
    expect(data.asString).to(equal(expected))
  }
}

extension Data {
  fileprivate var asString: String? {
    return String(data: self, encoding: .utf8)
  }
}

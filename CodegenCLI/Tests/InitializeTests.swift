import XCTest
import Nimble
@testable import apollo_ios_codegen
@testable import ArgumentParser

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

  func parse(options: [String]?) throws -> Initialize {
    try CodegenCLI.parseAsRoot(options) as! Initialize
  }

  // MARK: - Parsing Tests

  func test__parsing__givenParameters_none_shouldUseDefaults() throws {
    // given
    let options = ["init"]

    // when
    let command = try parse(options: options)

    // then
    expect(command.output).to(equal(.file))
    expect(command.path).to(equal(Constants.defaultFilePath))
    expect(command.overwrite).to(beFalse())
  }

  func test__parsing__givenParameters_outputFile_shouldParse() throws {
    // given
    let options = [
      "init",
      "--output=file"
    ]

    // when
    let command = try parse(options: options)

    // then
    expect(command.output).to(equal(.file))
  }

  func test__parsing__givenParameters_outputPrint_shouldParse() throws {
    // given
    let options = [
      "init",
      "--output=print"
    ]

    // when
    let command = try parse(options: options)

    // then
    expect(command.output).to(equal(.print))
  }

  func test__parsing__givenParameters_pathLongFormat_shouldParse() throws {
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
  }

  func test__parsing__givenParameters_pathShortFormat_shouldParse() throws {
    // given
    let path = "./configuration.json"

    let options = [
      "init",
      "-p=\(path)"
    ]

    // when
    let command = try parse(options: options)

    // then
    expect(command.path).to(equal(path))
  }

  func test__parsing__givenParameters_overwrite_shouldParse() throws {
    // given
    let options = [
      "init",
      "--overwrite"
    ]

    // when
    let command = try parse(options: options)

    // then
    expect(command.overwrite).to(beTrue())
  }

  func test__parsing__givenParameters_unknown_shouldThrow() throws {
    // given
    let options = [
      "init",
      "--unknown"
    ]

    // then
    expect(try self.parse(options: options))
      .to(throwUnknownOptionError())
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

  func test__output__givenParameters_outputFile_pathCustom_whenNoExistingFile_shouldWriteToPath() throws {
    // given
    let outputPath = "./path/to/output.file"

    let options = [
      "init",
      "--output=file",
      "--path=\(outputPath)"
    ]

    let subject = try parse(options: options)

    // when
    mockFileManager.mock(closure: .fileExists({ path, isDirectory in
      return false
    }))

    mockFileManager.mock(closure: .createDirectory({ path, intermediateDirectories, fileAttributes in
      // no-op
    }))

    mockFileManager.mock(closure: .createFile({ path, data, fileAttributes in
      let actualPath = URL(fileURLWithPath: path)
        .standardizedFileURL
        .path

      let expectedPath = TestSupport.productsDirectory
        .appendingPathComponent(outputPath)
        .standardizedFileURL
        .path

      expect(actualPath).to(equal(expectedPath))

      expect(data).to(equal(self.expectedJSON.data(using: .utf8)!))

      return true
    }))

    try subject._run(fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).toEventually(beTrue())
  }

  func test__output__givenParameters_outputFile_pathCustom_whenFileExists_shouldThrow() throws {
    // given
    let outputPath = "./path/to/output.file"

    let options = [
      "init",
      "--output=file",
      "--path=\(outputPath)"
    ]

    let subject = try parse(options: options)

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
    ).to(throwError() { error in
      expect(error.localizedDescription.starts(with: "File already exists at \(outputPath)."))
        .to(beTrue())
    })
  }

  func test__output__givenParameters_outputFile_pathCustom_overwriteTrue_whenFileExists_shouldWriteToPath() throws {
    // given
    let outputPath = "./path/to/output.file"

    let options = [
      "init",
      "--output=file",
      "--path=\(outputPath)",
      "--overwrite"
    ]

    let subject = try parse(options: options)

    // when
    mockFileManager.mock(closure: .fileExists({ path, isDirectory in
      return true
    }))

    mockFileManager.mock(closure: .createDirectory({ path, intermediateDirectories, fileAttributes in
      // no-op
    }))

    mockFileManager.mock(closure: .createFile({ path, data, fileAttributes in
      let actualPath = URL(fileURLWithPath: path)
        .standardizedFileURL
        .path

      let expectedPath = TestSupport.productsDirectory
        .appendingPathComponent(outputPath)
        .standardizedFileURL
        .path

      expect(actualPath).to(equal(expectedPath))

      expect(data).to(equal(self.expectedJSON.data(using: .utf8)!))

      return true
    }))

    try subject._run(fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).toEventually(beTrue())
  }

  func test__output__givenParameters_outputPrint_shouldPrintToStandardOutput() throws {
    // given
    let executable = TestSupport.productsDirectory.appendingPathComponent("apollo-ios-codegen")

    let subject = Process()
    subject.executableURL = executable
    subject.arguments = [
      "init",
      "--output=print"
    ]

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

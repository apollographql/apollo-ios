import XCTest
import Nimble
@testable import CodegenCLI
import ArgumentParser

class InitializeTests: XCTestCase {

  var mockFileManager: MockApolloFileManager!

  override func setUp() {
    super.setUp()

    mockFileManager = MockApolloFileManager(strict: true)
  }

  override func tearDown() {
    mockFileManager = nil

    super.tearDown()
  }

  // MARK: - Test Helpers

  func parse(_ options: [String]?) throws -> Initialize {
    try Initialize.parse(options)
  }

  // MARK: - Parsing Tests

  func test__parsing__givenParameters_none_shouldUseDefaults() throws {
    // when
    let command = try parse([])

    // then
    expect(command.path).to(equal(Constants.defaultFilePath))
    expect(command.overwrite).to(beFalse())
    expect(command.print).to(beFalse())
  }

  func test__parsing__givenParameters_pathLongFormat_shouldParse() throws {
    // given
    let path = "./configuration.json"

    let options = [
      "--path=\(path)"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.path).to(equal(path))
  }

  func test__parsing__givenParameters_pathShortFormat_shouldParse() throws {
    // given
    let path = "./configuration.json"

    let options = [
      "-p=\(path)"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.path).to(equal(path))
  }

  func test__parsing__givenParameters_overwriteLongFormat_shouldParse() throws {
    // given
    let options = [
      "--overwrite"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.overwrite).to(beTrue())
  }

  func test__parsing__givenParameters_overwriteShortFormat_shouldParse() throws {
    // given
    let options = [
      "-w"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.overwrite).to(beTrue())
  }

  func test__parsing__givenParameters_printLongFormat_shouldParse() throws {
    // given
    let options = [
      "--print"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.print).to(beTrue())
  }

  func test__parsing__givenParameters_printShortFormat_shouldParse() throws {
    // given
    let options = [
      "-s"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.print).to(beTrue())
  }

  func test__parsing__givenParameters_unknown_shouldThrow() throws {
    // given
    let options = [
      "--unknown"
    ]

    // then
    expect(try self.parse(options))
      .to(throwUnknownOptionError())
  }

  // MARK: - Output Tests

  let expectedJSON = """
  {
    "schemaName" : "GraphQLSchemaName",
    "options" : {
      "apqs" : "disabled",
      "additionalInflectionRules" : [

      ],
      "warningsOnDeprecatedUsage" : "include",
      "deprecatedEnumCases" : "include",
      "schemaDocumentation" : "include",
      "cocoapodsCompatibleImportStatements" : false,
      "queryStringLiteralFormat" : "multiline",
      "enumCaseConvertStrategy" : "none"
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
      "--path=\(outputPath)"
    ]

    let subject = try parse(options)

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
      "--path=\(outputPath)"
    ]

    let subject = try parse(options)

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
      "--path=\(outputPath)",
      "--overwrite"
    ]

    let subject = try parse(options)

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
    let options = [
      "--print"
    ]

    let command = try parse(options)

    // when
    var output: String?
    try command._run() { message in
      output = message
    }

    // then
    expect(output).toEventuallyNot(beNil())
    expect(output).to(equal(expectedJSON))
  }

  func test__output__givenParameters_bothPathAndPrint_shouldPrintToStandardOutput() throws {
    // given
    let options = [
      "--path=./path/to/file",
      "--print"
    ]

    let command = try parse(options)

    // when
    var output: String?
    try command._run() { message in
      output = message
    }

    // then
    expect(output).toEventuallyNot(beNil())
    expect(output).to(equal(expectedJSON))
  }
}

extension Data {
  fileprivate var asString: String? {
    return String(data: self, encoding: .utf8)
  }
}

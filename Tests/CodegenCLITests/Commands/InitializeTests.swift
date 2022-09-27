import XCTest
import Nimble
@testable import CodegenCLI
import ArgumentParser
import ApolloCodegenLib

class InitializeTests: XCTestCase {

  var mockFileManager: MockApolloFileManager!
  let baseOptions = ["--schema-name=MockSchema"]

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

  func test__parsing__givenParameters_none_shouldThrow() throws {
    expect { try self.parse([]) }.to(throwUserValidationError(
      ValidationError("Schema name is missing, use the --schema-name option to specify.")
    ))
  }

  func test__parsing__givenParameters_required_shouldUseDefaults() throws {
    // when
    let command = try parse(baseOptions)

    // then
    expect(command.path).to(equal(Constants.defaultFilePath))
    expect(command.overwrite).to(beFalse())
    expect(command.print).to(beFalse())
  }

  func test__parsing__givenParameters_schemaNameLongformat_shouldParse() throws {
    // given
    let options = [
      "--schema-name=LongFormatSchemaName"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.schemaName).to(equal("LongFormatSchemaName"))
  }

  func test__parsing__givenParameters_schemaNameShortFormat_shouldParse() throws {
    // given
    let options = [
      "-n=ShortFormatSchemaName"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.schemaName).to(equal("ShortFormatSchemaName"))
  }

  func test__parsing__givenParameters_pathLongFormat_shouldParse() throws {
    // given
    let path = "./configuration.json"

    let options = baseOptions + [
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

    let options = baseOptions + [
      "-p=\(path)"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.path).to(equal(path))
  }

  func test__parsing__givenParameters_overwriteLongFormat_shouldParse() throws {
    // given
    let options = baseOptions + [
      "--overwrite"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.overwrite).to(beTrue())
  }

  func test__parsing__givenParameters_overwriteShortFormat_shouldParse() throws {
    // given
    let options = baseOptions + [
      "-w"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.overwrite).to(beTrue())
  }

  func test__parsing__givenParameters_printLongFormat_shouldParse() throws {
    // given
    let options = baseOptions + [
      "--print"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.print).to(beTrue())
  }

  func test__parsing__givenParameters_printShortFormat_shouldParse() throws {
    // given
    let options = baseOptions + [
      "-s"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.print).to(beTrue())
  }

  func test__parsing__givenParameters_unknown_shouldThrow() throws {
    // given
    let options = baseOptions + [
      "--unknown"
    ]

    // then
    expect(try self.parse(options))
      .to(throwUnknownOptionError())
  }

  // MARK: - Output Tests

  func test__output__givenParameters_pathCustom_overwriteDefault_whenNoExistingFile_shouldWriteToPath() throws {
    // given
    let outputPath = "./path/to/output.file"

    let options = baseOptions + [
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
      expect(data?.asString).to(equal(
        ApolloCodegenConfiguration.minimalJSON(schemaName: "MockSchema")))

      return true
    }))

    try subject._run(fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__output__givenParameters_pathCustom_overwriteDefault_whenFileExists_shouldThrow() throws {
    // given
    let outputPath = "./path/to/output.file"

    let options = baseOptions + [
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

    let options = baseOptions + [
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
      expect(data?.asString).to(equal(
        ApolloCodegenConfiguration.minimalJSON(schemaName: "MockSchema")
      ))

      return true
    }))

    try subject._run(fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__output__givenParameters_printTrue_shouldPrintToStandardOutput() throws {
    // given
    let options = baseOptions + [
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
    expect(output).to(equal(ApolloCodegenConfiguration.minimalJSON(schemaName: "MockSchema")))
  }

  func test__output__givenParameters_bothPathAndPrint_shouldPrintToStandardOutput() throws {
    // given
    let options = baseOptions + [
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
    expect(output).to(equal(ApolloCodegenConfiguration.minimalJSON(schemaName: "MockSchema")))
  }

  // MARK: - minimalJSON Tests

  func test__decoding__givenMinimalJSON_cocoapodsIncompatible_shouldNotThrow() throws {
    // given
    let encoded = try ApolloCodegenConfiguration.minimalJSON(
      schemaName: "MockSchema",
      supportCocoaPods: false
    ).asData()

    // then
    var decoded: ApolloCodegenConfiguration?
    expect(decoded = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: encoded))
      .notTo(throwError())
    expect(decoded.unsafelyUnwrapped.options.cocoapodsCompatibleImportStatements).to(beFalse())
  }

  func test__decoding__givenMinimalJSON_cocoapodsIncompatible_shouldUseCorrectDefaults() throws {
    // given
    let encoded = try ApolloCodegenConfiguration.minimalJSON(
      schemaName: "MockSchema",
      supportCocoaPods: false
    ).asData()

    // then
    let decoded = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: encoded)

    expect(decoded.output.schemaTypes.moduleType).to(equal(.swiftPackageManager))
  }

  func test__decoding__givenMinimalJSON_cocoapodsCompatible_shouldNotThrow() throws {
    // given
    let encoded = try ApolloCodegenConfiguration.minimalJSON(
      schemaName: "MockSchema",
      supportCocoaPods: true
    ).asData()

    // then
    var decoded: ApolloCodegenConfiguration?
    expect(decoded = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: encoded))
      .notTo(throwError())
    expect(decoded.unsafelyUnwrapped.options.cocoapodsCompatibleImportStatements).to(beTrue())
  }

  func test__decoding__givenMinimalJSON_cocoapodsCompatible_shouldUseCorrectDefaults() throws {
    // given
    let encoded = try ApolloCodegenConfiguration.minimalJSON(
      schemaName: "MockSchema",
      supportCocoaPods: true
    ).asData()

    // then
    let decoded = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: encoded)

    expect(decoded.output.schemaTypes.moduleType).to(equal(.other))
  }
}

extension Data {
  fileprivate var asString: String? {
    return String(data: self, encoding: .utf8)
  }
}

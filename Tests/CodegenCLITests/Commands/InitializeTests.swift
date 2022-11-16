import XCTest
import Nimble
@testable import CodegenCLI
import ArgumentParser
import ApolloCodegenLib

class InitializeTests: XCTestCase {

  var mockFileManager: MockApolloFileManager!
  let requiredOptions = [
    "--schema-name=MockSchema",
    "--module-type=swiftPackageManager",
  ]

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
    expect { try self.parse([]) }.to(throwError())
  }

  func test__parsing__givenParameters_missingSchemaName_shouldThrow() throws {
    // given
    let options = [
      "--module-type=swiftPackageManager",
    ]

    // when
    expect { try self.parse(options) }.to(throwError())
  }

  func test__parsing__givenParameters_missingModuleType_shouldThrow() throws {
    // given
    let options = [
      "--schema-name=MySchemaName",
    ]

    // when
    expect { try self.parse(options) }.to(throwError())
  }

  func test__parsing__givenParameters_required_shouldUseDefaults() throws {
    // when
    let command = try parse(requiredOptions)

    // then
    expect(command.path).to(equal(Constants.defaultFilePath))
    expect(command.overwrite).to(beFalse())
    expect(command.print).to(beFalse())
  }

  func test__parsing__givenParameters_schemaNameLongformat_shouldParse() throws {
    // given
    let options = [
      "--schema-name=LongFormatSchemaName",
      "--module-type=swiftPackageManager",
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.schemaName).to(equal("LongFormatSchemaName"))
  }

  func test__parsing__givenParameters_schemaNameShortFormat_shouldParse() throws {
    // given
    let options = [
      "-n=ShortFormatSchemaName",
      "--module-type=swiftPackageManager",
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.schemaName).to(equal("ShortFormatSchemaName"))
  }

  func test__parsing__givenParameters_moduleNameLongFormat_shouldParse() throws {
    // given
    let options = [
      "--schema-name=MySchemaName",
      "--module-type=swiftPackageManager",
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.moduleType).to(equal(.swiftPackageManager))
  }

  func test__parsing__givenParameters_moduleNameShortFormat_shouldParse() throws {
    // given
    let options = [
      "--schema-name=MySchemaName",
      "-m=swiftPackageManager",
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.moduleType).to(equal(.swiftPackageManager))
  }

  func test__parsing__givenParameters_targetNameLongFormat_shouldParse() throws {
    // given
    let options = [
      "--schema-name=MySchemaName",
      "--module-type=embeddedInTarget",
      "--target-name=LongFormatTargetName",
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.targetName).to(equal("LongFormatTargetName"))
  }

  func test__parsing__givenParameters_targetNameShortFormat_shouldParse() throws {
    // given
    let options = [
      "--schema-name=MySchemaName",
      "--module-type=embeddedInTarget",
      "-t=ShortFormatTargetName",
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.targetName).to(equal("ShortFormatTargetName"))
  }

  func test__parsing__givenParameters_pathLongFormat_shouldParse() throws {
    // given
    let path = "./configuration.json"

    let options = requiredOptions + [
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

    let options = requiredOptions + [
      "-p=\(path)"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.path).to(equal(path))
  }

  func test__parsing__givenParameters_overwriteLongFormat_shouldParse() throws {
    // given
    let options = requiredOptions + [
      "--overwrite"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.overwrite).to(beTrue())
  }

  func test__parsing__givenParameters_overwriteShortFormat_shouldParse() throws {
    // given
    let options = requiredOptions + [
      "-w"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.overwrite).to(beTrue())
  }

  func test__parsing__givenParameters_printLongFormat_shouldParse() throws {
    // given
    let options = requiredOptions + [
      "--print"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.print).to(beTrue())
  }

  func test__parsing__givenParameters_printShortFormat_shouldParse() throws {
    // given
    let options = requiredOptions + [
      "-s"
    ]

    // when
    let command = try parse(options)

    // then
    expect(command.print).to(beTrue())
  }

  func test__parsing__givenParameters_unknown_shouldThrow() throws {
    // given
    let options = requiredOptions + [
      "--unknown"
    ]

    // then
    expect(try self.parse(options))
      .to(throwUnknownOptionError())
  }

  // MARK: - Validation Tests

  func test__validation__givenWhitespaceSchemaName_shouldThrowValidationError() throws {
    // given
    let options = [
      "--schema-name= ",
      "--module-type=swiftPackageManager",
    ]

    // then
    expect { try self.parse(options) }.to(throwUserValidationError(
      ValidationError("--schema-name value cannot be empty.")
    ))
  }

  func test__validation__givenModuleType_embeddedInTarget_withNoTargetName_shouldThrowValidationError() throws {
    // given
    let options = [
      "--schema-name=MySchemaName",
      "--module-type=embeddedInTarget",
    ]

    // then
    expect { try self.parse(options) }.to(throwUserValidationError(
      ValidationError("""
        Target name is required when using \"embeddedInTarget\" module type. Use --target-name \
        to specify.
        """
      )
    ))
  }

  func test__validation__givenModuleType_embeddedInTarget_withTargetName_shouldNotThrow() throws {
    // given
    let options = [
      "--schema-name=MySchemaName",
      "--module-type=embeddedInTarget",
      "--target-name=MyTarget",
    ]

    // then
    expect { try self.parse(options) }.notTo(throwError())
  }

  func test__validation__givenModuleType_swiftPackageManager_withNoTargetName_shouldNotThrow() throws {
    // given
    let options = [
      "--schema-name=MySchemaName",
      "--module-type=swiftPackageManager",
    ]

    // then
    expect { try self.parse(options) }.notTo(throwError())
  }

  func test__validation__givenModuleType_other_withNoTargetName_shouldNotThrow() throws {
    // given
    let options = [
      "--schema-name=MySchemaName",
      "--module-type=other",
    ]

    // then
    expect { try self.parse(options) }.notTo(throwError())
  }

  // MARK: - Output Tests

  func test__output__givenParameters_pathCustom_overwriteDefault_whenNoExistingFile_shouldWriteToPath() throws {
    // given
    let outputPath = "./path/to/output.file"

    let options = requiredOptions + [
      "--path=\(outputPath)",
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
        ApolloCodegenConfiguration.minimalJSON(
          schemaName: "MockSchema",
          moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager.rawValue,
          targetName: nil
        )
      ))

      return true
    }))

    try subject._run(fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__output__givenParameters_pathCustom_overwriteDefault_whenFileExists_shouldThrow() throws {
    // given
    let outputPath = "./path/to/output.file"

    let options = requiredOptions + [
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

    let options = requiredOptions + [
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
        ApolloCodegenConfiguration.minimalJSON(
          schemaName: "MockSchema",
          moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager.rawValue,
          targetName: nil
        )
      ))

      return true
    }))

    try subject._run(fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__output__givenParameters_printTrue_shouldPrintToStandardOutput() throws {
    // given
    let options = requiredOptions + [
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
    expect(output).to(equal(
      ApolloCodegenConfiguration.minimalJSON(
        schemaName: "MockSchema",
        moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager.rawValue,
        targetName: nil
      )
    ))
  }

  func test__output__givenParameters_bothPathAndPrint_shouldPrintToStandardOutput() throws {
    // given
    let options = requiredOptions + [
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
    expect(output).to(equal(
      ApolloCodegenConfiguration.minimalJSON(
        schemaName: "MockSchema",
        moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager.rawValue,
        targetName: nil
      )
    ))
  }

  // MARK: - minimalJSON Tests

  func test__decoding__givenMinimalJSON_cocoapodsIncompatible_shouldNotThrow() throws {
    // given
    let encoded = try ApolloCodegenConfiguration.minimalJSON(
      schemaName: "MockSchema",
      supportCocoaPods: false,
      moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager.rawValue,
      targetName: nil
    ).asData()

    // then
    var decoded: ApolloCodegenConfiguration?
    expect(decoded = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: encoded))
      .notTo(throwError())
    expect(decoded.unsafelyUnwrapped.options.cocoapodsCompatibleImportStatements).to(beFalse())
  }

  func test__decoding__givenMinimalJSON_cocoapodsCompatible_shouldNotThrow() throws {
    // given
    let encoded = try ApolloCodegenConfiguration.minimalJSON(
      schemaName: "MockSchema",
      supportCocoaPods: true,
      moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager.rawValue,
      targetName: nil
    ).asData()

    // then
    var decoded: ApolloCodegenConfiguration?
    expect(decoded = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: encoded))
      .notTo(throwError())
    expect(decoded.unsafelyUnwrapped.options.cocoapodsCompatibleImportStatements).to(beTrue())
  }
}

extension Data {
  fileprivate var asString: String? {
    return String(data: self, encoding: .utf8)
  }
}

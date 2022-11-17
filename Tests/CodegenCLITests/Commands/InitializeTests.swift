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

  func test__parsing__givenParameters_required_shouldUseDefaults() throws {
    // when
    let command = try parse(requiredOptions)

    // then
    expect(command.path).to(equal(Constants.defaultFilePath))
    expect(command.overwrite).to(beFalse())
    expect(command.print).to(beFalse())
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
          moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager,
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
          moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager,
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
        moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager,
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
        moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager,
        targetName: nil
      )
    ))
  }

  // MARK: - ModuleType Conversion Tests

  func test__moduleType__givenModuleTypeExpressibleByArgument_embeddedInTarget_shouldEqualSchemaTypesFileOutputModuleType_embeddedInTarget() throws {
    // given
    let encoded = try ApolloCodegenConfiguration.minimalJSON(
      schemaName: "MockSchema",
      supportCocoaPods: false,
      moduleType: ModuleTypeExpressibleByArgument.embeddedInTarget,
      targetName: "MyTarget"
    ).asData()

    // then
    let decoded = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: encoded)

    expect(decoded.output.schemaTypes.moduleType)
      .to(equal(.embeddedInTarget(name: "MyTarget")))
  }

  func test__moduleType__givenModuleTypeExpressibleByArgument_swiftPackageManager_shouldEqualSchemaTypesFileOutputModuleType_swiftPackageManager() throws {
    // given
    let encoded = try ApolloCodegenConfiguration.minimalJSON(
      schemaName: "MockSchema",
      supportCocoaPods: false,
      moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager,
      targetName: nil
    ).asData()

    // then
    let decoded = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: encoded)

    expect(decoded.output.schemaTypes.moduleType).to(equal(.swiftPackageManager))
  }

  func test__moduleType__givenModuleTypeExpressibleByArgument_other_shouldEqualSchemaTypesFileOutputModuleType_other() throws {
    // given
    let encoded = try ApolloCodegenConfiguration.minimalJSON(
      schemaName: "MockSchema",
      supportCocoaPods: false,
      moduleType: ModuleTypeExpressibleByArgument.other,
      targetName: nil
    ).asData()

    // then
    let decoded = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: encoded)

    expect(decoded.output.schemaTypes.moduleType).to(equal(.other))
  }

  // MARK: - minimalJSON Tests

  func test__decoding__givenMinimalJSON_cocoapodsIncompatible_shouldNotThrow() throws {
    // given
    let encoded = try ApolloCodegenConfiguration.minimalJSON(
      schemaName: "MockSchema",
      supportCocoaPods: false,
      moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager,
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
      moduleType: ModuleTypeExpressibleByArgument.swiftPackageManager,
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

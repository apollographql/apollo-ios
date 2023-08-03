import XCTest
import Nimble
import ApolloInternalTestHelpers
@testable import CodegenCLI
import ApolloCodegenLib
@testable import ArgumentParser

class GenerateOperationManifestTests: XCTestCase {

  // MARK: - Test Helpers

  func parse(_ options: [String]?) throws -> GenerateOperationManifest {
    try GenerateOperationManifest.parse(options)
  }
  
  // MARK: - Parsing Tests

  func test__parsing__givenParameters_none_shouldUseDefaults() throws {
    // when
    let command = try parse([])

    // then
    expect(command.inputs.path).to(equal(Constants.defaultFilePath))
    expect(command.inputs.string).to(beNil())
    expect(command.inputs.verbose).to(beFalse())
  }
  
  // MARK: - Generate Tests

  func test__generate__givenParameters_pathCustom_shouldBuildWithFileData() throws {
    // given
    let inputPath = "./config.json"

    let options = [
      "--path=\(inputPath)"
    ]

    let mockConfiguration = ApolloCodegenConfiguration.mock()
    let mockFileManager = MockApolloFileManager(strict: true)

    mockFileManager.mock(closure: .contents({ path in
      let actualPath = URL(fileURLWithPath: path).standardizedFileURL.path
      let expectedPath = URL(fileURLWithPath: inputPath).standardizedFileURL.path

      expect(actualPath).to(equal(expectedPath))

      return try! JSONEncoder().encode(mockConfiguration)
    }))

    var didCallBuild = false
    MockApolloCodegen.generateOperationManifestHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration))

      didCallBuild = true
    }

    // when
    let command = try parse(options)

    try command._run(fileManager: mockFileManager.base, codegenProvider: MockApolloCodegen.self)

    // then
    expect(didCallBuild).to(beTrue())
  }
  
  func test__generate__givenParameters_stringCustom_shouldBuildWithStringData() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)"
    ]

    var didCallBuild = false
    MockApolloCodegen.generateOperationManifestHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration))

      didCallBuild = true
    }

    // when
    let command = try parse(options)

    try command._run(codegenProvider: MockApolloCodegen.self)

    // then
    expect(didCallBuild).to(beTrue())
  }
  
  func test__generate__givenParameters_bothPathAndString_shouldBuildWithStringData() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--path=./path/to/file",
      "--string=\(jsonString)"
    ]

    var didCallBuild = false
    MockApolloCodegen.generateOperationManifestHandler = { configuration in
      expect(configuration).to(equal(mockConfiguration))

      didCallBuild = true
    }

    // when
    let command = try parse(options)

    try command._run(codegenProvider: MockApolloCodegen.self)

    // then
    expect(didCallBuild).to(beTrue())
  }
  
  func test__generate__givenDefaultParameter_verbose_shouldSetLogLevelWarning() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)"
    ]

    MockApolloCodegen.generateOperationManifestHandler = { configuration in }
    MockApolloSchemaDownloader.fetchHandler = { configuration in }

    var level: CodegenLogger.LogLevel?
    MockLogLevelSetter.levelHandler = { value in
      level = value
    }

    // when
    let command = try parse(options)

    try command._run(
      codegenProvider: MockApolloCodegen.self,
      logger: CodegenLogger.mock
    )

    // then
    expect(level).toEventually(equal(.warning))
  }
  
  func test__generate__givenParameter_verbose_shouldSetLogLevelDebug() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)",
      "--verbose"
    ]

    MockApolloCodegen.generateOperationManifestHandler = { configuration in }
    MockApolloSchemaDownloader.fetchHandler = { configuration in }

    var level: CodegenLogger.LogLevel?
    MockLogLevelSetter.levelHandler = { value in
      level = value
    }

    // when
    let command = try parse(options)

    try command._run(
      codegenProvider: MockApolloCodegen.self,
      logger: CodegenLogger.mock
    )

    // then
    expect(level).toEventually(equal(.debug))
  }

  func test__generate__givenParameters_outputPathAndManifestVersion_configHasOperationManifestOption__overridesOperationManifestInConfiguration() throws {
    // given
    let inputPath = "./config.json"
    let outputPath = "./operationManifest.json"

    let options = [
      "--path=\(inputPath)",
      "--output-path=\(outputPath)",
      "--manifest-version=persistedQueries"
    ]

    var didCallGenerate = false
    MockApolloCodegen.generateOperationManifestHandler = { configuration in
      let actual = configuration.output.operationManifest
      expect(actual?.path).to(equal(outputPath))
      expect(actual?.version).to(equal(.persistedQueries))

      didCallGenerate = true
    }

    let mockFileManager = MockApolloFileManager(strict: true)

    mockFileManager.mock(closure: .contents({ path in
      return try! JSONEncoder().encode(ApolloCodegenConfiguration.mock())
    }))

    // when
    let command = try parse(options)
    try command._run(fileManager: mockFileManager.base, codegenProvider: MockApolloCodegen.self)

    // then
    expect(didCallGenerate).to(beTrue())
  }

  func test__generate__givenParameters_manifestVersion_legacyAPQs__overridesOperationManifestInConfiguration() throws {
    // given
    let inputPath = "./config.json"
    let outputPath = "./operationManifest.json"

    let options = [
      "--path=\(inputPath)",
      "--output-path=\(outputPath)",
      "--manifest-version=legacyAPQ"
    ]

    var didCallGenerate = false
    MockApolloCodegen.generateOperationManifestHandler = { configuration in
      let actual = configuration.output.operationManifest
      expect(actual?.path).to(equal(outputPath))
      expect(actual?.version).to(equal(.legacyAPQ))

      didCallGenerate = true
    }

    let mockFileManager = MockApolloFileManager(strict: true)

    mockFileManager.mock(closure: .contents({ path in
      return try! JSONEncoder().encode(ApolloCodegenConfiguration.mock())
    }))

    // when
    let command = try parse(options)
    try command._run(fileManager: mockFileManager.base, codegenProvider: MockApolloCodegen.self)

    // then
    expect(didCallGenerate).to(beTrue())
  }

  // MARK: Argument Validation Tests

  func test__generate__givenParameters_outputPath_noManifestVersion_throwsValidationError() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!


    let options = [
      "--output-path=./operationManifest.json",
      "--string=\(jsonString)"
    ]

    // when
    let command = try parse(options)

    // then
    expect(
      try command._run(codegenProvider: MockApolloCodegen.self)
    ).to(throwError(GenerateOperationManifest.ParsingError.manifestVersionMissing))
  }

  func test__generate__givenConfigHasNoOperationManifestOption_outputPathMissing__throwsValidationError() throws {
    // given
    let inputPath = "./config.json"

    let options = [
      "--path=\(inputPath)"
    ]

    let mockConfiguration = ApolloCodegenConfiguration(
      schemaNamespace: "MockSchema",
      input: .init(
        schemaPath: "./schema.graphqls"
      ),
      output: .init(
        schemaTypes: .init(path: ".", moduleType: .swiftPackageManager)
      ),
      options: .init(
        operationDocumentFormat: [.definition, .operationId]
      ),
      schemaDownloadConfiguration: .init(
        using: .introspection(endpointURL: URL(string: "http://some.server")!),
        outputPath: "./schema.graphqls"
      )
    )

    let mockFileManager = MockApolloFileManager(strict: true)

    mockFileManager.mock(closure: .contents({ path in
      let actualPath = URL(fileURLWithPath: path).standardizedFileURL.path
      let expectedPath = URL(fileURLWithPath: inputPath).standardizedFileURL.path

      expect(actualPath).to(equal(expectedPath))

      return try! JSONEncoder().encode(mockConfiguration)
    }))

    // when
    let command = try parse(options)

    // then
    expect(
      try command._run(fileManager: mockFileManager.base, codegenProvider: MockApolloCodegen.self)
    ).to(throwError(GenerateOperationManifest.ParsingError.outputPathMissing))
  }
  
  // MARK: Version Checking Tests

  func test__generate__givenCLIVersionMismatch_shouldThrowVersionMismatchError() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)",
      "--verbose"
    ]

    MockApolloCodegen.generateOperationManifestHandler = { configuration in }
    MockApolloSchemaDownloader.fetchHandler = { configuration in }

    try self.testIsolatedFileManager().createFile(
      body: """
        {
          "pins": [
            {
              "identity": "apollo-ios",
              "kind" : "remoteSourceControl",
              "location": "https://github.com/apollographql/apollo-ios.git",
              "state": {
                "revision": "5349afb4e9d098776cc44280258edd5f2ae571ed",
                "version": "1.0.0-test.123"
              }
            }
          ],
          "version": 2
        }
        """,
      named: "Package.resolved"
    )

    // when
    let command = try parse(options)

    // then
    expect(
      try command._run(
        codegenProvider: MockApolloCodegen.self
      )
    ).to(throwError())
  }
  
  func test__generate__givenCLIVersionMismatch_withIgnoreVersionMismatchArgument_shouldNotThrowVersionMismatchError() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)",
      "--verbose",
      "--ignore-version-mismatch"
    ]

    MockApolloCodegen.generateOperationManifestHandler = { configuration in }
    MockApolloSchemaDownloader.fetchHandler = { configuration in }

    try self.testIsolatedFileManager().createFile(
      body: """
        {
          "pins": [
            {
              "identity": "apollo-ios",
              "kind" : "remoteSourceControl",
              "location": "https://github.com/apollographql/apollo-ios.git",
              "state": {
                "revision": "5349afb4e9d098776cc44280258edd5f2ae571ed",
                "version": "1.0.0-test.123"
              }
            }
          ],
          "version": 2
        }
        """,
      named: "Package.resolved"
    )

    // when
    let command = try parse(options)

    // then
    expect(
      try command._run(
        codegenProvider: MockApolloCodegen.self
      )
    ).toNot(throwError())
  }
  
  func test__generate__givenNoPackageResolvedFile__shouldNotThrowVersionMismatchError() throws {
    // given
    let mockConfiguration = ApolloCodegenConfiguration.mock()

    let jsonString = String(
      data: try! JSONEncoder().encode(mockConfiguration),
      encoding: .utf8
    )!

    let options = [
      "--string=\(jsonString)",
      "--verbose"
    ]

    MockApolloCodegen.generateOperationManifestHandler = { configuration in }
    MockApolloSchemaDownloader.fetchHandler = { configuration in }

    // when
    let command = try parse(options)

    // then
    expect(
      try command._run(
        codegenProvider: MockApolloCodegen.self
      )
    ).toNot(throwError())
  }
  
}

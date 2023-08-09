import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class OperationManifestFileGeneratorTests: XCTestCase {
  var fileManager: MockApolloFileManager!
  var subject: OperationManifestFileGenerator!

  override func setUp() {
    super.setUp()

    fileManager = MockApolloFileManager(strict: true)
  }

  override func tearDown() {
    subject = nil
    fileManager = nil
  }

  // MARK: Test Helpers

  private func buildSubject(
    path: String? = nil,
    version: ApolloCodegenConfiguration.OperationManifestConfiguration.Version = .legacy
  ) throws {
    let manifest: ApolloCodegenConfiguration.OperationManifestConfiguration? = {
      guard let path else { return nil }
      return .init(path: path, version: version)
    }()

    subject = try OperationManifestFileGenerator(
      config: ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
        output: .init(
          schemaTypes: .init(path: "", moduleType: .swiftPackageManager)
        ),
        operationManifest: manifest
      ))
    ).xctUnwrapped()
  }

  // MARK: Initializer Tests

  func test__initializer__givenPath_shouldReturnInstance() {
    // given
    let config = ApolloCodegenConfiguration.mock(
      output: .init(
        schemaTypes: .init(path: "", moduleType: .swiftPackageManager)
      ),
      operationManifest: .init(
        path: "a/file/path"
      )
    )

    // when
    let instance = OperationManifestFileGenerator(config: .init(config: config))

    // then
    expect(instance).notTo(beNil())
  }

  func test__initializer__givenNilPath_shouldReturnNil() {
    // given
    let config = ApolloCodegenConfiguration.mock(
      output: .init(
        schemaTypes: .init(path: "", moduleType: .swiftPackageManager)
      ),
      operationManifest: nil
    )

    // when
    let instance = OperationManifestFileGenerator(config: .init(config: config))

    // then
    expect(instance).to(beNil())
  }

  // MARK: Generate Tests

  func test__generate__givenOperation_shouldWriteToAbsolutePath() throws {
    // given
    let filePath = "path/to/match"
    try buildSubject(path: filePath)

    subject.collectOperationIdentifier(.mock(
      name: "TestQuery",
      type: .query,
      source: """
        query TestQuery {
          test
        }
        """
    ))

    fileManager.mock(closure: .fileExists({ path, isDirectory in
      return false
    }))

    fileManager.mock(closure: .createDirectory({ path, intermediateDirectories, attributes in
      // no-op
    }))

    fileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal("\(filePath).json"))

      return true
    }))

    // when
    try subject.generate(fileManager: fileManager)

    expect(self.fileManager.allClosuresCalled).to(beTrue())
  }
  
  func test__generate__givenOperation_withPathExtension_shouldWriteToAbsolutePathWithSinglePathExtension() throws {
    // given
    let filePath = "path/to/match"
    try buildSubject(path: "\(filePath).json")

    subject.collectOperationIdentifier(.mock(
      name: "TestQuery",
      type: .query,
      source: """
        query TestQuery {
          test
        }
        """
    ))

    fileManager.mock(closure: .fileExists({ path, isDirectory in
      return false
    }))

    fileManager.mock(closure: .createDirectory({ path, intermediateDirectories, attributes in
      // no-op
    }))

    fileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal("\(filePath).json"))

      return true
    }))

    // when
    try subject.generate(fileManager: fileManager)

    expect(self.fileManager.allClosuresCalled).to(beTrue())
  }
  
  func test__generate__givenOperation_shouldWriteToRelativePath() throws {
    // given
    let filePath = "./path/to/match"
    try buildSubject(path: filePath)

    subject.collectOperationIdentifier(.mock(
      name: "TestQuery",
      type: .query,
      source: """
        query TestQuery {
          test
        }
        """
    ))

    fileManager.mock(closure: .fileExists({ path, isDirectory in
      return false
    }))

    fileManager.mock(closure: .createDirectory({ path, intermediateDirectories, attributes in
      // no-op
    }))

    fileManager.mock(closure: .createFile({ path, data, attributes in
      let expectedPath = URL(fileURLWithPath: String(filePath.dropFirst(2)), relativeTo: self.subject.config.rootURL)
        .resolvingSymlinksInPath()
        .appendingPathExtension("json")
        .path
      expect(path).to(equal(expectedPath))

      return true
    }))

    // when
    try subject.generate(fileManager: fileManager)

    expect(self.fileManager.allClosuresCalled).to(beTrue())
  }
  
  func test__generate__givenOperation_withPathExtension_shouldWriteToRelativePathWithSinglePathExtension() throws {
    // given
    let filePath = "./path/to/match"
    try buildSubject(path: "\(filePath).json")

    subject.collectOperationIdentifier(.mock(
      name: "TestQuery",
      type: .query,
      source: """
        query TestQuery {
          test
        }
        """
    ))

    fileManager.mock(closure: .fileExists({ path, isDirectory in
      return false
    }))

    fileManager.mock(closure: .createDirectory({ path, intermediateDirectories, attributes in
      // no-op
    }))

    fileManager.mock(closure: .createFile({ path, data, attributes in
      let expectedPath = URL(fileURLWithPath: String(filePath.dropFirst(2)), relativeTo: self.subject.config.rootURL)
        .resolvingSymlinksInPath()
        .appendingPathExtension("json")
        .path
      expect(path).to(equal(expectedPath))

      return true
    }))

    // when
    try subject.generate(fileManager: fileManager)

    expect(self.fileManager.allClosuresCalled).to(beTrue())
  }
  
  func test__generate__givenOperations_whenFileExists_shouldOverwrite() throws {
    // given
    let filePath = "path/that/exists"
    try buildSubject(path: filePath)

    subject.collectOperationIdentifier(.mock(
      name: "TestQuery",
      type: .query,
      source: """
        query TestQuery {
          test
        }
        """
    ))

    fileManager.mock(closure: .fileExists({ path, isDirectory in
      return true
    }))

    fileManager.mock(closure: .createDirectory({ path, intermediateDirectories, attributes in
      // no-op
    }))

    fileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal("\(filePath).json"))

      expect(String(data: data!, encoding: .utf8)).to(equal(
        """
        {
          "8ed9fcbb8ef3c853ad0ecdc920eb8216608bd7c3b32258744e9289ec0372eb30" : {
            "name": "TestQuery",
            "source": "query TestQuery { test }"
          }
        }
        """
      ))

      return true
    }))

    // when
    try subject.generate(fileManager: fileManager)

    expect(self.fileManager.allClosuresCalled).to(beTrue())
  }

  // MARK: - Template Type Selection Tests

  func test__template__givenOperationManifestVersion_legacy__isLegacyTemplate() throws {
    // given
    try buildSubject(path: "a/path", version: .legacy)

    // when
    let actual = subject.template

    // then
    expect(actual).to(beAKindOf(LegacyAPQOperationManifestTemplate.self))
  }

  func test__template__givenOperationManifestVersion_persistedQueries__isPersistedQueriesTemplate() throws {
    // given
    try buildSubject(path: "a/path", version: .persistedQueries)

    // when
    let actual = subject.template as? PersistedQueriesOperationManifestTemplate

    // then
    expect(actual).toNot(beNil())
    expect(actual?.config).to(beIdenticalTo(self.subject.config))
  }
}

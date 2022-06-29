import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloUtils
import ApolloCodegenInternalTestHelpers

class OperationIdentifierFileGeneratorTests: XCTestCase {
  var fileManager: MockFileManager!
  var subject: OperationIdentifiersFileGenerator!

  override func setUp() {
    super.setUp()

    fileManager = MockFileManager(strict: true)
  }

  override func tearDown() {
    subject = nil
    fileManager = nil
  }

  // MARK: Test Helpers

  private func buildSubject(path: String? = nil) throws {
    subject = try OperationIdentifiersFileGenerator(
      config: ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
        output: .init(
          schemaTypes: .init(path: "", moduleType: .swiftPackageManager),
          operationIdentifiersPath: path
        )
      ))
    ).xctUnwrapped()
  }

  private func buildOperation(
    name: String,
    type: CompilationResult.OperationType,
    source: String
  ) -> IR.Operation {
    let definition = CompilationResult.OperationDefinition.mock(
      name: name,
      type: type,
      source: source
    )

    return IR.Operation.mock(definition: definition)
  }

  // MARK: Initializer Tests

  func test__initializer__givenPath_shouldReturnInstance() {
    // given
    let config = ApolloCodegenConfiguration.mock(output: .init(
      schemaTypes: .init(path: "", moduleType: .swiftPackageManager),
      operationIdentifiersPath: "a/file/path"
    ))

    // when
    let instance = OperationIdentifiersFileGenerator(config: .init(config: config))

    // then
    expect(instance).notTo(beNil())
  }

  func test__initializer__givenNilPath_shouldReturnNil() {
    // given
    let config = ApolloCodegenConfiguration.mock(output: .init(
      schemaTypes: .init(path: "", moduleType: .swiftPackageManager),
      operationIdentifiersPath: nil
    ))

    // when
    let instance = OperationIdentifiersFileGenerator(config: .init(config: config))

    // then
    expect(instance).to(beNil())
  }

  // MARK: Generate Tests

  func test__generate__givenOperation_shouldWriteToPath() throws {
    // given
    let filePath = "path/to/match"
    try buildSubject(path: filePath)

    subject.collectOperationIdentifier(buildOperation(
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
      expect(path).to(equal(filePath))

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

    subject.collectOperationIdentifier(buildOperation(
      name: "TestQuery",
      type: .query,
      source: """
        query TestQuery {
          test
        }
        """
    ))

    fileManager.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(URL(fileURLWithPath: filePath).deletingLastPathComponent().path))
      isDirectory?.pointee = true

      return true
    }))

    fileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(filePath))

      expect(String(data: data!, encoding: .utf8)).to(equal(
        """
        {
          "b02d2d734060114f64b24338486748f4f1f00838e07a293cc4e0f73f98fe3dad": {
            "name": "TestQuery",
            "source": "query TestQuery {\\n  test\\n}"
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
}

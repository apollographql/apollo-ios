import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class SchemaFileGeneratorTests: XCTestCase {
  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  func test_generate_givenSchemaTypes_shouldOutputToPath() throws {
    // given
    let irSchema = IR.Schema(name: "MockSchema", referencedTypes: .init([]))
    let fileManager = MockFileManager(strict: false)

    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("Schema.swift")

    fileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // then
    try SchemaFileGenerator.generate(
      irSchema,
      directoryPath: rootURL.path,
      fileManager: fileManager
    )

    expect(fileManager.allClosuresCalled).to(beTrue())
  }
}

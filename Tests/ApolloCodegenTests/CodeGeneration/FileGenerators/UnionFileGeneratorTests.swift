import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class UnionFileGeneratorTests: XCTestCase {
  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  func test_generate_givenSchemaType_shouldOutputToPath() throws {
    // given
    let graphQLUnion = GraphQLUnionType.mock("MockUnion", types: [])
    let fileManager = MockFileManager(strict: false)

    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("MockUnion.swift")

    fileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // then
    try UnionFileGenerator.generate(
      graphQLUnion,
      moduleName: "ModuleAPI",
      directoryPath: rootURL.path,
      fileManager: fileManager
    )

    expect(fileManager.allClosuresCalled).to(beTrue())
  }
}

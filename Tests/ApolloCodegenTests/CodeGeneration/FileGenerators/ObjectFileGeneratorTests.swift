import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class ObjectFileGeneratorTests: XCTestCase {
  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  func test_generate_givenSchemaType_shouldWriteToCorrectFilePath() throws {
    // given
    let graphQLObject = GraphQLObjectType.mock("MockObject", fields: [:], interfaces: [])
    let fileManager = MockFileManager(strict: false)

    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("MockObject.swift")

    fileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // then
    try ObjectFileGenerator.generate(
      graphQLObject,
      directoryPath: rootURL.path,
      fileManager: fileManager
    )

    expect(fileManager.allClosuresCalled).to(beTrue())
  }
}

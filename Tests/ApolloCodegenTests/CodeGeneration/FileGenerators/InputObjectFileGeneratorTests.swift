import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class InputObjectFileGeneratorTests: XCTestCase {
  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  func test_generate_givenSchemaType_shouldWriteToCorrectFilePath() throws {
    // given
    let graphQLInputObject = GraphQLInputObjectType.mock("MockInputObject")
    let fileManager = MockFileManager(strict: false)

    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("MockInputObject.swift")

    fileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // then
    try InputObjectFileGenerator.generate(
      graphQLInputObject,
      directoryPath: rootURL.path,
      fileManager: fileManager
    )

    expect(fileManager.allClosuresCalled).to(beTrue())
  }
}

import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class TypeFileGeneratorTests: XCTestCase {
  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  func test_generate_givenSchemaType_shouldOutputToPath() throws {
    // given
    let schema = """
    type Query {
      books: [Book!]!
    }

    type Book {
      name: String!
    }
    """

    let operation = """
    query getBooks {
      books {
        name
      }
    }
    """

    let ir = try IR.mock(schema: schema, document: operation)
    let bookType = try ir.schema[object: "Book"].xctUnwrapped()

    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("Book.swift")

    let mockFileManager = MockFileManager(strict: false)

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))
      expect(String(data: try! data.xctUnwrapped(), encoding: .utf8))
        .to(equal("public class Book {}"))

      return true
    }))

    // then
    try TypeFileGenerator(
      objectType: bookType,
      directoryPath: rootURL.path,
      fileManager: mockFileManager
    ).generateFile()

    expect(mockFileManager.allClosuresCalled).to(beTrue())
  }
}

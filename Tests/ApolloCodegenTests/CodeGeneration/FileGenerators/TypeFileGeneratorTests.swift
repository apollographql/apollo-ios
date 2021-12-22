import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class TypeFileGeneratorTests: XCTestCase {
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

    let rootURL = URL(fileURLWithPath: "a/path")
    let fileURL = rootURL.appendingPathComponent("Book.swift")
    let mockFileManager = MockFileManager()

    mockFileManager.set(closure: .fileExists({ path, isDirectory in
      // This is a directory-level check, not a file-level check.
      return false
    }))
    mockFileManager.set(closure: .createDirectory({ path, createIntermediates, attributes in
      return
    }))
    mockFileManager.set(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))
      expect(String(data: try! data.xctUnwrapped(), encoding: .utf8))
        .to(equal("public class Book {}"))

      return true
    }))

    // then
    try TypeFileGenerator.generateFile(
      for: bookType,
      directoryPath: rootURL.path,
      fileManager: mockFileManager
    )

    expect(mockFileManager.allClosuresCalled).to(beTrue())
  }
}

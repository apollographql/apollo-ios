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
    let schema = """
    type Query {
      books: [Book!]!
      authors: [Author]!
    }

    type Book {
      name: String!
      author: String!
    }

    type Author {
      name: String!
    }
    """

    let operation = """
    query getBooks {
      books {
        name
        author {
          name
        }
      }
    }
    """

    let ir = try IR.mock(schema: schema, document: operation)

    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("Schema.swift")

    let mockFileManager = MockFileManager(strict: false)

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))
      expect(String(data: try! data.xctUnwrapped(), encoding: .utf8))
        .to(equal("public enum Schema {}"))

      return true
    }))

    // then
    try SchemaFileGenerator(
      name: "ModuleName",
      objectTypes: ir.schema.referencedTypes.objects,
      directoryPath: rootURL.path
    ).generateFile(fileManager: mockFileManager)

    expect(mockFileManager.allClosuresCalled).to(beTrue())
  }
}

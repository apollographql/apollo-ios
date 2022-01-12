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
    let schema = """
    union SearchResult = Person | Business

    type Person {
      name: String
      age: Int
    }

    type Business {
      name: String
      employeeCount: Int
    }

    type Query {
      searchResult: SearchResult
    }
    """

    let operation = """
    query SearchResult {
      searchResult {
        ... on Person {
          name
          age
        }
        ... on Business {
          name
          employeeCount
        }
      }
    }
    """

    let ir = try IR.mock(schema: schema, document: operation)
    let unionType = try ir.schema[union: "SearchResult"].xctUnwrapped()

    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("SearchResult.swift")

    let mockFileManager = MockFileManager(strict: false)

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))
      expect(String(data: try! data.xctUnwrapped(), encoding: .utf8))
        .to(equal("public enum SearchResult {}"))

      return true
    }))

    // then
    try UnionFileGenerator(
      unionType: unionType,
      directoryPath: rootURL.path
    ).generateFile(fileManager: mockFileManager)

    expect(mockFileManager.allClosuresCalled).to(beTrue())
  }
}

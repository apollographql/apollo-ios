import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class EnumFileGeneratorTests: XCTestCase {
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
      rating: Rating!
    }

    enum Rating {
      GOOD
      BAD
    }
    """

    let operation = """
    query getBooks {
      books {
        name
        rating
      }
    }
    """

    let ir = try IR.mock(schema: schema, document: operation)
    let ratingType = try ir.schema[enum: "Rating"].xctUnwrapped()

    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("Rating.swift")

    let mockFileManager = MockFileManager(strict: false)

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))
      expect(String(data: try! data.xctUnwrapped(), encoding: .utf8))
        .to(equal("public enum Rating {}"))

      return true
    }))

    // then
    try EnumFileGenerator(
      enumType: ratingType,
      directoryPath: rootURL.path
    ).generateFile(fileManager: mockFileManager)

    expect(mockFileManager.allClosuresCalled).to(beTrue())
  }
}

import XCTest
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib
import Nimble

class ApolloCodegenTests: XCTestCase {
  private let schemaSDL: String = {
    """
    type Query {
      books: [Book!]!
      authors: [Author!]!
    }

    type Book {
      title: String!
      author: Author!
    }

    type Author {
      name: String!
      books: [Book!]!
    }
    """
  }()

  let directoryURL = CodegenTestHelper.outputFolderURL().appendingPathComponent("Codegen")

  override func setUpWithError() throws {
    try FileManager.default.apollo.createDirectoryIfNeeded(atPath: directoryURL.path)
  }

  override func tearDownWithError() throws {
    try cleanTestOutput()
  }

  // MARK: Helpers

  private func cleanTestOutput() throws {
    try FileManager.default.apollo.deleteDirectory(atPath: directoryURL.path)
  }

  private func createSchema(at path: String) {
    expect(
      try FileManager.default.apollo.createFile(
        atPath: path,
        data: self.schemaSDL.data(using: .utf8)!
      )
    ).notTo(throwError())
  }

  private func createOperationFile(for data: Data, inDirectory directoryURL: URL) {
    expect(
      try FileManager.default.apollo.createFile(
        atPath: directoryURL.appendingPathComponent("\(UUID().uuidString).graphql").path,
        data: data
      )
    ).notTo(throwError())
  }

  // MARK: Tests

  func test_build_givenInvalidConfiguration_shouldThrow() throws {
    // given
    let config = ApolloCodegenConfiguration(basePath: "not_a_path")

    // then
    expect(try ApolloCodegen.build(with: config)).to(throwError())
  }

  func test_compileResults_givenOperation_withGraphQLErrors_shouldThrow() throws {
    // given
    let schemaPath = directoryURL.appendingPathComponent("schema.graphqls").path
    createSchema(at: schemaPath)

    let searchPath = directoryURL.appendingPathComponent("*.graphql").path
    let data: Data =
      """
      query getBooks {
        books {
          title
          name
        }
      }
      """.data(using: .utf8)!
    createOperationFile(for: data, inDirectory: directoryURL)

    let config = ApolloCodegenConfiguration.FileInput(
      schemaPath: schemaPath,
      searchPaths: [searchPath]
    )

    // with
    //
    // Fetching `books.name` will cause a GraphQL validation error because `name`
    // is not a property of the `Book` type.

    // then
    expect(try ApolloCodegen.compileResults(using: config))
    .to(throwError { error in
      guard case let ApolloCodegen.Error.validationFailed(lines) = error else {
        fail("Expected .validationFailed, got .\(error)")
        return
      }
      expect(lines).notTo(beEmpty())
    })
  }

  func test_compileResults_givenOperations_withNoErrors_shouldReturn() throws {
    // given
    let schemaPath = directoryURL.appendingPathComponent("schema.graphqls").path
    createSchema(at: schemaPath)

    let searchPath = directoryURL.appendingPathComponent("*.graphql").path
    let booksData: Data =
      """
      query getBooks {
        books {
          title
        }
      }
      """.data(using: .utf8)!
    createOperationFile(for: booksData, inDirectory: directoryURL)

    let authorsData: Data =
      """
      query getAuthors {
        authors {
          name
        }
      }
      """.data(using: .utf8)!
    createOperationFile(for: authorsData, inDirectory: directoryURL)

    let config = ApolloCodegenConfiguration.FileInput(
      schemaPath: schemaPath,
      searchPaths: [searchPath]
    )

    // then
    expect(try ApolloCodegen.compileResults(using: config).operations).to(haveCount(2))
  }
}

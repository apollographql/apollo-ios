import XCTest
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib
import Nimble

class ApolloCodegenTests: XCTestCase {
  override func setUpWithError() throws {
    try FileManager.default.apollo.createDirectoryIfNeeded(atPath: directoryURL.path)
  }

  override func tearDownWithError() throws {
    try cleanTestOutput()
  }

  // MARK: Helpers

  private let directoryURL = CodegenTestHelper.outputFolderURL().appendingPathComponent("Codegen")

  private let schemaData: Data = {
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
  }().data(using: .utf8)!

  private func cleanTestOutput() throws {
    try FileManager.default.apollo.deleteDirectory(atPath: directoryURL.path)
  }

  /// Creates a file in the test directory.
  ///
  /// - Parameters:
  ///   - data: File content
  ///   - filename: Target name of the file. This should not include any path information
  ///
  /// - Returns:
  ///    - The full path of the created file.
  @discardableResult
  private func createFile(containing data: Data, named filename: String) -> String {
    let path = directoryURL.appendingPathComponent(filename).path
    expect(
      try FileManager.default.apollo.createFile(atPath: path, data: data)
    ).notTo(throwError())

    return path
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
    let schemaPath = createFile(containing: schemaData, named: "schema.graphqls")

    let operationData: Data =
      """
      query getBooks {
        books {
          title
          name
        }
      }
      """.data(using: .utf8)!
    createFile(containing: operationData, named: "operation.graphql")

    let config = ApolloCodegenConfiguration.FileInput(
      schemaPath: schemaPath,
      searchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )

    // with
    //
    // Fetching `books.name` will cause a GraphQL validation error because `name`
    // is not a property of the `Book` type.

    // then
    expect(try ApolloCodegen.compileGraphQLResult(using: config))
    .to(throwError { error in
      guard case let ApolloCodegen.Error.graphQLSourceValidationFailed(lines) = error else {
        fail("Expected .validationFailed, got .\(error)")
        return
      }
      expect(lines).notTo(beEmpty())
    })
  }

  func test_compileResults_givenOperations_withNoErrors_shouldReturn() throws {
    // given
    let schemaPath = createFile(containing: schemaData, named: "schema.graphqls")

    let booksData: Data =
      """
      query getBooks {
        books {
          title
        }
      }
      """.data(using: .utf8)!
    createFile(containing: booksData, named: "books-operation.graphql")

    let authorsData: Data =
      """
      query getAuthors {
        authors {
          name
        }
      }
      """.data(using: .utf8)!
    createFile(containing: authorsData, named: "authors-operation.graphql")

    let config = ApolloCodegenConfiguration.FileInput(
      schemaPath: schemaPath,
      searchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )

    // then
    expect(try ApolloCodegen.compileGraphQLResult(using: config).operations).to(haveCount(2))
  }

  func test_compileResults_givenSchema_withNoOperations_shouldReturnEmpty() throws {
    // given
    let schemaPath = createFile(containing: schemaData, named: "schema.graphqls")

    let config = ApolloCodegenConfiguration.FileInput(
      schemaPath: schemaPath,
      searchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )

    // then
    expect(try ApolloCodegen.compileGraphQLResult(using: config).operations).to(beEmpty())
  }
}

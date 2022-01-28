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

  // MARK: Configuration Tests

  func test_build_givenInvalidConfiguration_shouldThrow() throws {
    // given
    let config = ApolloCodegenConfiguration(basePath: "not_a_path")

    // then
    expect(try ApolloCodegen.build(with: config)).to(throwError())
  }

  // MARK: CompilationResult Tests

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
      guard case let ApolloCodegen.Error.graphQLSourceValidationFailure(lines) = error else {
        fail("Expected .graphQLSourceValidationFailure, got .\(error)")
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

  // MARK: File Generator Tests

  func test_fileGenerators_givenSchema_shouldCreateFileGeneratorsForUsedSchemaTypes() throws {
    // given
    let schema = """
    interface NamedEntity {
      name: String
    }

    type Person implements NamedEntity {
      name: String
      age: Int
    }

    type Business implements NamedEntity {
      name: String
      type: BUSINESS_TYPE
    }

    enum BUSINESS_TYPE {
      MOM_AND_POP
      BIG_RETAIL
    }

    type Contact {
      entity: NamedEntity!
      address: String
      phoneNumber: String
    }

    union SearchResult = Person | Business

    input ContactInput {
      name: String
      address: String
      phoneNumber: String
    }

    type Query {
      contacts: [Contact!]
      searchResult: SearchResult
    }

    type Mutation {
      createContact(contact: ContactInput!): Contact
    }
    """

    let operations = """
    query AllContacts {
      contacts {
        entity {
          name
        }
      }
    }

    query FindEntity {
      searchResult {
        ... on Person {
          name
          age
        }
        ... on Business {
          name
          type
        }
      }
    }

    mutation CreateContact($contact: ContactInput!) {
      createContact(contact: $contact) {
        entity {
          name
        }
      }
    }
    """

    let ir = try IR.mock(schema: schema, document: operations)
    let namedEntityInterface = try ir.schema[interface: "NamedEntity"].xctUnwrapped()
    let personObject = try ir.schema[object: "Person"].xctUnwrapped()
    let businessObject = try ir.schema[object: "Business"].xctUnwrapped()
    let contactObject = try ir.schema[object: "Contact"].xctUnwrapped()
    let businessTypeEnum = try ir.schema[enum: "BUSINESS_TYPE"].xctUnwrapped()
    let searchResultUnion = try ir.schema[union: "SearchResult"].xctUnwrapped()
    let contactInput = try ir.schema[inputObject: "ContactInput"].xctUnwrapped()

    let directoryPath = CodegenTestHelper.outputFolderURL().path

    // then
    expect(ApolloCodegen.fileGenerators(
      for: ir.schema.referencedTypes.interfaces,
      directoryPath:directoryPath
    )).to(equal([
      InterfaceFileGenerator(interfaceType: namedEntityInterface, directoryPath: directoryPath)
    ]))

    expect(ApolloCodegen.fileGenerators(
      for: ir.schema.referencedTypes.objects,
      directoryPath: directoryPath
    )).to(equal([
      TypeFileGenerator(objectType: contactObject, directoryPath: directoryPath),
      TypeFileGenerator(objectType: personObject, directoryPath: directoryPath),
      TypeFileGenerator(objectType: businessObject, directoryPath: directoryPath)
    ]))

    expect(ApolloCodegen.fileGenerators(
      for: ir.schema.referencedTypes.enums,
      directoryPath: directoryPath
    )).to(equal([
      EnumFileGenerator(enumType: businessTypeEnum, directoryPath: directoryPath)
    ]))

    expect(ApolloCodegen.fileGenerators(
      for: ir.schema.referencedTypes.unions,
      moduleName: ir.schema.name,
      directoryPath: directoryPath
    )).to(equal([
      UnionFileGenerator(
        unionType: searchResultUnion,
        moduleName: "TestSchema",
        directoryPath: directoryPath
      )
    ]))

    expect(ApolloCodegen.fileGenerators(
      for: ir.schema.referencedTypes.inputObjects,
      directoryPath: directoryPath
    )).to(equal([
      InputObjectFileGenerator(inputObjectType: contactInput, directoryPath: directoryPath)
    ]))
  }
}

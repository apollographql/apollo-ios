import XCTest
import ApolloInternalTestHelpers
@testable import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib
import Nimble

class ApolloCodegenTests: XCTestCase {
  private var directoryURL: URL { testFileManager.directoryURL }
  private var testFileManager: TestIsolatedFileManager!

  override func setUpWithError() throws {    
    testFileManager = try testIsolatedFileManager()

    testFileManager.fileManager.changeCurrentDirectoryPath(directoryURL.path)
  }

  override func tearDownWithError() throws {
    testFileManager = nil
  }

  // MARK: Helpers

  private let schemaData: Data = {
    """
    type Query {
      books: [Book!]!
      authors: [Author!]!
    }

    type Mutation {
      books: [Book!]!
      authors: [Author!]!
    }

    type Subscription {
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

  /// Creates a file in the test directory.
  ///
  /// - Parameters:
  ///   - data: File content
  ///   - filename: Target name of the file. This should not include any path information
  ///
  /// - Returns:
  ///    - The full path of the created file.
  @discardableResult
  private func createFile(
    containing data: Data,
    named filename: String,
    inDirectory directory: String? = nil
  ) throws -> String {
    return try self.testFileManager.createFile(
      containing: data,
      named: filename,
      inDirectory: directory
    )
  }

  @discardableResult
  private func createFile(
    body: @autoclosure () -> String = "Test File",
    filename: String,
    inDirectory directory: String? = nil
  ) throws -> String {
    return try self.testFileManager.createFile(
      body: body(),
      named: filename,
      inDirectory: directory
    )
  }

  @discardableResult
  private func createOperationFile(
    type: CompilationResult.OperationType,
    named operationName: String,
    filename: String,
    inDirectory directory: String? = nil
  ) throws -> String {
    let query: String =
      """
      \(type.rawValue) \(operationName) {
        books {
          title
        }
      }
      """
    return try createFile(body: query, filename: filename, inDirectory: directory)
  }

  // MARK: CompilationResult Tests

  func test_compileResults_givenOperation_withGraphQLErrors_shouldThrow() throws {
    // given
    let schemaPath = try createFile(containing: schemaData, named: "schema.graphqls")

    let operationData: Data =
      """
      query getBooks {
        books {
          title
          name
        }
      }
      """.data(using: .utf8)!
    try createFile(containing: operationData, named: "operation.graphql")

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )), rootURL: nil)

    // with
    //
    // Fetching `books.name` will cause a GraphQL validation error because `name`
    // is not a property of the `Book` type.

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config))
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
    let schemaPath = try createFile(containing: schemaData, named: "schema.graphqls")

    let booksData: Data =
      """
      query getBooks {
        books {
          title
        }
      }
      """.data(using: .utf8)!
    try createFile(containing: booksData, named: "books-operation.graphql")

    let authorsData: Data =
      """
      query getAuthors {
        authors {
          name
        }
      }
      """.data(using: .utf8)!
    try createFile(containing: authorsData, named: "authors-operation.graphql")

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )), rootURL: nil)

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config).operations).to(haveCount(2))
  }

  func test_compileResults_givenRelativeSearchPath_relativeToRootURL_hasOperations_shouldReturnOperationsRelativeToRoot() throws {
    // given
    let schemaPath = try createFile(containing: schemaData, named: "schema.graphqls")

    let rootURL = directoryURL.appendingPathComponent("CustomRoot")

    let booksData: Data =
      """
      query getBooks {
        books {
          title
        }
      }
      """.data(using: .utf8)!
    try createFile(containing: booksData, named: "books-operation.graphql", inDirectory: "CustomRoot")

    let authorsData: Data =
      """
      query getAuthors {
        authors {
          name
        }
      }
      """.data(using: .utf8)!
    try createFile(containing: authorsData, named: "authors-operation.graphql")

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      operationSearchPaths: ["./**/*.graphql"]
    )), rootURL: rootURL)

    let actual = try ApolloCodegen.compileGraphQLResult(config).operations

    // then
    expect(actual).to(haveCount(1))
    expect(actual.first?.name).to(equal("getBooks"))
  }

  func test_CCN_compileResults_givenOperations_withNoErrors_shouldReturn() throws {
    let schemaData: Data = {
      """
      type Query {
        author: Author
      }

      type Author {
        name: String
        age: Int
      }
      """
    }().data(using: .utf8)!
    // given
    let schemaPath = try createFile(containing: schemaData, named: "schema.graphqls")

    let authorsData: Data =
      """
      query getAuthors {
        author! {
          name!
        }
      }
      """.data(using: .utf8)!
    try createFile(containing: authorsData, named: "authors-operation.graphql")

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )), rootURL: nil)

    let compiledDocument = try ApolloCodegen.compileGraphQLResult(
      config,
      experimentalFeatures: .init(clientControlledNullability: true)
    )

    // then
    expect(compiledDocument.operations).to(haveCount(1))
  }

  func test_CCN_compileResults_givenOperations_withErrors_shouldError() throws {
    // given
    let schemaPath = try createFile(containing: schemaData, named: "schema.graphqls")

    let authorsData: Data =
      """
      query getAuthors {
        authors {
          name!
        }
      }
      """.data(using: .utf8)!
    try createFile(containing: authorsData, named: "authors-operation.graphql")

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )), rootURL: nil)

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config).operations).to(throwError { error in
      guard let error = error as? GraphQLError else {
        fail("Expected .graphQLSourceValidationFailure because we attempted to compile a document that uses CCN without CCN enabled, got \(error)")
        return
      }
      expect(error.message).to(equal("Syntax Error: Expected Name, found \"!\"."))
    })
  }

  func test_compileResults_givenRelativeSchemaSearchPath_relativeToRootURL_shouldReturnSchemaRelativeToRoot() throws {
    // given
    try createFile(
      body: """
      type QueryTwo {
        string: String!
      }
      """,
      filename: "schema1.graphqls")

    try createFile(containing: schemaData, named: "schema.graphqls", inDirectory: "CustomRoot")

    try createFile(
      body: """
      query getAuthors {
        authors {
          name
        }
      }
      """,
      filename: "TestQuery.graphql")

    let rootURL = directoryURL.appendingPathComponent("CustomRoot")

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaSearchPaths: ["./**/*.graphqls"],
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )), rootURL: rootURL)

    let actual = try ApolloCodegen.compileGraphQLResult(config)

    // then
    expect(actual.operations).to(haveCount(1))
    expect(actual.referencedTypes).to(haveCount(3))
  }

  func test__compileResults__givenMultipleSchemaFiles_withDependentTypes_compilesResult() throws {
    // given
    try createFile(
      body: """
      type Query {
        books: [Book!]!
        authors: [Author!]!
      }
      """,
      filename: "schema1.graphqls")

    try createFile(
      body: """
      type Book {
        title: String!
        author: Author!
      }

      type Author {
        name: String!
        books: [Book!]!
      }
      """,
      filename: "schema2.graphqls")

    try createFile(
      body: """
      query getAuthors {
        authors {
          name
        }
      }
      """,
      filename: "TestQuery.graphql")

    // when
    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaSearchPaths: [directoryURL.appendingPathComponent("schema*.graphqls").path],
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )), rootURL: nil)

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config).referencedTypes.count).to(equal(3))
  }

  func test__compileResults__givenMultipleSchemaFiles_withDifferentRootTypes_compilesResult() throws {
    // given
    try createFile(
      body: """
      type Query {
        string: String!
      }
      """,
      filename: "schema1.graphqls")

    try createFile(
      body: """
      type Subscription {
        bool: Boolean!
      }
      """,
      filename: "schema2.graphqls")

    try createFile(
      body: """
      query TestQuery {
        string
      }
      """,
      filename: "TestQuery.graphql")

    try createFile(
      body: """
      subscription TestSubscription {
        bool
      }
      """,
      filename: "TestSubscription.graphql")

    // when
    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaSearchPaths: [directoryURL.appendingPathComponent("schema*.graphqls").path],
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )), rootURL: nil)

    let result = try ApolloCodegen.compileGraphQLResult(config)

    // then
    expect(result.operations.count).to(equal(2))
  }

  func test__compileResults__givenMultipleSchemaFiles_withSchemaTypeExtension_compilesResultWithExtension() throws {
    // given
    try createFile(
      body: """
      type Query {
        string: String!
      }
      """,
      filename: "schema1.graphqls")

    try createFile(
      body: """
      extend type Query {
        bool: Boolean!
      }
      """,
      filename: "schemaExtension.graphqls")

    try createFile(
      body: """
      query TestQuery {
        string
        bool
      }
      """,
      filename: "TestQuery.graphql")

    // when
    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaSearchPaths: [directoryURL.appendingPathComponent("schema*.graphqls").path],
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )), rootURL: nil)

    let result = try ApolloCodegen.compileGraphQLResult(config)

    // then
    expect(result.operations.count).to(equal(1))
  }

  func test__compileResults__givenMultipleSchemaFilesWith_introspectionJSONSchema_withSchemaTypeExtension_compilesResultWithExtension() throws {
    // given
    let introspectionJSON = try String(
      contentsOf: ApolloCodegenInternalTestHelpers.Resources.StarWars.JSONSchema
    )
    
    try createFile(body: introspectionJSON, filename: "schemaJSON.json")

    try createFile(
      body: """
      extend type Query {
        testExtensionField: Boolean!
      }
      """,
      filename: "schemaExtension.graphqls")

    try createFile(
      body: """
      query TestQuery {
        testExtensionField
      }
      """,
      filename: "TestQuery.graphql")

    // when
    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaSearchPaths: [
        directoryURL.appendingPathComponent("schema*.graphqls").path,
        directoryURL.appendingPathComponent("schema*.json").path,
      ],
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )), rootURL: nil)

    let result = try ApolloCodegen.compileGraphQLResult(config)

    // then
    expect(result.operations.count).to(equal(1))
  }

  func test__compileResults__givenMultipleIntrospectionJSONSchemaFiles_throwsError() throws {
    // given
    let introspectionJSON = try String(
      contentsOf: ApolloCodegenInternalTestHelpers.Resources.StarWars.JSONSchema
    )

    try createFile(body: introspectionJSON, filename: "schemaJSON1.json")
    try createFile(body: introspectionJSON, filename: "schemaJSON2.json")

    // when
    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaSearchPaths: [
        directoryURL.appendingPathComponent("schema*.graphqls").path,
        directoryURL.appendingPathComponent("schema*.json").path,
      ],
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )), rootURL: nil)

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config)).to(throwError())
  }

  func test__compileResults__givenSchemaSearchPath_withNoMatches_throwsError() throws {
    // given
    let config = ApolloCodegen.ConfigurationContext(config: .mock(
      input: .init(schemaPath: directoryURL.appendingPathComponent("file_does_not_exist").path)))

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config))
      .to(throwError(ApolloCodegen.Error.cannotLoadSchema))
  }

  func test__compileResults__givenSchemaSearchPaths_withMixedMatches_doesNotThrowError() throws {
    // given
    let schemaPath = try createFile(containing: schemaData, named: "schema.graphqls")

    let operationPath = try createOperationFile(
      type: .query,
      named: "TestQuery",
      filename: "TestQuery.graphql"
    )

    let config = ApolloCodegen.ConfigurationContext(config: .mock(
      input: .init(
        schemaSearchPaths: [
          schemaPath,
          directoryURL.appendingPathComponent("file_does_not_exist").path
        ],
        operationSearchPaths: [operationPath]
      )))

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config))
      .notTo(throwError())
  }

  func test__compileResults__givenOperationSearchPath_withNoMatches_throwsError() throws {
    // given
    let schemaPath = try createFile(containing: schemaData, named: "schema.graphqls")

    let config = ApolloCodegen.ConfigurationContext(config: .mock(
      input: .init(
        schemaPath: schemaPath,
        operationSearchPaths: [directoryURL.appendingPathComponent("file_does_not_exist").path])))

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config))
      .to(throwError(ApolloCodegen.Error.cannotLoadOperations))
  }

  func test__compileResults__givenOperationSearchPaths_withMixedMatches_doesNotThrowError() throws {
    // given
    let schemaPath = try createFile(containing: schemaData, named: "schema.graphqls")

    let operationPath = try createOperationFile(
      type: .query,
      named: "TestQuery",
      filename: "TestQuery.graphql"
    )

    let config = ApolloCodegen.ConfigurationContext(config: .mock(
      input: .init(
        schemaPath: schemaPath,
        operationSearchPaths: [
          operationPath,
          directoryURL.appendingPathComponent("file_does_not_exist").path
        ])))

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config))
      .notTo(throwError())
  }

  // MARK: File Generator Tests

  func test_fileGenerators_givenSchemaAndMultipleOperationDocuments_operations_inSchemaModule_shouldGenerateSchemaAndOperationsFiles() throws {
    // given
    let schemaPath = ApolloCodegenInternalTestHelpers.Resources.AnimalKingdom.Schema.path
    let operationsPath = ApolloCodegenInternalTestHelpers.Resources.url
      .appendingPathComponent("animalkingdom-graphql")
      .appendingPathComponent("*.graphql").path

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      schemaName: "AnimalKingdomAPI",
      input: .init(
        schemaPath: schemaPath,
        operationSearchPaths: [operationsPath]
      ),
      output: .mock(
        moduleType: .swiftPackageManager,
        operations: .inSchemaModule,
        path: directoryURL.path
      )
    ), rootURL: nil)

    let fileManager = MockApolloFileManager(strict: false)

    var filePaths: Set<String> = []
    fileManager.mock(closure: .createFile({ path, data, attributes in
      filePaths.insert(path)
      return true
    }))

    let expectedPaths: Set<String> = [
      directoryURL.appendingPathComponent("Sources/Schema/SchemaMetadata.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/SchemaConfiguration.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Enums/SkinCovering.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/Pet.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/Animal.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/WarmBlooded.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/HousePet.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Enums/SkinCovering.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Enums/RelativeSize.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Unions/ClassroomPet.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/PetAdoptionInput.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/PetSearchFilters.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/MeasurementsInput.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Objects/Height.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Query.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Cat.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Human.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Bird.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Rat.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/PetRock.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Fish.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Crocodile.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Mutation.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Dog.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/CustomScalars/CustomDate.swift").path,
      
      directoryURL.appendingPathComponent("Sources/Operations/Queries/AllAnimalsQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/AllAnimalsIncludeSkipQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/ClassroomPetsQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/DogQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/PetSearchQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/PetSearchQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Mutations/PetAdoptionMutation.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Fragments/PetDetails.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/DogFragment.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/ClassroomPetDetails.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/HeightInMeters.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/WarmBloodedDetails.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/LocalCacheMutations/AllAnimalsLocalCacheMutation.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/LocalCacheMutations/PetDetailsMutation.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/LocalCacheMutations/PetSearchLocalCacheMutation.graphql.swift").path,

      directoryURL.appendingPathComponent("Package.swift").path,
    ]

    // when
    let compilationResult = try ApolloCodegen.compileGraphQLResult(config)

    let ir = IR(compilationResult: compilationResult)

    try ApolloCodegen.generateFiles(
      compilationResult: compilationResult,
      ir: ir,
      config: config,
      fileManager: fileManager
    )

    // then
    expect(filePaths).to(equal(expectedPaths))
    expect(fileManager.allClosuresCalled).to(beTrue())
  }

  func test_fileGenerators_givenSchemaAndMultipleOperationDocuments_operations_absolute_shouldGenerateSchemaAndOperationsFiles() throws {
    // given
    let schemaPath = ApolloCodegenInternalTestHelpers.Resources.AnimalKingdom.Schema.path
    let operationsPath = ApolloCodegenInternalTestHelpers.Resources.url
      .appendingPathComponent("animalkingdom-graphql")
      .appendingPathComponent("*.graphql").path

    let operationsOutputURL = directoryURL.appendingPathComponent("AbsoluteSources")

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      schemaName: "AnimalKingdomAPI",
      input: .init(
        schemaPath: schemaPath,
        operationSearchPaths: [operationsPath]
      ),
      output: .mock(
        moduleType: .swiftPackageManager,
        operations: .absolute(path: operationsOutputURL.path),
        path: directoryURL.path
      )
    ), rootURL: nil)

    let fileManager = MockApolloFileManager(strict: false)

    var filePaths: Set<String> = []
    fileManager.mock(closure: .createFile({ path, data, attributes in
      filePaths.insert(path)
      return true
    }))

    let expectedPaths: Set<String> = [
      directoryURL.appendingPathComponent("Sources/SchemaMetadata.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/SchemaConfiguration.swift").path,

      directoryURL.appendingPathComponent("Sources/Enums/SkinCovering.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Interfaces/Pet.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Interfaces/Animal.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Interfaces/WarmBlooded.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Interfaces/HousePet.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Enums/SkinCovering.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Enums/RelativeSize.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Unions/ClassroomPet.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/InputObjects/PetAdoptionInput.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/InputObjects/PetSearchFilters.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/InputObjects/MeasurementsInput.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Height.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Query.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Cat.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Human.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Bird.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Rat.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/PetRock.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Fish.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Crocodile.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Mutation.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Dog.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/CustomScalars/CustomDate.swift").path,

      operationsOutputURL.appendingPathComponent("Queries/AllAnimalsQuery.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("Queries/DogQuery.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("Queries/AllAnimalsIncludeSkipQuery.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("Queries/ClassroomPetsQuery.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("Queries/PetSearchQuery.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("Queries/PetSearchQuery.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("Mutations/PetAdoptionMutation.graphql.swift").path,

      operationsOutputURL.appendingPathComponent("Fragments/PetDetails.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("Fragments/DogFragment.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("Fragments/ClassroomPetDetails.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("Fragments/HeightInMeters.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("Fragments/WarmBloodedDetails.graphql.swift").path,

      operationsOutputURL.appendingPathComponent("LocalCacheMutations/AllAnimalsLocalCacheMutation.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("LocalCacheMutations/PetDetailsMutation.graphql.swift").path,
      operationsOutputURL.appendingPathComponent("LocalCacheMutations/PetSearchLocalCacheMutation.graphql.swift").path,

      directoryURL.appendingPathComponent("Package.swift").path,
    ]

    // when
    let compilationResult = try ApolloCodegen.compileGraphQLResult(config)

    let ir = IR(compilationResult: compilationResult)

    try ApolloCodegen.generateFiles(
      compilationResult: compilationResult,
      ir: ir,
      config: config,
      fileManager: fileManager
    )

    // then
    expect(filePaths).to(equal(expectedPaths))
    expect(fileManager.allClosuresCalled).to(beTrue())
  }

  func test_fileGenerators_givenSchemaAndMultipleOperationDocuments_shouldGenerateSchemaAndOperationsFiles_CCN() throws {
    // given
    let schemaPath = ApolloCodegenInternalTestHelpers.Resources.AnimalKingdom.Schema.path
    let operationsPath = ApolloCodegenInternalTestHelpers.Resources.url
      .appendingPathComponent("animalkingdom-graphql")
      .appendingPathComponent("**/*.graphql").path

    let config =  ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration(
      schemaName: "AnimalKingdomAPI",
      input: .init(schemaPath: schemaPath, operationSearchPaths: [operationsPath]),
      output: .mock(
        moduleType: .swiftPackageManager,
        operations: .inSchemaModule,
        path: directoryURL.path
      )
    ), rootURL: nil)

    let fileManager = MockApolloFileManager(strict: false)

    var filePaths: Set<String> = []
    fileManager.mock(closure: .createFile({ path, data, attributes in
      filePaths.insert(path)
      return true
    }))

    let expectedPaths: Set<String> = [
      directoryURL.appendingPathComponent("Sources/Schema/SchemaMetadata.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/SchemaConfiguration.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/Pet.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/Animal.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/WarmBlooded.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/HousePet.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Enums/SkinCovering.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Enums/RelativeSize.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Unions/ClassroomPet.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/PetAdoptionInput.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/PetSearchFilters.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/MeasurementsInput.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Objects/Height.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Query.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Cat.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Human.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Bird.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Rat.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/PetRock.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Mutation.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Dog.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Fish.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Crocodile.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/CustomScalars/CustomDate.swift").path,

      directoryURL.appendingPathComponent("Sources/Operations/Queries/AllAnimalsQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/DogQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/ClassroomPetsQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/PetSearchQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/PetSearchQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/AllAnimalsIncludeSkipQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/AllAnimalsCCNQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/ClassroomPetsCCNQuery.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Operations/Mutations/PetAdoptionMutation.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/Fragments/ClassroomPetDetailsCCN.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/PetDetails.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/DogFragment.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/ClassroomPetDetails.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/HeightInMeters.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/WarmBloodedDetails.graphql.swift").path,

      directoryURL.appendingPathComponent("Sources/LocalCacheMutations/AllAnimalsLocalCacheMutation.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/LocalCacheMutations/PetDetailsMutation.graphql.swift").path,
      directoryURL.appendingPathComponent("Sources/LocalCacheMutations/PetSearchLocalCacheMutation.graphql.swift").path,

      directoryURL.appendingPathComponent("Package.swift").path,
    ]

    // when
    let compilationResult = try ApolloCodegen.compileGraphQLResult(
      config,
      experimentalFeatures: .init(clientControlledNullability: true)
    )

    let ir = IR(compilationResult: compilationResult)

    try ApolloCodegen.generateFiles(
      compilationResult: compilationResult,
      ir: ir,
      config: config,
      fileManager: fileManager
    )

    // then
    expect(filePaths).to(equal(expectedPaths))
    expect(fileManager.allClosuresCalled).to(beTrue())
  }

  func test_fileGenerators_givenTestMockOutput_absolutePath_shouldGenerateTestMocks() throws {
    // given
    let schemaPath = ApolloCodegenInternalTestHelpers.Resources.AnimalKingdom.Schema.path
    let operationsPath = ApolloCodegenInternalTestHelpers.Resources.url
      .appendingPathComponent("animalkingdom-graphql")
      .appendingPathComponent("**/*.graphql").path

    let config =  ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration(
      schemaName: "AnimalKingdomAPI",
      input: .init(schemaPath: schemaPath, operationSearchPaths: [operationsPath]),
      output: .init(
        schemaTypes: .init(path: directoryURL.path,
                           moduleType: .swiftPackageManager),
        operations: .inSchemaModule,
        testMocks: .absolute(path: directoryURL.appendingPathComponent("TestMocks").path)
      )
    ), rootURL: nil)

    let fileManager = MockApolloFileManager(strict: false)

    var filePaths: Set<String> = []
    fileManager.mock(closure: .createFile({ path, data, attributes in
      if path.contains("/TestMocks/") {
        filePaths.insert(path)
      }
      return true
    }))

    let expectedPaths: Set<String> = [
      directoryURL.appendingPathComponent("TestMocks/Height+Mock.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Query+Mock.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Cat+Mock.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Human+Mock.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Bird+Mock.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Rat+Mock.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/PetRock+Mock.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Mutation+Mock.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Dog+Mock.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Fish+Mock.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Crocodile+Mock.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/MockObject+Unions.graphql.swift").path,
      directoryURL.appendingPathComponent("TestMocks/MockObject+Interfaces.graphql.swift").path,
    ]

    // when
    let compilationResult = try ApolloCodegen.compileGraphQLResult(
      config,
      experimentalFeatures: .init(clientControlledNullability: true)
    )

    let ir = IR(compilationResult: compilationResult)

    try ApolloCodegen.generateFiles(
      compilationResult: compilationResult,
      ir: ir,
      config: config,
      fileManager: fileManager
    )

    // then
    expect(filePaths).to(equal(expectedPaths))
    expect(fileManager.allClosuresCalled).to(beTrue())
  }

  // MARK: Custom Root URL Tests

  func test_fileGenerators_givenCustomRootDirectoryPath_operations_inSchemaModule__shouldGenerateFilesWithCustomRootPath() throws {
    // given
    let schemaPath = ApolloCodegenInternalTestHelpers.Resources.AnimalKingdom.Schema.path
    let operationsPath = ApolloCodegenInternalTestHelpers.Resources.url
      .appendingPathComponent("animalkingdom-graphql")
      .appendingPathComponent("*.graphql").path

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      schemaName: "AnimalKingdomAPI",
      input: .init(
        schemaPath: schemaPath,
        operationSearchPaths: [operationsPath]
      ),
      output: .mock(
        moduleType: .swiftPackageManager,
        operations: .inSchemaModule,
        path: "./RelativePath"
      )
    ), rootURL: directoryURL)

    let fileManager = MockApolloFileManager(strict: false)

    var filePaths: Set<String> = []
    fileManager.mock(closure: .createFile({ path, data, attributes in
      filePaths.insert(path)
      return true
    }))

    let expectedPaths: Set<String> = [
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/SchemaMetadata.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/SchemaConfiguration.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Enums/SkinCovering.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Interfaces/Pet.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Interfaces/Animal.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Interfaces/WarmBlooded.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Interfaces/HousePet.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Enums/SkinCovering.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Enums/RelativeSize.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Unions/ClassroomPet.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/InputObjects/PetAdoptionInput.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/InputObjects/PetSearchFilters.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/InputObjects/MeasurementsInput.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Objects/Height.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Objects/Query.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Objects/Cat.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Objects/Human.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Objects/Bird.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Objects/Rat.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Objects/PetRock.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Objects/Fish.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Objects/Crocodile.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Objects/Mutation.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/Objects/Dog.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Schema/CustomScalars/CustomDate.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Operations/Queries/AllAnimalsQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Operations/Queries/DogQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Operations/Queries/AllAnimalsIncludeSkipQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Operations/Queries/ClassroomPetsQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Operations/Queries/PetSearchQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Operations/Queries/PetSearchQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Operations/Mutations/PetAdoptionMutation.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Fragments/PetDetails.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Fragments/DogFragment.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Fragments/ClassroomPetDetails.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Fragments/HeightInMeters.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Fragments/WarmBloodedDetails.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/LocalCacheMutations/AllAnimalsLocalCacheMutation.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/LocalCacheMutations/PetDetailsMutation.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/LocalCacheMutations/PetSearchLocalCacheMutation.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Package.swift").path,
    ]

    // when
    let compilationResult = try ApolloCodegen.compileGraphQLResult(config)

    let ir = IR(compilationResult: compilationResult)

    try ApolloCodegen.generateFiles(
      compilationResult: compilationResult,
      ir: ir,
      config: config,
      fileManager: fileManager
    )

    // then
    expect(filePaths).to(equal(expectedPaths))
    expect(fileManager.allClosuresCalled).to(beTrue())
  }

  func test_fileGenerators_givenCustomRootDirectoryPath_operations_absolute__shouldGenerateFilesWithCustomRootPath() throws {
    // given
    let schemaPath = ApolloCodegenInternalTestHelpers.Resources.AnimalKingdom.Schema.path
    let operationsPath = ApolloCodegenInternalTestHelpers.Resources.url
      .appendingPathComponent("animalkingdom-graphql")
      .appendingPathComponent("*.graphql").path

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      schemaName: "AnimalKingdomAPI",
      input: .init(
        schemaPath: schemaPath,
        operationSearchPaths: [operationsPath]
      ),
      output: .mock(
        moduleType: .swiftPackageManager,
        operations: .absolute(path: "./RelativeOperations"),
        path: "./RelativePath"
      )
    ), rootURL: directoryURL)

    let fileManager = MockApolloFileManager(strict: false)

    var filePaths: Set<String> = []
    fileManager.mock(closure: .createFile({ path, data, attributes in
      filePaths.insert(path)
      return true
    }))

    let expectedPaths: Set<String> = [
      directoryURL.appendingPathComponent("RelativePath/Sources/SchemaMetadata.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/SchemaConfiguration.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Enums/SkinCovering.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Interfaces/Pet.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Interfaces/Animal.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Interfaces/WarmBlooded.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Interfaces/HousePet.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Enums/SkinCovering.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Enums/RelativeSize.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Unions/ClassroomPet.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/InputObjects/PetAdoptionInput.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/InputObjects/PetSearchFilters.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/InputObjects/MeasurementsInput.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/Objects/Height.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Objects/Query.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Objects/Cat.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Objects/Human.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Objects/Bird.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Objects/Rat.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Objects/PetRock.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Objects/Fish.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Objects/Crocodile.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Objects/Mutation.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativePath/Sources/Objects/Dog.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Sources/CustomScalars/CustomDate.swift").path,

      directoryURL.appendingPathComponent("RelativeOperations/Queries/AllAnimalsQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/Queries/DogQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/Queries/AllAnimalsIncludeSkipQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/Queries/ClassroomPetsQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/Queries/PetSearchQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/Queries/PetSearchQuery.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/Mutations/PetAdoptionMutation.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativeOperations/Fragments/PetDetails.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/Fragments/DogFragment.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/Fragments/ClassroomPetDetails.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/Fragments/HeightInMeters.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/Fragments/WarmBloodedDetails.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativeOperations/LocalCacheMutations/AllAnimalsLocalCacheMutation.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/LocalCacheMutations/PetDetailsMutation.graphql.swift").path,
      directoryURL.appendingPathComponent("RelativeOperations/LocalCacheMutations/PetSearchLocalCacheMutation.graphql.swift").path,

      directoryURL.appendingPathComponent("RelativePath/Package.swift").path,
    ]

    // when
    let compilationResult = try ApolloCodegen.compileGraphQLResult(config)

    let ir = IR(compilationResult: compilationResult)

    try ApolloCodegen.generateFiles(
      compilationResult: compilationResult,
      ir: ir,
      config: config,
      fileManager: fileManager
    )

    // then
    expect(filePaths).to(equal(expectedPaths))
    expect(fileManager.allClosuresCalled).to(beTrue())
  }

  // MARK: Old File Deletion Tests

  func test__fileDeletion__givenPruneGeneratedFiles_false__doesNotDeleteUnusedGeneratedFiles() throws {
    // given
    try createFile(containing: schemaData, named: "schema.graphqls")

    try createOperationFile(
      type: .query,
      named: "TestQuery",
      filename: "TestQuery.graphql"
    )

    let testFile = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: "SchemaModule"
    )
    let testInSourcesFile = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "SchemaModule/Sources"
    )
    let testInOtherFolderFile = try createFile(
      filename: "TestGeneratedC.graphql.swift",
      inDirectory: "SchemaModule/OtherFolder"
    )

    // when
    let config = ApolloCodegenConfiguration.mock(
      input: .init(
        schemaSearchPaths: ["schema*.graphqls"],
        operationSearchPaths: ["*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: "SchemaModule",
                           moduleType: .swiftPackageManager),
        operations: .inSchemaModule
      ),
      options: .init(pruneGeneratedFiles: false)
    )

    try ApolloCodegen.build(with: config, rootURL: directoryURL)

    // then
    expect(ApolloFileManager.default.doesFileExist(atPath: testFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInSourcesFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInOtherFolderFile)).to(beTrue())
  }

  func test__fileDeletion__givenGeneratedFilesExist_InSchemaModuleDirectory_deletesOnlyGeneratedFiles() throws {
    // given
    try createFile(containing: schemaData, named: "schema.graphqls")

    try createOperationFile(
      type: .query,
      named: "TestQuery",
      filename: "TestQuery.graphql"
    )

    let testFile = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: "SchemaModule"
    )
    let testInSourcesFile = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "SchemaModule/Sources"
    )
    let testInOtherFolderFile = try createFile(
      filename: "TestGeneratedC.graphql.swift",
      inDirectory: "SchemaModule/OtherFolder"
    )

    let testUserFile = try createFile(
      filename: "TestUserFileA.swift",
      inDirectory: "SchemaModule"
    )
    let testInSourcesUserFile = try createFile(
      filename: "TestUserFileB.swift",
      inDirectory: "SchemaModule/Sources"
    )
    let testInOtherFolderUserFile = try createFile(
      filename: "TestUserFileC.swift",
      inDirectory: "SchemaModule/OtherFolder"
    )

    // when
    let config = ApolloCodegenConfiguration.mock(
      input: .init(
        schemaSearchPaths: ["schema*.graphqls"],
        operationSearchPaths: ["*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: "SchemaModule",
                           moduleType: .swiftPackageManager),
        operations: .inSchemaModule
      )
    )

    try ApolloCodegen.build(with: config, rootURL: directoryURL)

    // then
    expect(ApolloFileManager.default.doesFileExist(atPath: testFile)).to(beFalse())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInSourcesFile)).to(beFalse())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInOtherFolderFile)).to(beFalse())

    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInSourcesUserFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInOtherFolderUserFile)).to(beTrue())
  }

  func test__fileDeletion__givenGeneratedFilesExist_InOperationAbsoluteDirectory_deletesOnlyGeneratedFiles() throws {
    // given
    let absolutePath = "OperationPath"
    try createFile(containing: schemaData, named: "schema.graphqls")

    try createOperationFile(
      type: .query,
      named: "TestQuery",
      filename: "TestQuery.graphql"
    )

    let testFile = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: absolutePath
    )
    let testInChildFile = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "\(absolutePath)/Child"
    )

    let testUserFile = try createFile(
      filename: "TestFileA.swift",
      inDirectory: absolutePath
    )
    let testInChildUserFile = try createFile(
      filename: "TestFileB.swift",
      inDirectory: "\(absolutePath)/Child"
    )

    // when
    let config = ApolloCodegenConfiguration.mock(
      input: .init(
        schemaSearchPaths: ["schema*.graphqls"],
        operationSearchPaths: ["*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: "SchemaModule",
                           moduleType: .swiftPackageManager),
        operations: .absolute(path: "OperationPath")
      )
    )

    try ApolloCodegen.build(with: config, rootURL: directoryURL)

    // then
    expect(ApolloFileManager.default.doesFileExist(atPath: testFile)).to(beFalse())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInChildFile)).to(beFalse())

    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInChildUserFile)).to(beTrue())
  }

  func test__fileDeletion__givenGeneratedFilesExist_InOperationRelativeDirectories_deletesOnlyRelativeGeneratedFilesInOperationSearchPaths() throws {
    // given
    try createFile(containing: schemaData, named: "schema.graphqls")

    try createOperationFile(
      type: .query,
      named: "TestQuery",
      filename: "TestQuery.graphql",
      inDirectory: "code"
    )

    let testGeneratedFileInRootPath = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: "code"
    )
    let testGeneratedFileInChildPath = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "code/child"
    )
    let testGeneratedFileInNestedChildPath = try createFile(
      filename: "TestGeneratedC.graphql.swift",
      inDirectory: "code/one/two"
    )

    let testGeneratedFileNotInRelativePath = try createFile(
      filename: "TestGeneratedD.graphql.swift",
      inDirectory: nil
    )
    let testGeneratedFileNotInRelativeChildPath = try createFile(
      filename: "TestGeneratedE.graphql.swift",
      inDirectory: "other/child"
    )

    let testUserFileInRootPath = try createFile(
      filename: "TestUserFileA.swift",
      inDirectory: "code"
    )
    let testUserFileInChildPath = try createFile(
      filename: "TestUserFileB.swift",
      inDirectory: "code/child"
    )
    let testUserFileInNestedChildPath = try createFile(
      filename: "TestUserFileC.swift",
      inDirectory: "code/one/two"
    )

    // when
    let config = ApolloCodegenConfiguration.mock(
      input: .init(
        schemaSearchPaths: ["schema*.graphqls"],
        operationSearchPaths: ["code/**/*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: "SchemaModule",
                           moduleType: .swiftPackageManager),
        operations: .relative(subpath: nil)
      )
    )

    try ApolloCodegen.build(with: config, rootURL: directoryURL)

    // then
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInRootPath)).to(beFalse())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInChildPath)).to(beFalse())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInNestedChildPath)).to(beFalse())

    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativePath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativeChildPath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInRootPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInChildPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInNestedChildPath)).to(beTrue())
  }

  func test__fileDeletion__givenGeneratedFilesExist_InOperationRelativeDirectories_operationSearchPathWithoutDirectories_deletesOnlyRelativeGeneratedFilesInOperationSearchPaths() throws {
    // given
    try createFile(containing: schemaData, named: "schema.graphqls")

    try createOperationFile(
      type: .query,
      named: "TestQuery",
      filename: "code.graphql"
    )

    let testGeneratedFileInRootPath = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: "code"
    )
    let testGeneratedFileInChildPath = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "code/child"
    )
    let testGeneratedFileInNestedChildPath = try createFile(
      filename: "TestGeneratedC.graphql.swift",
      inDirectory: "code/one/two"
    )

    let testGeneratedFileNotInRelativePath = try createFile(
      filename: "TestGeneratedD.graphql.swift",
      inDirectory: nil
    )
    let testGeneratedFileNotInRelativeChildPath = try createFile(
      filename: "TestGeneratedE.graphql.swift",
      inDirectory: "other/child"
    )

    let testUserFileInRootPath = try createFile(
      filename: "TestUserFileA.swift",
      inDirectory: "code"
    )
    let testUserFileInChildPath = try createFile(
      filename: "TestUserFileB.swift",
      inDirectory: "code/child"
    )
    let testUserFileInNestedChildPath = try createFile(
      filename: "TestUserFileC.swift",
      inDirectory: "code/one/two"
    )

    // when
    let config = ApolloCodegenConfiguration.mock(
      input: .init(
        schemaSearchPaths: ["schema*.graphqls"],
        operationSearchPaths: ["code.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: "SchemaModule",
                           moduleType: .swiftPackageManager),
        operations: .relative(subpath: nil)
      )
    )

    try ApolloCodegen.build(with: config, rootURL: directoryURL)

    // then
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInRootPath)).to(beFalse())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInChildPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInNestedChildPath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativePath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativeChildPath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInRootPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInChildPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInNestedChildPath)).to(beTrue())
  }

  func test__fileDeletion__givenGeneratedFilesExist_InOperationRelativeDirectoriesWithSubPath_deletesOnlyRelativeGeneratedFilesInOperationSearchPaths() throws {
    // given
    try createFile(containing: schemaData, named: "schema.graphqls")

    let testGeneratedFileInRootPath = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: "code"
    )
    let testGeneratedFileInChildPath = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "code/child"
    )
    let testGeneratedFileInNestedChildPath = try createFile(
      filename: "TestGeneratedC.graphql.swift",
      inDirectory: "code/one/two"
    )

    let testGeneratedFileNotInRelativePath = try createFile(
      filename: "TestGeneratedD.graphql.swift",
      inDirectory: nil
    )
    let testGeneratedFileNotInRelativeChildPath = try createFile(
      filename: "TestGeneratedE.graphql.swift",
      inDirectory: "other/child"
    )

    let testGeneratedFileInRootPathSubpath = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: "code/subpath"
    )
    let testGeneratedFileInChildPathSubpath = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "code/child/subpath"
    )
    let testGeneratedFileInNestedChildPathSubpath = try createFile(
      filename: "TestGeneratedC.graphql.swift",
      inDirectory: "code/one/two/subpath"
    )

    let testGeneratedFileNotInRelativePathSubpath = try createFile(
      filename: "TestGeneratedD.graphql.swift",
      inDirectory: "subpath"
    )
    let testGeneratedFileNotInRelativeChildPathSubpath = try createFile(
      filename: "TestGeneratedE.graphql.swift",
      inDirectory: "other/child/subpath"
    )

    let testUserFileInRootPath = try createOperationFile(
      type: .query,
      named: "OperationA",
      filename: "TestUserFileOperationA.graphql",
      inDirectory: "code"
    )
    let testUserFileInChildPath = try createOperationFile(
      type: .query,
      named: "OperationB",
      filename: "TestUserFileOperationB.graphql",
      inDirectory: "code/child"
    )
    let testUserFileInNestedChildPath = try createOperationFile(
      type: .query,
      named: "OperationC",
      filename: "TestUserFileOperationC.graphql",
      inDirectory: "code/one/two"
    )

    // when
    let config = ApolloCodegenConfiguration.mock(
      input: .init(
        schemaSearchPaths: ["schema*.graphqls"],
        operationSearchPaths: ["code/**/*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: "SchemaModule",
                           moduleType: .swiftPackageManager),
        operations: .relative(subpath: "subpath")
      )
    )

    try ApolloCodegen.build(with: config, rootURL: directoryURL)

    // then
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInRootPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInChildPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInNestedChildPath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativePath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativeChildPath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInRootPathSubpath)).to(beFalse())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInChildPathSubpath)).to(beFalse())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInNestedChildPathSubpath)).to(beFalse())

    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativePathSubpath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativeChildPathSubpath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInRootPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInChildPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInNestedChildPath)).to(beTrue())
  }

  func test__fileDeletion__givenGeneratedFilesExist_InOperationRelativeDirectoriesWithSubPath_operationSearchPathWithNoDirectories_deletesOnlyRelativeGeneratedFilesInOperationSearchPaths() throws {
    // given
    try createFile(containing: schemaData, named: "schema.graphqls")

    try createOperationFile(
      type: .query,
      named: "TestQuery",
      filename: "code.graphql"
    )

    let testGeneratedFileInRootPath = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: "code"
    )
    let testGeneratedFileInChildPath = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "code/child"
    )
    let testGeneratedFileInNestedChildPath = try createFile(
      filename: "TestGeneratedC.graphql.swift",
      inDirectory: "code/one/two"
    )

    let testGeneratedFileNotInRelativePath = try createFile(
      filename: "TestGeneratedD.graphql.swift",
      inDirectory: nil
    )
    let testGeneratedFileNotInRelativeChildPath = try createFile(
      filename: "TestGeneratedE.graphql.swift",
      inDirectory: "other/child"
    )

    let testGeneratedFileInRootPathSubpath = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: "code/subpath"
    )
    let testGeneratedFileInChildPathSubpath = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "code/child/subpath"
    )
    let testGeneratedFileInNestedChildPathSubpath = try createFile(
      filename: "TestGeneratedC.graphql.swift",
      inDirectory: "code/one/two/subpath"
    )

    let testGeneratedFileNotInRelativePathSubpath = try createFile(
      filename: "TestGeneratedD.graphql.swift",
      inDirectory: "subpath"
    )
    let testGeneratedFileNotInRelativeChildPathSubpath = try createFile(
      filename: "TestGeneratedE.graphql.swift",
      inDirectory: "other/child/subpath"
    )

    let testUserFileInRootPath = try createOperationFile(
      type: .query,
      named: "OperationA",
      filename: "TestUserFileOperationA.graphql",
      inDirectory: "code"
    )
    let testUserFileInChildPath = try createOperationFile(
      type: .query,
      named: "OperationB",
      filename: "TestUserFileOperationB.graphql",
      inDirectory: "code/child"
    )
    let testUserFileInNestedChildPath = try createOperationFile(
      type: .query,
      named: "OperationC",
      filename: "TestUserFileOperationC.graphql",
      inDirectory: "code/one/two"
    )

    // when
    let config = ApolloCodegenConfiguration.mock(
      input: .init(
        schemaSearchPaths: ["schema*.graphqls"],
        operationSearchPaths: ["code.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: "SchemaModule",
                           moduleType: .swiftPackageManager),
        operations: .relative(subpath: "subpath")
      )
    )

    try ApolloCodegen.build(with: config, rootURL: directoryURL)

    // then
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInRootPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInChildPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInNestedChildPath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativePath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativeChildPath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInRootPathSubpath)).to(beFalse())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInChildPathSubpath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInNestedChildPathSubpath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativePathSubpath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativeChildPathSubpath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInRootPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInChildPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInNestedChildPath)).to(beTrue())
  }

  func test__fileDeletion__givenGeneratedFilesExist_InOperationRelativeDirectoriesWithSubPath_operationSearchPathWithoutGlobstar_deletesOnlyRelativeGeneratedFilesInOperationSearchPaths() throws {
    // given
    try createFile(containing: schemaData, named: "schema.graphqls")

    let testGeneratedFileInRootPath = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: "code"
    )
    let testGeneratedFileInChildPath = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "code/child"
    )
    let testGeneratedFileInNestedChildPath = try createFile(
      filename: "TestGeneratedC.graphql.swift",
      inDirectory: "code/child/A"
    )

    let testGeneratedFileNotInRelativePath = try createFile(
      filename: "TestGeneratedD.graphql.swift",
      inDirectory: nil
    )
    let testGeneratedFileNotInRelativeChildPath = try createFile(
      filename: "TestGeneratedE.graphql.swift",
      inDirectory: "other/child"
    )

    let testGeneratedFileInRootPathSubpath = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: "code/subpath"
    )
    let testGeneratedFileInChildPathSubpath = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "code/child/subpath"
    )
    let testGeneratedFileInNestedChildPathSubpath = try createFile(
      filename: "TestGeneratedC.graphql.swift",
      inDirectory: "code/child/next/subpath"
    )

    let testGeneratedFileNotInRelativePathSubpath = try createFile(
      filename: "TestGeneratedD.graphql.swift",
      inDirectory: "subpath"
    )
    let testGeneratedFileNotInRelativeChildPathSubpath = try createFile(
      filename: "TestGeneratedE.graphql.swift",
      inDirectory: "other/child/subpath"
    )

    let testUserFileInRootPath = try createOperationFile(
      type: .query,
      named: "OperationA",
      filename: "TestUserFileOperationA.graphql",
      inDirectory: "code"
    )
    let testUserFileInChildPath = try createOperationFile(
      type: .query,
      named: "OperationB",
      filename: "TestUserFileOperationB.graphql",
      inDirectory: "code/child"
    )
    let testUserFileInNestedChildPath = try createOperationFile(
      type: .query,
      named: "OperationC",
      filename: "TestUserFileOperationC.graphql",
      inDirectory: "code/child/next"
    )

    // when
    let config = ApolloCodegenConfiguration.mock(
      input: .init(
        schemaSearchPaths: ["schema*.graphqls"],
        operationSearchPaths: ["code/child/*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: "SchemaModule",
                           moduleType: .swiftPackageManager),
        operations: .relative(subpath: "subpath")
      )
    )

    try ApolloCodegen.build(with: config, rootURL: directoryURL)

    // then
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInRootPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInChildPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInNestedChildPath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativePath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativeChildPath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInRootPathSubpath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInChildPathSubpath)).to(beFalse())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileInNestedChildPathSubpath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativePathSubpath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testGeneratedFileNotInRelativeChildPathSubpath)).to(beTrue())

    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInRootPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInChildPath)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFileInNestedChildPath)).to(beTrue())
  }

  func test__fileDeletion__givenGeneratedTestMockFilesExist_InAbsoluteDirectory_deletesOnlyGeneratedFiles() throws {
    // given
    let absolutePath = "TestMocksPath"
    try createFile(containing: schemaData, named: "schema.graphqls")

    try createOperationFile(
      type: .query,
      named: "TestQuery",
      filename: "TestQuery.graphql"
    )

    let testFile = try createFile(
      filename: "TestGeneratedA.graphql.swift",
      inDirectory: absolutePath
    )
    let testInChildFile = try createFile(
      filename: "TestGeneratedB.graphql.swift",
      inDirectory: "\(absolutePath)/Child"
    )

    let testUserFile = try createFile(
      filename: "TestFileA.swift",
      inDirectory: absolutePath
    )
    let testInChildUserFile = try createFile(
      filename: "TestFileB.swift",
      inDirectory: "\(absolutePath)/Child"
    )

    // when
    let config = ApolloCodegenConfiguration.mock(
      input: .init(
        schemaSearchPaths: ["schema*.graphqls"],
        operationSearchPaths: ["*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: "SchemaModule",
                           moduleType: .swiftPackageManager),
        operations: .inSchemaModule,
        testMocks: .absolute(path: absolutePath)
      )
    )

    try ApolloCodegen.build(with: config, rootURL: directoryURL)

    // then
    expect(ApolloFileManager.default.doesFileExist(atPath: testFile)).to(beFalse())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInChildFile)).to(beFalse())

    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInChildUserFile)).to(beTrue())
  }

  func test__fileDeletion__givenGeneratedTestMockFilesExist_InSwiftPackageDirectory_deletesOnlyGeneratedFiles() throws {
    // given
    try createFile(containing: schemaData, named: "schema.graphqls")

    try createOperationFile(
      type: .query,
      named: "TestQuery",
      filename: "TestQuery.graphql"
    )

    let testInTestMocksFolderFile = try createFile(
      filename: "TestGeneratedD.graphql.swift",
      inDirectory: "SchemaModule/TestMocks"
    )

    let testUserFile = try createFile(
      filename: "TestUserFileA.swift",
      inDirectory: "SchemaModule"
    )
    let testInSourcesUserFile = try createFile(
      filename: "TestUserFileB.swift",
      inDirectory: "SchemaModule/Sources"
    )
    let testInOtherFolderUserFile = try createFile(
      filename: "TestUserFileC.swift",
      inDirectory: "SchemaModule/OtherFolder"
    )
    let testInTestMocksFolderUserFile = try createFile(
      filename: "TestUserFileD.swift",
      inDirectory: "SchemaModule/TestMocks"
    )

    // when
    let config = ApolloCodegenConfiguration.mock(
      schemaName: "TestSchema",
      input: .init(
        schemaSearchPaths: ["schema*.graphqls"],
        operationSearchPaths: ["*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: "SchemaModule",
                           moduleType: .swiftPackageManager),
        testMocks: .swiftPackage()
      )
    )

    try ApolloCodegen.build(with: config, rootURL: directoryURL)

    // then
    expect(ApolloFileManager.default.doesFileExist(atPath: testInTestMocksFolderFile)).to(beFalse())

    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInSourcesUserFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInOtherFolderUserFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInTestMocksFolderUserFile)).to(beTrue())
  }

  func test__fileDeletion__givenGeneratedTestMockFilesExist_InSwiftPackageWithCustomTargetNameDirectory_deletesOnlyGeneratedFiles() throws {
    // given
    let testMockTargetName = "ApolloTestTarget"
    try createFile(containing: schemaData, named: "schema.graphqls")

    try createOperationFile(
      type: .query,
      named: "TestQuery",
      filename: "TestQuery.graphql"
    )

    let testInTestMocksFolderFile = try createFile(
      filename: "TestGeneratedD.graphql.swift",
      inDirectory: "SchemaModule/\(testMockTargetName)"
    )

    let testUserFile = try createFile(
      filename: "TestUserFileA.swift",
      inDirectory: "SchemaModule"
    )
    let testInSourcesUserFile = try createFile(
      filename: "TestUserFileB.swift",
      inDirectory: "SchemaModule/Sources"
    )
    let testInOtherFolderUserFile = try createFile(
      filename: "TestUserFileC.swift",
      inDirectory: "SchemaModule/OtherFolder"
    )
    let testInTestMocksFolderUserFile = try createFile(
      filename: "TestUserFileD.swift",
      inDirectory: "SchemaModule/\(testMockTargetName)"
    )

    // when
    let config = ApolloCodegenConfiguration.mock(
      schemaName: "TestSchema",
      input: .init(
        schemaSearchPaths: ["schema*.graphqls"],
        operationSearchPaths: ["*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(path: "SchemaModule",
                           moduleType: .swiftPackageManager),
        testMocks: .swiftPackage(targetName: testMockTargetName)
      )
    )

    try ApolloCodegen.build(with: config, rootURL: directoryURL)

    // then
    expect(ApolloFileManager.default.doesFileExist(atPath: testInTestMocksFolderFile)).to(beFalse())

    expect(ApolloFileManager.default.doesFileExist(atPath: testUserFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInSourcesUserFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInOtherFolderUserFile)).to(beTrue())
    expect(ApolloFileManager.default.doesFileExist(atPath: testInTestMocksFolderUserFile)).to(beTrue())
  }

  // MARK: Validation Tests

  func test_validation_givenTestMockConfiguration_asSwiftPackage_withSchemaTypesModule_asEmbeddedInTarget_shouldThrow() throws {
    // given
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      input: .init(schemaPath: "path"),
      output: .mock(
        moduleType: .embeddedInTarget(name: "ModuleTarget"),
        testMocks: .swiftPackage(targetName: nil)
      )
    ), rootURL: nil)

    // then
    expect(try ApolloCodegen.validate(config: configContext))
      .to(throwError(ApolloCodegen.Error.testMocksInvalidSwiftPackageConfiguration))
  }

  func test_validation_givenTestMockConfiguration_asSwiftPackage_withSchemaTypesModule_asOther_shouldThrow() throws {
    // given
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      input: .init(schemaPath: "path"),
      output: .mock(
        moduleType: .other,
        testMocks: .swiftPackage(targetName: nil)
      )
    ), rootURL: nil)

    // then
    expect(try ApolloCodegen.validate(config: configContext))
      .to(throwError(ApolloCodegen.Error.testMocksInvalidSwiftPackageConfiguration))
  }

  func test_validation_givenTestMockConfiguration_asSwiftPackage_withSchemaTypesModule_asSwiftPackage_shouldNotThrow() throws {
    // given
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      input: .init(schemaPath: "path.graphqls")
    ), rootURL: nil)

    // then
    expect(try ApolloCodegen.validate(config: configContext))
      .notTo(throwError())
  }

  func test_validation_givenOperationSearchPathWithoutFileExtensionComponent_shouldThrow() throws {
    // given
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      input: .init(schemaPath: "path.graphqls", operationSearchPaths: ["operations/*"])
    ), rootURL: nil)

    // then
    expect(try ApolloCodegen.validate(config: configContext))
      .to(throwError(ApolloCodegen.Error.inputSearchPathInvalid(path: "operations/*")))
  }

  func test_validation_givenOperationSearchPathEndingInPeriod_shouldThrow() throws {
    // given
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      input: .init(schemaPath: "path.graphqls", operationSearchPaths: ["operations/*."])
    ), rootURL: nil)

    // then
    expect(try ApolloCodegen.validate(config: configContext))
      .to(throwError(ApolloCodegen.Error.inputSearchPathInvalid(path: "operations/*.")))
  }

  func test_validation_givenSchemaSearchPathWithoutFileExtensionComponent_shouldThrow() throws {
    // given
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      input: .init(schemaSearchPaths: ["schema/*"])
    ), rootURL: nil)

    // then
    expect(try ApolloCodegen.validate(config: configContext))
      .to(throwError(ApolloCodegen.Error.inputSearchPathInvalid(path: "schema/*")))
  }

  func test_validation_givenSchemaSearchPathEndingInPeriod_shouldThrow() throws {
    // given
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      input: .init(schemaSearchPaths: ["schema/*."])
    ), rootURL: nil)

    // then
    expect(try ApolloCodegen.validate(config: configContext))
      .to(throwError(ApolloCodegen.Error.inputSearchPathInvalid(path: "schema/*.")))
  }

  let conflictingSchemaNames = ["rocket", "Rocket"]

  func test__validation__givenSchemaName_matchingObjectName_shouldThrow() throws {
    // given
    let object = GraphQLObjectType.mock("Rocket")
    let compilationResult = CompilationResult.mock()

    compilationResult.referencedTypes.append(object)

    // then
    for name in conflictingSchemaNames {
      let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
        schemaName: name
      ), rootURL: nil)

      expect(try ApolloCodegen.validate(
        schemaName: configContext.schemaName,
        compilationResult: compilationResult))
      .to(throwError(ApolloCodegen.Error.schemaNameConflict(name: configContext.schemaName)))
    }
  }

  func test__validation__givenSchemaName_matchingInterfaceName_shouldThrow() throws {
    // given
    let interface = GraphQLInterfaceType.mock("Rocket")
    let compilationResult = CompilationResult.mock()

    compilationResult.referencedTypes.append(interface)

    // then
    for name in conflictingSchemaNames {
      let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
        schemaName: name
      ), rootURL: nil)

      expect(try ApolloCodegen.validate(
        schemaName: configContext.schemaName,
        compilationResult: compilationResult))
      .to(throwError(ApolloCodegen.Error.schemaNameConflict(name: configContext.schemaName)))
    }
  }

  func test__validation__givenSchemaName_matchingUnionName_shouldThrow() throws {
    // given
    let union = GraphQLUnionType.mock("Rocket")
    let compilationResult = CompilationResult.mock()

    compilationResult.referencedTypes.append(union)

    // then
    for name in conflictingSchemaNames {
      let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
        schemaName: name
      ), rootURL: nil)

      expect(try ApolloCodegen.validate(
        schemaName: configContext.schemaName,
        compilationResult: compilationResult))
      .to(throwError(ApolloCodegen.Error.schemaNameConflict(name: configContext.schemaName)))
    }
  }

  func test__validation__givenSchemaName_matchingEnumName_shouldThrow() throws {
    // given
    let `enum` = GraphQLEnumType.mock(name: "Rocket", values: ["one", "two"])
    let compilationResult = CompilationResult.mock()

    compilationResult.referencedTypes.append(`enum`)

    // then
    for name in conflictingSchemaNames {
      let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
        schemaName: name
      ), rootURL: nil)

      expect(try ApolloCodegen.validate(
        schemaName: configContext.schemaName,
        compilationResult: compilationResult))
      .to(throwError(ApolloCodegen.Error.schemaNameConflict(name: configContext.schemaName)))
    }
  }

  func test__validation__givenSchemaName_matchingInputObjectName_shouldThrow() throws {
    // given
    let inputObject = GraphQLInputObjectType.mock("Rocket")
    let compilationResult = CompilationResult.mock()

    compilationResult.referencedTypes.append(inputObject)

    // then
    for name in conflictingSchemaNames {
      let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
        schemaName: name
      ), rootURL: nil)

      expect(try ApolloCodegen.validate(
        schemaName: configContext.schemaName,
        compilationResult: compilationResult))
      .to(throwError(ApolloCodegen.Error.schemaNameConflict(name: configContext.schemaName)))
    }
  }

  func test__validation__givenSchemaName_matchingCustomScalarName_shouldThrow() throws {
    // given
    let customScalar = GraphQLScalarType.mock(name: "Rocket")
    let compilationResult = CompilationResult.mock()

    compilationResult.referencedTypes.append(customScalar)

    // then
    for name in conflictingSchemaNames {
      let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
        schemaName: name
      ), rootURL: nil)

      expect(try ApolloCodegen.validate(
        schemaName: configContext.schemaName,
        compilationResult: compilationResult))
      .to(throwError(ApolloCodegen.Error.schemaNameConflict(name: configContext.schemaName)))
    }
  }

  func test__validation__givenSchemaName_matchingFragmentDefinitionName_shouldThrow() throws {
    // given
    let fragmentDefinition = CompilationResult.FragmentDefinition.mock(
      "Rocket",
      type: .mock("MockType"))
    let compilationResult = CompilationResult.mock()

    compilationResult.fragments.append(fragmentDefinition)

    // then
    for name in conflictingSchemaNames {
      let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
        schemaName: name
      ), rootURL: nil)

      expect(try ApolloCodegen.validate(
        schemaName: configContext.schemaName,
        compilationResult: compilationResult))
      .to(throwError(ApolloCodegen.Error.schemaNameConflict(name: configContext.schemaName)))
    }
  }

  func test__validation__givenSchemaName_matchingDisallowedSchemaNamespaceName_shouldThrow() throws {
    // given
    let disallowedNames = ["schema", "Schema", "ApolloAPI", "apolloapi"]

    // when
    for name in disallowedNames {
      let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
        schemaName: name
      ), rootURL: nil)

      // then
      expect(try ApolloCodegen.validate(config: configContext))
        .to(throwError(ApolloCodegen.Error.schemaNameConflict(name: configContext.schemaName)))
    }
  }

  func test__validation__givenUniqueSchemaName_shouldNotThrow() throws {
    // given
    let object = GraphQLObjectType.mock("MockObject")
    let interface = GraphQLInterfaceType.mock("MockInterface")
    let union = GraphQLUnionType.mock("MockUnion")
    let `enum` = GraphQLEnumType.mock(name: "MockEnum", values: ["one", "two"])
    let inputObject = GraphQLInputObjectType.mock("MockInputObject")
    let customScalar = GraphQLScalarType.mock(name: "MockCustomScalar")
    let fragmentDefinition = CompilationResult.FragmentDefinition.mock(
      "MockFragmentDefinition",
      type: .mock("MockType"))
    let compilationResult = CompilationResult.mock()

    compilationResult.referencedTypes.append(contentsOf: [
      object,
      interface,
      union,
      `enum`,
      inputObject,
      customScalar
    ])
    compilationResult.fragments.append(fragmentDefinition)

    // then
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      schemaName: "MySchema"
    ), rootURL: nil)

    expect(try ApolloCodegen.validate(
      schemaName: configContext.schemaName,
      compilationResult: compilationResult))
    .notTo(throwError())
  }

  func test__validation__givenSchemaTypesModule_swiftPackageManager_withCocoapodsCompatibleImportStatements_true_shouldThrow() throws {
    // given
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      .swiftPackageManager,
      options: .init(cocoapodsCompatibleImportStatements: true)
    ))

    // then
    expect(try ApolloCodegen.validate(config: configContext))
      .to(throwError(ApolloCodegen.Error.invalidConfiguration(message: """
        cocoapodsCompatibleImportStatements cannot be set to 'true' when the output schema types \
        module type is Swift Package Manager. Change the cocoapodsCompatibleImportStatements \
        value to 'false' to resolve the conflict.
        """)))
  }

  func test__validation__givenSchemaTypesModule_swiftPackageManager_withCocoapodsCompatibleImportStatements_false_shouldNotThrow() throws {
    // given
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      .swiftPackageManager,
      options: .init(cocoapodsCompatibleImportStatements: false)
    ))

    // then
    expect(try ApolloCodegen.validate(config: configContext)).notTo(throwError())
  }

  func test__validation__givenSchemaTypesModule_embeddedInTarget_withCocoapodsCompatibleImportStatements_true_shouldNotThrow() throws {
    // given
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      .embeddedInTarget(name: "TestTarget"),
      options: .init(cocoapodsCompatibleImportStatements: true)
    ))

    // then
    expect(try ApolloCodegen.validate(config: configContext)).notTo(throwError())
  }

  func test__validation__givenSchemaTypesModule_other_withCocoapodsCompatibleImportStatements_true_shouldNotThrow() throws {
    // given
    let configContext = ApolloCodegen.ConfigurationContext(config: .mock(
      .other,
      options: .init(cocoapodsCompatibleImportStatements: true)
    ))

    // then
    expect(try ApolloCodegen.validate(config: configContext)).notTo(throwError())
  }

  // MARK: Path Match Exclusion Tests

  func test__match__givenFilesInSpecialExcludedPaths_shouldNotReturnExcludedPaths() throws {
    // given
    try createFile(filename: "included.file")

    try createFile(filename: "excludedBuildFolder.file", inDirectory: ".build")
    try createFile(filename: "excludedBuildSubfolderOne.file", inDirectory: ".build/subfolder")
    try createFile(filename: "excludedBuildSubfolderTwo.file", inDirectory: ".build/subfolder/two")
    try createFile(filename: "excludedNestedOneBuildFolder.file", inDirectory: "nested/.build")
    try createFile(filename: "excludedNestedTwoBuildFolder.file", inDirectory: "nested/two/.build")

    try createFile(filename: "excludedSwiftpmFolder.file", inDirectory: ".swiftpm")
    try createFile(filename: "excludedSwiftpmSubfolderOne.file", inDirectory: ".swiftpm/subfolder")
    try createFile(filename: "excludedSwiftpmSubfolderTwo.file", inDirectory: ".swiftpm/subfolder/two")
    try createFile(filename: "excludedNestedOneSwiftpmFolder.file", inDirectory: "nested/.swiftpm")
    try createFile(filename: "excludedNestedTwoSwiftpmFolder.file", inDirectory: "nested/two/.swiftpm")

    try createFile(filename: "excludedPodsFolder.file", inDirectory: ".Pods")
    try createFile(filename: "excludedPodsSubfolderOne.file", inDirectory: ".Pods/subfolder")
    try createFile(filename: "excludedPodsSubfolderTwo.file", inDirectory: ".Pods/subfolder/two")
    try createFile(filename: "excludedNestedOnePodsFolder.file", inDirectory: "nested/.Pods")
    try createFile(filename: "excludedNestedTwoPodsFolder.file", inDirectory: "nested/two/.Pods")

    // when
    let matches = try ApolloCodegen.match(
      searchPaths: ["\(directoryURL.path)/**/*.file"],
      relativeTo: nil)

    // then
    expect(matches.count).to(equal(1))
    expect(matches.contains(where: { $0.contains(".build") })).to(beFalse())
    expect(matches.contains(where: { $0.contains(".swiftpm") })).to(beFalse())
    expect(matches.contains(where: { $0.contains(".Pods") })).to(beFalse())
  }

  func test__match__givenFilesInSpecialExcludedPaths_usingRelativeDirectory_shouldNotReturnExcludedPaths() throws {
    // given
    try createFile(filename: "included.file")

    try createFile(filename: "excludedBuildFolder.file", inDirectory: ".build")
    try createFile(filename: "excludedBuildSubfolderOne.file", inDirectory: ".build/subfolder")
    try createFile(filename: "excludedBuildSubfolderTwo.file", inDirectory: ".build/subfolder/two")
    try createFile(filename: "excludedNestedOneBuildFolder.file", inDirectory: "nested/.build")
    try createFile(filename: "excludedNestedTwoBuildFolder.file", inDirectory: "nested/two/.build")

    try createFile(filename: "excludedSwiftpmFolder.file", inDirectory: ".swiftpm")
    try createFile(filename: "excludedSwiftpmSubfolderOne.file", inDirectory: ".swiftpm/subfolder")
    try createFile(filename: "excludedSwiftpmSubfolderTwo.file", inDirectory: ".swiftpm/subfolder/two")
    try createFile(filename: "excludedNestedOneSwiftpmFolder.file", inDirectory: "nested/.swiftpm")
    try createFile(filename: "excludedNestedTwoSwiftpmFolder.file", inDirectory: "nested/two/.swiftpm")

    try createFile(filename: "excludedPodsFolder.file", inDirectory: ".Pods")
    try createFile(filename: "excludedPodsSubfolderOne.file", inDirectory: ".Pods/subfolder")
    try createFile(filename: "excludedPodsSubfolderTwo.file", inDirectory: ".Pods/subfolder/two")
    try createFile(filename: "excludedNestedOnePodsFolder.file", inDirectory: "nested/.Pods")
    try createFile(filename: "excludedNestedTwoPodsFolder.file", inDirectory: "nested/two/.Pods")

    // when
    let matches = try ApolloCodegen.match(
      searchPaths: ["**/*.file"],
      relativeTo: directoryURL)

    // then
    expect(matches.count).to(equal(1))
    expect(matches.contains(where: { $0.contains(".build") })).to(beFalse())
    expect(matches.contains(where: { $0.contains(".swiftpm") })).to(beFalse())
    expect(matches.contains(where: { $0.contains(".Pods") })).to(beFalse())
  }

}

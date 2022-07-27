import XCTest
@testable import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib
import Nimble
import ApolloUtils

class ApolloCodegenTests: XCTestCase {
  private var directoryURL: URL!

  override func setUpWithError() throws {
    directoryURL = CodegenTestHelper.outputFolderURL()
      .appendingPathComponent("Codegen")
      .appendingPathComponent(UUID().uuidString)

    try ApolloFileManager.default.createDirectoryIfNeeded(atPath: directoryURL.path)
  }

  override func tearDownWithError() throws {
    try cleanTestOutput()
    directoryURL = nil
  }

  // MARK: Helpers

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
    try ApolloFileManager.default.deleteDirectory(atPath: directoryURL.path)
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
      try ApolloFileManager.default.createFile(atPath: path, data: data)
    ).notTo(throwError())

    return path
  }

  @discardableResult
  private func createFile(body: String, named filename: String) -> String {
    return createFile(containing: body.data(using: .utf8)!, named: filename)
  }

  // MARK: Configuration Tests

  func test_build_givenInvalidConfiguration_shouldThrow() throws {
    // given
    let config = ApolloCodegenConfiguration.mock(
      input: .init(schemaPath: "not_a_path", operationSearchPaths: []),
      output: .mock(operations: .inSchemaModule)
    )

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

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )))

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

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )))

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config).operations).to(haveCount(2))
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
    let schemaPath = createFile(containing: schemaData, named: "schema.graphqls")

    let authorsData: Data =
      """
      query getAuthors {
        author! {
          name!
        }
      }
      """.data(using: .utf8)!
    createFile(containing: authorsData, named: "authors-operation.graphql")

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )))

    let compiledDocument = try ApolloCodegen.compileGraphQLResult(
      config,
      experimentalFeatures: .init(clientControlledNullability: true)
    )

    // then
    expect(compiledDocument.operations).to(haveCount(1))
  }

  func test_CCN_compileResults_givenOperations_withErrors_shouldError() throws {
    // given
    let schemaPath = createFile(containing: schemaData, named: "schema.graphqls")

    let authorsData: Data =
      """
      query getAuthors {
        authors {
          name!
        }
      }
      """.data(using: .utf8)!
    createFile(containing: authorsData, named: "authors-operation.graphql")

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )))

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config).operations).to(throwError { error in
      guard let error = error as? GraphQLError else {
        fail("Expected .graphQLSourceValidationFailure because we attempted to compile a document that uses CCN without CCN enabled, got \(error)")
        return
      }
      expect(error.message).to(equal("Syntax Error: Expected Name, found \"!\"."))
    })
  }

  func test_compileResults_givenSchema_withNoOperations_shouldReturnEmpty() throws {
    // given
    let schemaPath = createFile(containing: schemaData, named: "schema.graphqls")

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )))

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config).operations).to(beEmpty())
  }

  func test__compileResults__givenMultipleSchemaFiles_withDependentTypes_compilesResult() throws {
    // given
    createFile(
      body: """
      type Query {
        books: [Book!]!
        authors: [Author!]!
      }
      """,
      named: "schema1.graphqls")

    createFile(
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
      named: "schema2.graphqls")

    createFile(
      body: """
      query getAuthors {
        authors {
          name
        }
      }
      """,
      named: "TestQuery.graphql")

    // when
    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaSearchPaths: [directoryURL.appendingPathComponent("schema*.graphqls").path],
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )))

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config).referencedTypes.count).to(equal(3))
  }

  func test__compileResults__givenMultipleSchemaFiles_withDifferentRootTypes_compilesResult() throws {
    // given
    createFile(
      body: """
      type Query {
        string: String!
      }
      """,
      named: "schema1.graphqls")

    createFile(
      body: """
      type Subscription {
        bool: Boolean!
      }
      """,
      named: "schema2.graphqls")

    createFile(
      body: """
      query TestQuery {
        string
      }
      """,
      named: "TestQuery.graphql")

    createFile(
      body: """
      subscription TestSubscription {
        bool
      }
      """,
      named: "TestSubscription.graphql")

    // when
    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaSearchPaths: [directoryURL.appendingPathComponent("schema*.graphqls").path],
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )))

    let result = try ApolloCodegen.compileGraphQLResult(config)

    // then
    expect(result.operations.count).to(equal(2))
  }

  func test__compileResults__givenMultipleSchemaFiles_withSchemaTypeExtension_compilesResultWithExtension() throws {
    // given
    createFile(
      body: """
      type Query {
        string: String!
      }
      """,
      named: "schema1.graphqls")

    createFile(
      body: """
      extend type Query {
        bool: Boolean!
      }
      """,
      named: "schemaExtension.graphqls")

    createFile(
      body: """
      query TestQuery {
        string
        bool
      }
      """,
      named: "TestQuery.graphql")

    // when
    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaSearchPaths: [directoryURL.appendingPathComponent("schema*.graphqls").path],
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )))

    let result = try ApolloCodegen.compileGraphQLResult(config)

    // then
    expect(result.operations.count).to(equal(1))
  }

  func test__compileResults__givenMultipleSchemaFilesWith_introspectionJSONSchema_withSchemaTypeExtension_compilesResultWithExtension() throws {
    // given
    let introspectionJSON = try String(
      contentsOf: ApolloCodegenInternalTestHelpers.Resources.StarWars.JSONSchema
    )
    
    createFile(body: introspectionJSON, named: "schemaJSON.json")

    createFile(
      body: """
      extend type Query {
        testExtensionField: Boolean!
      }
      """,
      named: "schemaExtension.graphqls")

    createFile(
      body: """
      query TestQuery {
        testExtensionField
      }
      """,
      named: "TestQuery.graphql")

    // when
    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaSearchPaths: [
        directoryURL.appendingPathComponent("schema*.graphqls").path,
        directoryURL.appendingPathComponent("schema*.json").path,
      ],
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )))

    let result = try ApolloCodegen.compileGraphQLResult(config)

    // then
    expect(result.operations.count).to(equal(1))
  }

  func test__compileResults__givenMultipleIntrospectionJSONSchemaFiles_throwsError() throws {
    // given
    let introspectionJSON = try String(
      contentsOf: ApolloCodegenInternalTestHelpers.Resources.StarWars.JSONSchema
    )

    createFile(body: introspectionJSON, named: "schemaJSON1.json")
    createFile(body: introspectionJSON, named: "schemaJSON2.json")

    // when
    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(input: .init(
      schemaSearchPaths: [
        directoryURL.appendingPathComponent("schema*.graphqls").path,
        directoryURL.appendingPathComponent("schema*.json").path,
      ],
      operationSearchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )))

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config)).to(throwError())
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
    ))

    let fileManager = MockApolloFileManager(strict: false)

    var filePaths: Set<String> = []
    fileManager.mock(closure: .createFile({ path, data, attributes in
      filePaths.insert(path)
      return true
    }))

    let expectedPaths: Set<String> = [
      directoryURL.appendingPathComponent("Sources/Schema/Schema.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Enums/SkinCovering.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/Pet.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/Animal.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/WarmBlooded.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/HousePet.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Enums/SkinCovering.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Enums/RelativeSize.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Unions/ClassroomPet.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/PetAdoptionInput.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/PetSearchFilters.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/MeasurementsInput.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Objects/Height.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Query.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Cat.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Human.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Bird.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Rat.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/PetRock.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Fish.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Crocodile.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Mutation.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Dog.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/CustomScalars/CustomDate.swift").path,
      
      directoryURL.appendingPathComponent("Sources/Operations/Queries/AllAnimalsQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/AllAnimalsIncludeSkipQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/ClassroomPetsQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/PetSearchQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/PetSearchQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Mutations/PetAdoptionMutation.swift").path,

      directoryURL.appendingPathComponent("Sources/Fragments/PetDetails.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/ClassroomPetDetails.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/HeightInMeters.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/WarmBloodedDetails.swift").path,

      directoryURL.appendingPathComponent("Sources/LocalCacheMutations/AllAnimalsLocalCacheMutation.swift").path,
      directoryURL.appendingPathComponent("Sources/LocalCacheMutations/PetDetailsMutation.swift").path,

      directoryURL.appendingPathComponent("Package.swift").path,
    ]

    // when
    let compilationResult = try ApolloCodegen.compileGraphQLResult(config)

    let ir = IR(
      schemaName: config.schemaName,
      compilationResult: compilationResult
    )

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
    ))

    let fileManager = MockApolloFileManager(strict: false)

    var filePaths: Set<String> = []
    fileManager.mock(closure: .createFile({ path, data, attributes in
      filePaths.insert(path)
      return true
    }))

    let expectedPaths: Set<String> = [
      directoryURL.appendingPathComponent("Sources/Schema.swift").path,
      directoryURL.appendingPathComponent("Sources/Enums/SkinCovering.swift").path,
      directoryURL.appendingPathComponent("Sources/Interfaces/Pet.swift").path,
      directoryURL.appendingPathComponent("Sources/Interfaces/Animal.swift").path,
      directoryURL.appendingPathComponent("Sources/Interfaces/WarmBlooded.swift").path,
      directoryURL.appendingPathComponent("Sources/Interfaces/HousePet.swift").path,
      directoryURL.appendingPathComponent("Sources/Enums/SkinCovering.swift").path,
      directoryURL.appendingPathComponent("Sources/Enums/RelativeSize.swift").path,
      directoryURL.appendingPathComponent("Sources/Unions/ClassroomPet.swift").path,
      directoryURL.appendingPathComponent("Sources/InputObjects/PetAdoptionInput.swift").path,
      directoryURL.appendingPathComponent("Sources/InputObjects/PetSearchFilters.swift").path,
      directoryURL.appendingPathComponent("Sources/InputObjects/MeasurementsInput.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Height.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Query.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Cat.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Human.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Bird.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Rat.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/PetRock.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Fish.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Crocodile.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Mutation.swift").path,
      directoryURL.appendingPathComponent("Sources/Objects/Dog.swift").path,
      directoryURL.appendingPathComponent("Sources/CustomScalars/CustomDate.swift").path,

      operationsOutputURL.appendingPathComponent("Queries/AllAnimalsQuery.swift").path,
      operationsOutputURL.appendingPathComponent("Queries/AllAnimalsIncludeSkipQuery.swift").path,
      operationsOutputURL.appendingPathComponent("Queries/ClassroomPetsQuery.swift").path,
      operationsOutputURL.appendingPathComponent("Queries/PetSearchQuery.swift").path,
      operationsOutputURL.appendingPathComponent("Queries/PetSearchQuery.swift").path,
      operationsOutputURL.appendingPathComponent("Mutations/PetAdoptionMutation.swift").path,

      operationsOutputURL.appendingPathComponent("Fragments/PetDetails.swift").path,
      operationsOutputURL.appendingPathComponent("Fragments/ClassroomPetDetails.swift").path,
      operationsOutputURL.appendingPathComponent("Fragments/HeightInMeters.swift").path,
      operationsOutputURL.appendingPathComponent("Fragments/WarmBloodedDetails.swift").path,

      operationsOutputURL.appendingPathComponent("LocalCacheMutations/AllAnimalsLocalCacheMutation.swift").path,
      operationsOutputURL.appendingPathComponent("LocalCacheMutations/PetDetailsMutation.swift").path,

      directoryURL.appendingPathComponent("Package.swift").path,
    ]

    // when
    let compilationResult = try ApolloCodegen.compileGraphQLResult(config)

    let ir = IR(
      schemaName: config.schemaName,
      compilationResult: compilationResult
    )

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
    ))

    let fileManager = MockApolloFileManager(strict: false)

    var filePaths: Set<String> = []
    fileManager.mock(closure: .createFile({ path, data, attributes in
      filePaths.insert(path)
      return true
    }))

    let expectedPaths: Set<String> = [
      directoryURL.appendingPathComponent("Sources/Schema/Schema.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/Pet.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/Animal.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/WarmBlooded.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/HousePet.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Enums/SkinCovering.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Enums/RelativeSize.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Unions/ClassroomPet.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/PetAdoptionInput.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/PetSearchFilters.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/InputObjects/MeasurementsInput.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/Objects/Height.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Query.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Cat.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Human.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Bird.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Rat.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/PetRock.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Mutation.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Dog.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Fish.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Crocodile.swift").path,

      directoryURL.appendingPathComponent("Sources/Schema/CustomScalars/CustomDate.swift").path,

      directoryURL.appendingPathComponent("Sources/Operations/Queries/AllAnimalsQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/ClassroomPetsQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/PetSearchQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/PetSearchQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/AllAnimalsIncludeSkipQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/AllAnimalsCCNQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/Queries/ClassroomPetsCCNQuery.swift").path,

      directoryURL.appendingPathComponent("Sources/Operations/Mutations/PetAdoptionMutation.swift").path,

      directoryURL.appendingPathComponent("Sources/Fragments/ClassroomPetDetailsCCN.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/PetDetails.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/ClassroomPetDetails.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/HeightInMeters.swift").path,
      directoryURL.appendingPathComponent("Sources/Fragments/WarmBloodedDetails.swift").path,

      directoryURL.appendingPathComponent("Sources/LocalCacheMutations/AllAnimalsLocalCacheMutation.swift").path,
      directoryURL.appendingPathComponent("Sources/LocalCacheMutations/PetDetailsMutation.swift").path,

      directoryURL.appendingPathComponent("Package.swift").path,
    ]

    // when
    let compilationResult = try ApolloCodegen.compileGraphQLResult(
      config,
      experimentalFeatures: .init(clientControlledNullability: true)
    )

    let ir = IR(
      schemaName: config.schemaName,
      compilationResult: compilationResult
    )

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
    ))

    let fileManager = MockApolloFileManager(strict: false)

    var filePaths: Set<String> = []
    fileManager.mock(closure: .createFile({ path, data, attributes in
      if path.contains("TestMocks/") {
        filePaths.insert(path)
      }
      return true
    }))

    let expectedPaths: Set<String> = [
      directoryURL.appendingPathComponent("TestMocks/Height+Mock.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Query+Mock.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Cat+Mock.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Human+Mock.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Bird+Mock.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Rat+Mock.swift").path,
      directoryURL.appendingPathComponent("TestMocks/PetRock+Mock.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Mutation+Mock.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Dog+Mock.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Fish+Mock.swift").path,
      directoryURL.appendingPathComponent("TestMocks/Crocodile+Mock.swift").path,
      directoryURL.appendingPathComponent("TestMocks/ClassroomPet+Mock.swift").path,
    ]

    // when
    let compilationResult = try ApolloCodegen.compileGraphQLResult(
      config,
      experimentalFeatures: .init(clientControlledNullability: true)
    )

    let ir = IR(
      schemaName: config.schemaName,
      compilationResult: compilationResult
    )

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

}

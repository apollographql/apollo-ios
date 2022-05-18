import XCTest
@testable import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib
import Nimble
import ApolloUtils

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
    let config = ApolloCodegenConfiguration.mock(
      input: .init(schemaPath: "not_a_path", searchPaths: []),
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

    let config = ReferenceWrapped(value: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      searchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
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

    let config = ReferenceWrapped(value: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      searchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
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

    let config = ReferenceWrapped(value: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      searchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
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

    let config = ReferenceWrapped(value: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      searchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
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

    let config = ReferenceWrapped(value: ApolloCodegenConfiguration.mock(input: .init(
      schemaPath: schemaPath,
      searchPaths: [directoryURL.appendingPathComponent("*.graphql").path]
    )))

    // then
    expect(try ApolloCodegen.compileGraphQLResult(config).operations).to(beEmpty())
  }

  // MARK: File Generator Tests

  func test_fileGenerators_givenSchemaAndMultipleOperationDocuments_shouldGenerateSchemaAndOperationsFiles() throws {
    // given
    let schemaPath = ApolloCodegenInternalTestHelpers.Resources.AnimalKingdomSchema.path
    let operationsPath = ApolloCodegenInternalTestHelpers.Resources.url
      .appendingPathComponent("graphql")
      .appendingPathComponent("*.graphql").path

    let config = ReferenceWrapped(value: ApolloCodegenConfiguration.mock(
      schemaName: "AnimalKingdomAPI",
      input: .init(
        schemaPath: schemaPath,
        searchPaths: [operationsPath]
      ),
      output: .mock(
        moduleType: .swiftPackageManager,
        operations: .inSchemaModule,
        path: directoryURL.path
      )
    ))

    let fileManager = MockFileManager(strict: false)

    var filePaths: Set<String> = []
    fileManager.mock(closure: .createFile({ path, data, attributes in
      filePaths.insert(path)
      return true
    }))

    let expectedPaths: Set<String> = [
      directoryURL.appendingPathComponent("Sources/Schema/Schema.swift").path,

      directoryURL.appendingPathComponent("Sources/Operations/AllAnimalsIncludeSkipQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/AllAnimalsQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Height.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/HeightInMeters.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/WarmBloodedDetails.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Enums/SkinCovering.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/Pet.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/Animal.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/WarmBlooded.swift").path,

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

      directoryURL.appendingPathComponent("Sources/Operations/AllAnimalsQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/PetDetails.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/ClassroomPetsQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/ClassroomPetDetails.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/PetSearchQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/PetAdoptionMutation.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/HeightInMeters.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/WarmBloodedDetails.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/PetSearchQuery.swift").path,

      directoryURL.appendingPathComponent("Package.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Objects/Dog.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/Interfaces/HousePet.swift").path,
      directoryURL.appendingPathComponent("Sources/Schema/CustomScalars/CustomDate.swift").path,
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
    let schemaPath = ApolloCodegenInternalTestHelpers.Resources.AnimalKingdomSchema.path
    let operationsPath = ApolloCodegenInternalTestHelpers.Resources.url
      .appendingPathComponent("graphql")
      .appendingPathComponent("**/*.graphql").path

    let config =  ReferenceWrapped(value: ApolloCodegenConfiguration(
      schemaName: "AnimalKingdomAPI",
      input: .init(schemaPath: schemaPath, searchPaths: [operationsPath]),
      output: .mock(
        moduleType: .swiftPackageManager,
        operations: .inSchemaModule,
        path: directoryURL.path
      )
    ))

    let fileManager = MockFileManager(strict: false)

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

      directoryURL.appendingPathComponent("Sources/Operations/AllAnimalsQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/PetDetails.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/ClassroomPetsQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/ClassroomPetDetails.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/PetSearchQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/PetAdoptionMutation.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/HeightInMeters.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/WarmBloodedDetails.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/PetSearchQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/AllAnimalsIncludeSkipQuery.swift").path,

      directoryURL.appendingPathComponent("Sources/Operations/AllAnimalsCCNQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/ClassroomPetsCCNQuery.swift").path,
      directoryURL.appendingPathComponent("Sources/Operations/ClassroomPetDetailsCCN.swift").path,

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
    let schemaPath = ApolloCodegenInternalTestHelpers.Resources.AnimalKingdomSchema.path
    let operationsPath = ApolloCodegenInternalTestHelpers.Resources.url
      .appendingPathComponent("graphql")
      .appendingPathComponent("**/*.graphql").path

    let config =  ReferenceWrapped(value: ApolloCodegenConfiguration(
      schemaName: "AnimalKingdomAPI",
      input: .init(schemaPath: schemaPath, searchPaths: [operationsPath]),
      output: .init(
        schemaTypes: .init(path: directoryURL.path,
                           moduleType: .swiftPackageManager),
        operations: .inSchemaModule,
        testMocks: .absolute(path: directoryURL.appendingPathComponent("TestMocks").path)
      )
    ))

    let fileManager = MockFileManager(strict: false)

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

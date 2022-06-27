import XCTest
import Nimble
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib

class CompilationTests: XCTestCase {

  var schemaSDL: String!
  var schemaJSON: String!
  var document: String!
  
  override func setUpWithError() throws {
    try super.setUpWithError()

  }

  override func tearDown() {
    schemaSDL = nil
    schemaJSON = nil
    document = nil

    super.tearDown()
  }

  // MARK: - Helpers

  func useStarWarsSchema() throws {
    schemaJSON = try String(
      contentsOf: ApolloCodegenInternalTestHelpers.Resources.StarWars.JSONSchema
    )
  }

  func compileFrontend(enableCCN: Bool = false) throws -> CompilationResult {
    let frontend = try GraphQLJSFrontend()
    if let schemaSDL = schemaSDL {
      return try frontend.compile(
        schema: schemaSDL,
        document: document,
        enableCCN: enableCCN
      )
    } else if let schemaJSON = schemaJSON {
      return try frontend.compile(
        schemaJSON: schemaJSON,
        document: document,
        enableCCN: enableCCN
      )
    } else {
      throw TestError("No Schema!")
    }
  }

  // MARK: - Tests
  
  func testCompileSingleQuery() throws {
    // given
    try useStarWarsSchema()

    document = """
      query HeroAndFriendsNames($episode: Episode) {
        hero(episode: $episode) {
          name
          friends {
            name
          }
        }
      }
      """

    let compilationResult = try compileFrontend()
    
    let operation = try XCTUnwrap(compilationResult.operations.first)
    XCTAssertEqual(operation.name, "HeroAndFriendsNames")
    XCTAssertEqual(operation.operationType, .query)
    XCTAssertEqual(operation.rootType.name, "Query")
    
    XCTAssertEqual(operation.variables[0].name, "episode")
    XCTAssertEqual(operation.variables[0].type.typeReference, "Episode")

    let heroField = try XCTUnwrap(operation.selectionSet.firstField(for: "hero"))
    XCTAssertEqual(heroField.name, "hero")
    XCTAssertEqual(heroField.type.typeReference, "Character")
    
    let episodeArgument = try XCTUnwrap(heroField.arguments?.first)
    XCTAssertEqual(episodeArgument.name, "episode")
    XCTAssertEqual(episodeArgument.value, .variable("episode"))

    let friendsField = try XCTUnwrap(heroField.selectionSet?.firstField(for: "friends"))
    XCTAssertEqual(friendsField.name, "friends")
    XCTAssertEqual(friendsField.type.typeReference, "[Character]")
    
    XCTAssertEqualUnordered(compilationResult.referencedTypes.map(\.name),
                            ["Human", "Droid", "Query", "Episode", "Character", "String"])
  }

  func testCompileSingleQueryCCN() throws {
    // given
    try useStarWarsSchema()

    document = """
      query HeroAndFriendsNames($id: ID) {
        human(id: $id) {
          name
          mass!
          appearsIn[!]?
        }
      }
      """

    let compilationResult = try compileFrontend(enableCCN: true)

    let operation = try XCTUnwrap(compilationResult.operations.first)
    XCTAssertEqual(operation.name, "HeroAndFriendsNames")
    XCTAssertEqual(operation.operationType, .query)
    XCTAssertEqual(operation.rootType.name, "Query")

    XCTAssertEqual(operation.variables[0].name, "id")
    XCTAssertEqual(operation.variables[0].type.typeReference, "ID")

    let heroField = try XCTUnwrap(operation.selectionSet.firstField(for: "human"))
    XCTAssertEqual(heroField.name, "human")
    XCTAssertEqual(heroField.type.typeReference, "Human")

    let episodeArgument = try XCTUnwrap(heroField.arguments?.first)
    XCTAssertEqual(episodeArgument.name, "id")
    XCTAssertEqual(episodeArgument.value, .variable("id"))

    let friendsField = try XCTUnwrap(heroField.selectionSet?.firstField(for: "mass"))
    XCTAssertEqual(friendsField.name, "mass")
    XCTAssertEqual(friendsField.type.typeReference, "Float!")

    let appearsInField = try XCTUnwrap(heroField.selectionSet?.firstField(for: "appearsIn"))
    XCTAssertEqual(appearsInField.name, "appearsIn")
    XCTAssertEqual(appearsInField.type.typeReference, "[Episode!]")

    XCTAssertEqualUnordered(compilationResult.referencedTypes.map(\.name),
                            ["ID", "Query", "Human", "Droid", "String", "Float", "Episode", "Character"])
  }

  func testCompile_givenOperationWithRecognizedDirective_hasDirective() throws {
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }

    directive @testDirective on QUERY
    """

    document = """
    query Test @testDirective {
      allAnimals {
        species
      }
    }
    """

    let expectedDirectives: [CompilationResult.Directive] = [
      .mock("testDirective")
    ]

    let compilationResult = try compileFrontend()


    let operation = try XCTUnwrap(compilationResult.operations.first)
    expect(operation.directives).to(equal(expectedDirectives))
  }

  /// Tests that we automatically add the local cache mutation directive to the schema
  /// during codegen.
  func testCompile_givenSchemaSDL_queryWithLocalCacheMutationDirective_notInSchema_hasDirective() throws {
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }
    """

    document = """
    query Test @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    let expectedDirectives: [CompilationResult.Directive] = [
      .mock("apollo_client_ios_localCacheMutation")
    ]

    let compilationResult = try compileFrontend()


    let operation = try XCTUnwrap(compilationResult.operations.first)
    expect(operation.directives).to(equal(expectedDirectives))
  }

  /// Tests that we automatically add the local cache mutation directive to the schema
  /// during codegen.
  func testCompile_givenSchemaJSON_queryWithLocalCacheMutationDirective_notInSchema_hasDirective() throws {
    try useStarWarsSchema()

    document = """
      query HeroAndFriendsNames($id: ID) @apollo_client_ios_localCacheMutation {
        human(id: $id) {
          name
          mass
          appearsIn
        }
      }
      """

    let expectedDirectives: [CompilationResult.Directive] = [
      .mock("apollo_client_ios_localCacheMutation")
    ]

    let compilationResult = try compileFrontend()


    let operation = try XCTUnwrap(compilationResult.operations.first)
    expect(operation.directives).to(equal(expectedDirectives))
  }
}

fileprivate extension CompilationResult.SelectionSet {
  // This is a helper method that is really only suitable for testing because getting just the first
  // occurrence of a field is of limited use when generating code.
  func firstField(for responseKey: String) -> CompilationResult.Field? {
    for selection in selections {
      guard case let .field(field) = selection else {
        continue
      }
      
      if field.responseKey == responseKey {
        return field
      }
    }
    
    return nil
  }
}

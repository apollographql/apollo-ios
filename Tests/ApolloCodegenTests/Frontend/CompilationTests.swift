import XCTest
import ApolloTestSupport
@testable import ApolloCodegenLib

class CompilationTests: XCTestCase {

  var codegenFrontend: ApolloCodegenFrontend!
  var schema: GraphQLSchema!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    codegenFrontend = try ApolloCodegenFrontend()
    
    let introspectionResult = try String(contentsOf: XCTUnwrap(starWarsAPIBundle.url(forResource: "schema", withExtension: "json")))
        
    schema = try codegenFrontend.loadSchemaFromIntrospectionResult(introspectionResult)
  }
  
  func testCompileSingleQuery() throws {
    let source = try codegenFrontend.makeSource("""
      query HeroAndFriendsNames($episode: Episode) {
        hero(episode: $episode) {
          name
          friends {
            name
          }
        }
      }
      """, filePath: "HeroAndFriendsNames.graphql")
    
    let document = try codegenFrontend.parseDocument(source)
    
    let compilationResult = try codegenFrontend.compile(schema: schema, document: document)
    
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
    
    XCTAssertEqualUnordered(compilationResult.referencedTypes.map(\.name), ["Episode", "Character", "String"])
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

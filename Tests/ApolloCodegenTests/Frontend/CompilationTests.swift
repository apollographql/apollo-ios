import XCTest
import ApolloTestSupport
@testable import ApolloCodegenLib

class CompilationTests: XCTestCase {

  var codegenFrontend: ApolloCodegenFrontend!
  var schema: GraphQLSchema!
  
  override func setUpWithError() throws {
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
    XCTAssertEqual(operation.operationName, "HeroAndFriendsNames")
    XCTAssertEqual(operation.operationType, .query)
    
    XCTAssertEqual(operation.variables[0].name, "episode")
    XCTAssertEqual(operation.variables[0].type.typeReference, "Episode")

    let heroField = try XCTUnwrap(operation.selectionSet.field(for: "hero"))
    XCTAssertEqual(heroField.name, "hero")
    XCTAssertEqual(heroField.type.typeReference, "Character")
    
    let episodeArgument = try XCTUnwrap(heroField.arguments?.first)
    XCTAssertEqual(episodeArgument.name, "episode")
    XCTAssertEqual(episodeArgument.value, .variable("episode"))

    let friendsField = try XCTUnwrap(heroField.selectionSet?.field(for: "friends"))
    XCTAssertEqual(friendsField.name, "friends")
    XCTAssertEqual(friendsField.type.typeReference, "[Character]")
  }
  
  // FIXME: This is a workaround for a really weird issue that I haven't been able to solve in any other way.
  // It seems errors thrown during `init(from decoder: Decoder)` are somehow bridged to Objective-C in a way
  // that makes Xcode fail to record them.
  // Instead, it will log: "NSInvalidUnarchiveOperationException attempting to serialize associated error of issue: This decoder will only decode classes that adopt NSSecureCoding. Class '__SwiftValue' does not adopt it."
  // What makes this weird is that throwing `DecodingError` anywhere else doesn't show this issue, so it
  // really seems to be specific to `JSONDecoder`.
  override func record(_ issue: XCTIssue) {
    if issue.associatedError != nil {
      var issue = issue
      issue.associatedError = nil
      super.record(issue)
    } else {
      super.record(issue)
    }
  }
}

fileprivate extension CompilationResult.SelectionSet {
  func field(for responseKey: String) -> CompilationResult.Field? {
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

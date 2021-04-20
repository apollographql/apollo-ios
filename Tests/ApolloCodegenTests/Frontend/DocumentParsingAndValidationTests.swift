import XCTest
import ApolloTestSupport
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib

class DocumentParsingAndValidationTests: XCTestCase {
  
  var codegenFrontend: ApolloCodegenFrontend!
  var schema: GraphQLSchema!
  
  override func setUpWithError() throws {
    try super.setUpWithError()

    codegenFrontend = try ApolloCodegenFrontend()
    
    let introspectionResult = try String(contentsOf: XCTUnwrap(starWarsAPIBundle.url(forResource: "schema", withExtension: "json")))
        
    schema = try codegenFrontend.loadSchemaFromIntrospectionResult(introspectionResult)
  }
  
  func testParseDocument() throws {
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
    
    XCTAssertEqual(document.filePath, "HeroAndFriendsNames.graphql")
  }
  
  func testParseDocumentWithSyntaxError() throws {
    let source = try codegenFrontend.makeSource("""
      query HeroAndFriendsNames($episode: Episode) {
        hero[episode: foo]
      }
      """, filePath: "HeroAndFriendsNames.graphql")
    
    XCTAssertThrowsError(try codegenFrontend.parseDocument(source)) { error in
      whileRecordingErrors {
        let error = try XCTDowncast(error as AnyObject, to: GraphQLError.self)
        XCTAssert(try XCTUnwrap(error.message).starts(with: "Syntax Error"))
        
        let sourceLocations = try XCTUnwrap(error.sourceLocations)
        XCTAssertEqual(sourceLocations.count, 1)
        
        XCTAssertEqual(sourceLocations[0].filePath, "HeroAndFriendsNames.graphql")
        XCTAssertEqual(sourceLocations[0].lineNumber, 2)
      }
    }
  }
  
  func testValidateDocument() throws {
    let source = try codegenFrontend.makeSource("""
      query HeroAndFriendsNames($episode: Episode) {
        hero(episode: $episode) {
          name
          email
          ...FriendsNames
        }
      }
      """, filePath: "HeroAndFriendsNames.graphql")
    
    let document = try codegenFrontend.parseDocument(source)
    
    let validationErrors = try codegenFrontend.validateDocument(schema: schema, document: document)
    
    XCTAssertEqual(validationErrors.map(\.message), [
      """
      Cannot query field "email" on type "Character".
      """,
      """
      Unknown fragment "FriendsNames".
      """
    ])
        
    XCTAssertEqual(document.filePath, "HeroAndFriendsNames.graphql")
  }
  
  func testParseAndValidateMultipleDocuments() throws {
    let source1 = try codegenFrontend.makeSource("""
      query HeroAndFriendsNames($episode: Episode) {
        hero(episode: $episode) {
          name
          ...FriendsNames
        }
      }
      """, filePath: "HeroAndFriendsNames.graphql")
    
    let source2 = try codegenFrontend.makeSource("""
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          name
        }
      }
      """, filePath: "HeroName.graphql")
    
    let source3 = try codegenFrontend.makeSource("""
      fragment FriendsNames on Character {
        friends {
          name
        }
      }
      """, filePath: "FriendsNames.graphql")
    
    let document1 = try codegenFrontend.parseDocument(source1)
    let document2 = try codegenFrontend.parseDocument(source2)
    let document3 = try codegenFrontend.parseDocument(source3)
    
    let document = try codegenFrontend.mergeDocuments([document1, document2, document3])
    XCTAssertEqual(document.definitions.count, 3)
    
    let validationErrors = try codegenFrontend.validateDocument(schema: schema, document: document)
    XCTAssertEqual(validationErrors, [])
  }
  
  // Errors during validation may contain multiple source locations. In the case of a field conflict
  // for example, both fields would be associated with the same error. These locations
  // may even come from different source files, so we need to test for that explicitly because
  // handling that situation required a workaround (see `GraphQLError.sourceLocations`).
  func testValidationErrorThatSpansMultipleDocuments() throws {
    let source1 = try codegenFrontend.makeSource("""
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          foo: appearsIn
          ...HeroName
        }
      }
      """, filePath: "HeroName.graphql")
    
    let source2 = try codegenFrontend.makeSource("""
      fragment HeroName on Character {
        foo: name
      }
      """, filePath: "HeroNameFragment.graphql")
    
    let document1 = try codegenFrontend.parseDocument(source1)
    let document2 = try codegenFrontend.parseDocument(source2)
    
    let document = try codegenFrontend.mergeDocuments([document1, document2])
    XCTAssertEqual(document.definitions.count, 2)
    
    let validationErrors = try codegenFrontend.validateDocument(schema: schema, document: document)
    
    XCTAssertEqual(validationErrors.count, 1)
    let validationError = validationErrors[0]
    
    XCTAssertEqual(validationError.message, """
      Fields "foo" conflict because "appearsIn" and "name" are different fields. \
      Use different aliases on the fields to fetch both if this was intentional.
      """)
    
    let sourceLocations = try XCTUnwrap(validationError.sourceLocations)
    XCTAssertEqual(sourceLocations.count, 2)
        
    XCTAssertEqual(sourceLocations[0].filePath, "HeroName.graphql")
    XCTAssertEqual(sourceLocations[0].lineNumber, 3)
    
    XCTAssertEqual(sourceLocations[1].filePath, "HeroNameFragment.graphql")
    XCTAssertEqual(sourceLocations[1].lineNumber, 2)
  }
}

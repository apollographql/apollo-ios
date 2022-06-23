import XCTest
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib

class SchemaIntrospectionTests: XCTestCase {

  var codegenFrontend: GraphQLJSFrontend!
  var schema: GraphQLSchema!
  
  override func setUpWithError() throws {
    try super.setUpWithError()

    codegenFrontend = try GraphQLJSFrontend()
    
    let introspectionResult = try String(contentsOf: XCTUnwrap(starWarsAPIBundle.url(forResource: "schema", withExtension: "json")))
    schema = try codegenFrontend.loadSchema(
      from: [try codegenFrontend.makeSource(introspectionResult, filePath: "schema.json")]
    )
  }

  override func tearDown() {
    codegenFrontend = nil
    schema = nil

    super.tearDown()
  }
  
  func testGetFieldsForObjectType() throws {
    let droidType = try XCTDowncast(XCTUnwrap(schema.getType(named: "Droid")), to: GraphQLObjectType.self)
    XCTAssertEqual(droidType.name, "Droid")
    
    let fields = droidType.fields
        
    XCTAssertEqual(fields["name"]?.name, "name")
    XCTAssertEqual(fields["name"]?.type.typeReference, "String!")
    
    XCTAssertEqual(fields["friends"]?.name, "friends")
    XCTAssertEqual(fields["friends"]?.type.typeReference, "[Character]")
  }
  
  func testGetPossibleTypesForInterface() throws {
    let characterType = try XCTDowncast(XCTUnwrap(schema.getType(named: "Character")), to: GraphQLAbstractType.self)
    XCTAssertEqual(characterType.name, "Character")
    
    try XCTAssertEqualUnordered(schema.getPossibleTypes(characterType).map(\.name), ["Human", "Droid"])
  }
  
  func testGetPossibleTypesForUnion() throws {
    let searchResultType = try XCTDowncast(XCTUnwrap(schema.getType(named: "SearchResult")), to: GraphQLAbstractType.self)
    XCTAssertEqual(searchResultType.name, "SearchResult")
    
    try XCTAssertEqualUnordered(schema.getPossibleTypes(searchResultType).map(\.name), ["Human", "Droid", "Starship"])
  }
  
  func testGetTypesForUnion() throws {
    let searchResultType = try XCTDowncast(XCTUnwrap(schema.getType(named: "SearchResult")), to: GraphQLUnionType.self)
    XCTAssertEqual(searchResultType.name, "SearchResult")
    
    XCTAssertEqualUnordered(searchResultType.types.map(\.name), ["Human", "Droid", "Starship"])
  }
  
  func testEnumType() throws {
    let episodeType = try XCTDowncast(XCTUnwrap(schema.getType(named: "Episode")), to: GraphQLEnumType.self)
    XCTAssertEqual(episodeType.name, "Episode")
    
    XCTAssertEqual(episodeType.description, "The episodes in the Star Wars trilogy")
    
    XCTAssertEqual(episodeType.values.map(\.name), ["NEWHOPE", "EMPIRE", "JEDI"])
    XCTAssertEqual(episodeType.values.map(\.description), [
      "Star Wars Episode IV: A New Hope, released in 1977.",
      "Star Wars Episode V: The Empire Strikes Back, released in 1980.",
      "Star Wars Episode VI: Return of the Jedi, released in 1983."
    ])
  }
  
  func testInputObjectType() throws {
    let episodeType = try XCTDowncast(XCTUnwrap(schema.getType(named: "ReviewInput")), to: GraphQLInputObjectType.self)
    XCTAssertEqual(episodeType.name, "ReviewInput")
    
    XCTAssertEqual(episodeType.description, "The input object sent when someone is creating a new review")
    
    XCTAssertEqual(episodeType.fields["stars"]?.type.typeReference, "Int!")
    XCTAssertEqual(episodeType.fields["stars"]?.description, "0-5 stars")
    
    XCTAssertEqual(episodeType.fields["commentary"]?.type.typeReference, "String")
    XCTAssertEqual(episodeType.fields["commentary"]?.description, "Comment about the movie, optional")
    
    XCTAssertEqual(episodeType.fields["favorite_color"]?.type.typeReference, "ColorInput")
    XCTAssertEqual(episodeType.fields["favorite_color"]?.description, "Favorite color, optional")
  }
}

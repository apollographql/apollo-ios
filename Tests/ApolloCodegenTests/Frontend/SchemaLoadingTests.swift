import XCTest
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib

class SchemaLoadingTests: XCTestCase {
  
  var codegenFrontend: GraphQLJSFrontend!
  
  override func setUpWithError() throws {
    try super.setUpWithError()

    codegenFrontend = try GraphQLJSFrontend()
  }

  override func tearDown() {
    codegenFrontend = nil

    super.tearDown()
  }
  
  func testParseSchemaFromIntrospectionResult() throws {
    let introspectionResult = try String(
      contentsOf: ApolloCodegenInternalTestHelpers.Resources.StarWars.JSONSchema
    )
    
    let schema = try codegenFrontend.loadSchema(
      from: [try codegenFrontend.makeSource(introspectionResult, filePath: "schema.json")]
    )
    
    let characterType = try XCTUnwrap(schema.getType(named: "Character"))
    XCTAssertEqual(characterType.name, "Character")
  }
  
  func testParseSchemaFromSDL() throws {
    let source = try codegenFrontend.makeSource(
      from: ApolloCodegenInternalTestHelpers.Resources.StarWars.JSONSchema
    )
    let schema = try codegenFrontend.loadSchema(from: [source])
    
    let characterType = try XCTUnwrap(schema.getType(named: "Character"))
    XCTAssertEqual(characterType.name, "Character")
  }
  
  func testParseSchemaFromSDLWithSyntaxError() throws {
    let source = try codegenFrontend.makeSource("""
      type Query {
        foo
      }
      """, filePath: "schema.graphqls")
        
    XCTAssertThrowsError(try codegenFrontend.loadSchema(from: [source])) { error in
      whileRecordingErrors {
        let error = try XCTDowncast(error as AnyObject, to: GraphQLError.self)
        XCTAssert(try XCTUnwrap(error.message).starts(with: "Syntax Error"))
        
        XCTAssertEqual(error.sourceLocations?.count, 1)
        XCTAssertEqual(error.sourceLocations?[0].filePath, "schema.graphqls")
        XCTAssertEqual(error.sourceLocations?[0].lineNumber, 3)
      }
    }
  }
  
  func testParseSchemaFromSDLWithValidationErrors() throws {
    let source = try codegenFrontend.makeSource("""
      type Query {
        foo: Foo
        bar: Bar
      }
      """, filePath: "schema.graphqls")
            
    XCTAssertThrowsError(try codegenFrontend.loadSchema(from: [source])) { error in
      whileRecordingErrors {
        print(error)
        if let error1 = error as? GraphQLSchemaValidationError {
          print(error1)
        }
        let error = try XCTDowncast(error as AnyObject, to: GraphQLSchemaValidationError.self)
        
        let validationErrors = error.validationErrors
        XCTAssertEqual(validationErrors.count, 2)
        XCTAssertEqual(validationErrors[0].message, "Unknown type \"Foo\".")
        XCTAssertEqual(validationErrors[1].message, "Unknown type \"Bar\".")
      }
    }
  }
}

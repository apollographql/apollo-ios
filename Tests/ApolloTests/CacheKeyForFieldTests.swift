import XCTest
@testable import Apollo

extension Field {
  var cacheKey: String {
    return try! cacheKey(with: nil)
  }
}

class CacheKeyForFieldTests: XCTestCase {
  func testFieldWithResponseNameOnly() {
    let field = Field("hero", type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero")
  }
  
  func testFieldWithAlias() {
    let field = Field("hero", alias: "r2", type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero")
  }
  
  func testFieldWithArgument() {
    let field = Field("hero", arguments: ["episode": Episode.jedi], type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero(episode:JEDI)")
  }
  
  func testFieldWithAliasAndArgument() {
    let field = Field("hero", alias: "r2", arguments: ["episode": Episode.jedi], type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero(episode:JEDI)")
  }
  
  func testFieldWithMultipleArgumentsIsOrderIndependent() {
    let field1 = Field("hero", arguments: ["foo": "a", "bar": "b"], type: .scalar(String.self))
    let field2 = Field("hero", arguments: ["bar": "b", "foo": "a"], type: .scalar(String.self))
    XCTAssertEqual(field1.cacheKey, field2.cacheKey)
  }
  
  func testFieldWithNestedObjectAsArgumentIsOrderIndependent() {
    let field1 = Field("hero", arguments: ["episode": Episode.jedi, "nested": ["foo": "a", "bar": "b"]], type: .scalar(String.self))
    let field2 = Field("hero", arguments: ["episode": Episode.jedi, "nested": ["bar": "b", "foo": "a"]], type: .scalar(String.self))
    XCTAssertEqual(field1.cacheKey, field2.cacheKey)
  }
  
  func testFieldWithVariableArgument() throws {
    let field = Field("hero", arguments: ["episode": Variable("episode")], type: .scalar(String.self))
    let variables = ["episode": Episode.jedi]
    XCTAssertEqual(try field.cacheKey(with: variables), "hero(episode:JEDI)")
  }
  
  func testFieldWithNilVariableArgument() throws {
    let field = Field("hero", arguments: ["episode": Variable("episode")], type: .scalar(String.self))
    let variables: GraphQLMap = ["episode": nil as Optional<Episode>]
    XCTAssertEqual(try field.cacheKey(with: variables), "hero")
  }
}

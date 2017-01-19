import XCTest
@testable import Apollo

class CacheKeyForFieldTests: XCTestCase {
  func testFieldWithResponseNameOnly() {
    let field = Field(responseName: "hero")
    XCTAssertEqual(field.cacheKey, "hero")
  }
  
  func testFieldWithAlias() {
    let field = Field(responseName: "r2", fieldName: "hero")
    XCTAssertEqual(field.cacheKey, "hero")
  }
  
  func testFieldWithArgument() {
    let field = Field(responseName: "hero", arguments: ["episode": Episode.jedi])
    XCTAssertEqual(field.cacheKey, "hero(episode:JEDI)")
  }
  
  func testFieldWithAliasAndArgument() {
    let field = Field(responseName: "r2", fieldName: "hero", arguments: ["episode": Episode.jedi])
    XCTAssertEqual(field.cacheKey, "hero(episode:JEDI)")
  }
  
  func testFieldWithMultipleArgumentsIsOrderIndependent() {
    let field1 = Field(responseName: "hero", arguments: ["foo": "a", "bar": "b"])
    let field2 = Field(responseName: "hero", arguments: ["bar": "b", "foo": "a"])
    XCTAssertEqual(field1.cacheKey, field2.cacheKey)
  }
  
  func testFieldWithNestedObjectAsArgumentIsOrderIndependent() {
    let field1 = Field(responseName: "hero", arguments: ["episode": Episode.jedi, "nested": ["foo": "a", "bar": "b"]])
    let field2 = Field(responseName: "hero", arguments: ["episode": Episode.jedi, "nested": ["bar": "b", "foo": "a"]])
    XCTAssertEqual(field1.cacheKey, field2.cacheKey)
  }
}

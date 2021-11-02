import XCTest
import Apollo
import ApolloTestSupport
import StarWarsAPI

extension GraphQLField {
  var cacheKey: String {
    return try! cacheKey(with: nil)
  }
}

class CacheKeyForFieldTests: XCTestCase {
  func testFieldWithResponseNameOnly() {
    let field = GraphQLField("hero", type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero")
  }
  
  func testFieldWithAlias() {
    let field = GraphQLField("hero", alias: "r2", type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero")
  }

  func testFieldWithAliasAndArgument() {
    let field = GraphQLField("hero", alias: "r2", arguments: ["episode": "JEDI"], type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero(episode:JEDI)")
  }
  
  func testFieldWithStringArgument() {
    let field = GraphQLField("hero", arguments: ["episode": "JEDI"], type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero(episode:JEDI)")
  }

  func testFieldWithIntegerArgument() {
    let field = GraphQLField("hero", arguments: ["episode": 1], type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero(episode:1)")
  }

  func testFieldWithFloatArgument() {
    let field = GraphQLField("hero", arguments: ["episode": 1.99], type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero(episode:1.99)")
  }

  func testFieldWithNilArgument() {
    let field = GraphQLField("hero", arguments: ["episode": nil], type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero")
  }

  func testFieldWithListArgument() {
    let field = GraphQLField("hero", arguments: ["episodes": [1, 1, 2]], type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero(episodes:[1, 1, 2])")
  }
  
  func testFieldWithDictionaryArgument() throws {
    let field = GraphQLField("hero", arguments: ["nested": ["foo": 1, "bar": 2]], type: .scalar(String.self))
    XCTAssertEqual(field.cacheKey, "hero([nested:bar:2,foo:1])")
  }
  
  func testFieldWithDictionaryArgumentWithVariables() throws {
    let field = GraphQLField("hero", arguments: ["nested": ["foo": GraphQLVariable("a"), "bar": GraphQLVariable("b")]], type: .scalar(String.self))
    let variables: GraphQLMap = ["a": 1, "b": 2]
    XCTAssertEqual(try field.cacheKey(with: variables), "hero([nested:bar:2,foo:1])")
  }
  
  func testFieldWithMultipleArgumentsIsOrderIndependent() {
    let field1 = GraphQLField("hero", arguments: ["foo": "a", "bar": "b"], type: .scalar(String.self))
    let field2 = GraphQLField("hero", arguments: ["bar": "b", "foo": "a"], type: .scalar(String.self))
    XCTAssertEqual(field1.cacheKey, field2.cacheKey)
  }
  
  func testFieldWithInputObjectArgumentIsOrderIndependent() {
    let field1 = GraphQLField("hero", arguments: ["episode": "JEDI", "nested": ["foo": "a", "bar": "b"]], type: .scalar(String.self))
    let field2 = GraphQLField("hero", arguments: ["episode": "JEDI", "nested": ["bar": "b", "foo": "a"]], type: .scalar(String.self))
    XCTAssertEqual(field1.cacheKey, field2.cacheKey)
  }
  
  func testFieldWithVariableArgument() throws {
    let field = GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .scalar(String.self))
    let variables = ["episode": Episode.jedi]
    XCTAssertEqual(try field.cacheKey(with: variables), "hero(episode:JEDI)")
  }
  
  func testFieldWithVariableArgumentWithNil() throws {
    let field = GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .scalar(String.self))
    let variables: GraphQLMap = ["episode": nil as Optional<Episode>]
    XCTAssertEqual(try field.cacheKey(with: variables), "hero")
  }
}

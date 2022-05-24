import XCTest
import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

fileprivate extension Selection.Field {
  var test_cacheKey: String {
    return try! cacheKey(with: nil)
  }
}

class CacheKeyForFieldTests: XCTestCase {
  func testFieldWithResponseNameOnly() {
    let field = Selection.Field("hero", type: .scalar(String.self))
    XCTAssertEqual(field.test_cacheKey, "hero")
  }
  
  func testFieldWithAlias() {
    let field = Selection.Field("hero", alias: "r2", type: .scalar(String.self))
    XCTAssertEqual(field.test_cacheKey, "hero")
  }

  func testFieldWithAliasAndArgument() {
    let field = Selection.Field("hero", alias: "r2", type: .scalar(String.self), arguments: ["episode": "JEDI"])
    XCTAssertEqual(field.test_cacheKey, "hero(episode:JEDI)")
  }
  
  func testFieldWithStringArgument() {
    let field = Selection.Field("hero", type: .scalar(String.self), arguments: ["episode": "JEDI"])
    XCTAssertEqual(field.test_cacheKey, "hero(episode:JEDI)")
  }

  func testFieldWithIntegerArgument() {
    let field = Selection.Field("hero", type: .scalar(String.self), arguments: ["episode": 1])
    XCTAssertEqual(field.test_cacheKey, "hero(episode:1)")
  }

  func testFieldWithFloatArgument() {
    let field = Selection.Field("hero", type: .scalar(String.self), arguments: ["episode": 1.99])
    XCTAssertEqual(field.test_cacheKey, "hero(episode:1.99)")
  }

  func testFieldWithNullArgument() {
    let field = Selection.Field("hero", type: .scalar(String.self), arguments: ["episode": .null])
    XCTAssertEqual(field.test_cacheKey, "hero(episode:null)")
  }

  func testFieldWithNestedNullArgument() throws {
    let field = Selection.Field("hero",
                                type: .scalar(String.self),
                                arguments: ["nested": ["foo": 1, "bar": InputValue.null]])
    XCTAssertEqual(field.test_cacheKey, "hero([nested:bar:null,foo:1])")
  }

  func testFieldWithArgumentOmitted() {
    let field = Selection.Field("hero", type: .scalar(String.self), arguments: [:])
    XCTAssertEqual(field.test_cacheKey, "hero")
  }

  func testFieldWithListArgument() {
    let field = Selection.Field("hero", type: .scalar(String.self), arguments: ["episodes": [1, 1, 2]])
    XCTAssertEqual(field.test_cacheKey, "hero(episodes:[1, 1, 2])")
  }
  
  func testFieldWithDictionaryArgument() throws {
    let field = Selection.Field("hero",
                                type: .scalar(String.self),
                                arguments: ["nested": ["foo": 1, "bar": "2"]])
    XCTAssertEqual(field.test_cacheKey, "hero([nested:bar:2,foo:1])")
  }
  
  func testFieldWithDictionaryArgumentWithVariables() throws {
    let field = Selection.Field("hero", type: .scalar(String.self), arguments: ["nested": ["foo": InputValue.variable("a"), "bar": InputValue.variable("b")]])
    let variables: GraphQLOperation.Variables = ["a": 1, "b": "2"]
    XCTAssertEqual(try field.cacheKey(with: variables), "hero([nested:bar:2,foo:1])")
  }
  
  func testFieldWithMultipleArgumentsIsOrderIndependent() {
    let field1 = Selection.Field("hero", type: .scalar(String.self), arguments: ["foo": "a", "bar": "b"])
    let field2 = Selection.Field("hero", type: .scalar(String.self), arguments: ["bar": "b", "foo": "a"])
    XCTAssertEqual(field1.test_cacheKey, field2.test_cacheKey)
  }
  
  func testFieldWithInputObjectArgumentIsOrderIndependent() {
    let field1 = Selection.Field("hero", type: .scalar(String.self), arguments: ["episode": "JEDI", "nested": ["foo": "a", "bar": "b"]])
    let field2 = Selection.Field("hero", type: .scalar(String.self), arguments: ["episode": "JEDI", "nested": ["bar": "b", "foo": "a"]])
    XCTAssertEqual(field1.test_cacheKey, field2.test_cacheKey)
  }
  
  func testFieldWithVariableArgument() throws {
    let field = Selection.Field("hero", type: .scalar(String.self), arguments: ["episode": .variable("episode")])
    let variables = ["episode": "JEDI"]
    XCTAssertEqual(try field.cacheKey(with: variables), "hero(episode:JEDI)")
  }
  
  func testFieldWithVariableArgumentWithNil() throws {
    let field = Selection.Field("hero", type: .scalar(String.self), arguments: ["episode": .variable("episode")])
    let variables: GraphQLOperation.Variables = ["episode": GraphQLNullable<String>.none]
    XCTAssertEqual(try field.cacheKey(with: variables), "hero")
  }

  func testFieldWithVariableArgumentWithNull() throws {
    let field = Selection.Field("hero", type: .scalar(String.self), arguments: ["episode": .variable("episode")])
    let variables = ["episode": GraphQLNullable<String>.null]
    XCTAssertEqual(try field.cacheKey(with: variables), "hero(episode:null)")
  }

  func testFieldWithVariableArgumentWithNestedNull() throws {
    let field = Selection.Field("hero", type: .scalar(String.self), arguments: ["nested": ["foo": InputValue.variable("a"), "bar": InputValue.variable("b")]])
    let variables: GraphQLOperation.Variables = ["a": 1, "b": GraphQLNullable<String>.null]
    XCTAssertEqual(try field.cacheKey(with: variables), "hero([nested:bar:null,foo:1])")
  }
}

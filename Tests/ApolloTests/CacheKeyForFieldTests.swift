import XCTest
@testable import Apollo

class CacheKeyForFieldTests: XCTestCase {
  func testFieldWithNameOnly() {
    let actual = CacheKeyForField(named: "hero", arguments: [:])
    XCTAssertEqual(actual, "hero")
  }
  
  func testFieldWithStringArgument() {
    let actual = CacheKeyForField(named: "hero", arguments: ["episode": "JEDI"])
    XCTAssertEqual(actual, "hero(episode:JEDI)")
  }

  func testFieldWithIntegerArgument() {
    let actual = CacheKeyForField(named: "hero", arguments: ["episode": 1])
    XCTAssertEqual(actual, "hero(episode:1)")
  }

  func testFieldWithFloatArgument() {
    let actual = CacheKeyForField(named: "hero", arguments: ["episode": 1.99])
    XCTAssertEqual(actual, "hero(episode:1.99)")
  }

  func testFieldWithNullArgument() {
    let actual = CacheKeyForField(named: "hero", arguments: ["episode": NSNull()])
    XCTAssertEqual(actual, "hero(episode:null)")
  }

  func testFieldWithNestedNullArgument() throws {
    let actual = CacheKeyForField(
      named: "hero",
      arguments: ["nested": ["foo": 1, "bar": NSNull()]]
    )
    XCTAssertEqual(actual, "hero([nested:bar:null,foo:1])")
  }

  func testFieldWithListArgument() {
    let actual = CacheKeyForField(named: "hero", arguments: ["episodes": [1, 1, 2]])
    XCTAssertEqual(actual, "hero(episodes:[1, 1, 2])")
  }
  
  func testFieldWithDictionaryArgument() throws {
    let actual = CacheKeyForField(
      named: "hero",
      arguments: ["nested": ["foo": 1, "bar": "2"]]
    )
    XCTAssertEqual(actual, "hero([nested:bar:2,foo:1])")
  }

  func testFieldWithMultipleArgumentsIsOrderIndependent() {
    let actual1 = CacheKeyForField(named: "hero", arguments: ["foo": "a", "bar": "b"])
    let actual2 = CacheKeyForField(named: "hero", arguments: ["bar": "b", "foo": "a"])
    XCTAssertEqual(actual1, actual2)
  }
  
  func testFieldWithInputObjectArgumentIsOrderIndependent() {
    let actual1 = CacheKeyForField(named: "hero", arguments: ["episode": "JEDI", "nested": ["foo": "a", "bar": "b"]])
    let actual2 = CacheKeyForField(named: "hero", arguments: ["episode": "JEDI", "nested": ["bar": "b", "foo": "a"]])
    XCTAssertEqual(actual1, actual2)
  }

}

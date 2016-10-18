import XCTest
@testable import Apollo

class GraphQLMapEncodingTests: XCTestCase {
  static var allTests : [(String, (GraphQLMapEncodingTests) -> () throws -> Void)] {
    return [
      ("testEncodeValue", testEncodeValue),
      ("testEncodeOptionalValue", testEncodeOptionalValue),
      ("testEncodeInputObject", testEncodeInputObject),
      ("testEncodeInputObjectWithOptionalValue", testEncodeInputObjectWithOptionalValue),
    ]
  }
  
  func testEncodeValue() {
    let map: GraphQLMap = ["name": "Luke Skywalker"]
    XCTAssertEqual(map.jsonValue as! NSDictionary, ["name": "Luke Skywalker"])
  }
  
  func testEncodeOptionalValue() {
    let map: GraphQLMap = ["name": nil]
    XCTAssertEqual(map.jsonValue as! NSDictionary, ["name": NSNull()])
  }
  
  func testEncodeInputObject() {
    let review = ReviewInput(stars: 5, commentary: "This is a great movie!")
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(map.jsonValue as! NSDictionary, ["review": ["stars": 5, "commentary": "This is a great movie!"]])
  }
  
  func testEncodeInputObjectWithOptionalValue() {
    let review = ReviewInput(stars: 5, commentary: nil)
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(map.jsonValue as! NSDictionary, ["review": ["stars": 5, "commentary": NSNull()]])
  }
}

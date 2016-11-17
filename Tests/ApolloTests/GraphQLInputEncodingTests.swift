import XCTest
@testable import Apollo

class GraphQLInputEncodingTests: XCTestCase {
  static var allTests : [(String, (GraphQLInputEncodingTests) -> () throws -> Void)] {
    return [
      ("testEncodeValue", testEncodeValue),
      ("testEncodeOptionalValue", testEncodeOptionalValue),
      ("testEncodeNilValue", testEncodeNilValue),
      ("testEncodeEnumValue", testEncodeEnumValue),
      ("testEncodeMap", testEncodeMap),
      ("testEncodeOptionalMap", testEncodeOptionalMap),
      ("testEncodeNilMap", testEncodeNilMap),
      ("testEncodeList", testEncodeList),
      ("testEncodeOptionalList", testEncodeOptionalList),
      ("testEncodeNilList", testEncodeNilList),
      ("testEncodeInputObject", testEncodeInputObject),
      ("testEncodeInputObjectWithOptionalValue", testEncodeInputObjectWithOptionalValue),
      ("testEncodeInputObjectWithNilValue", testEncodeInputObjectWithNilValue),
    ]
  }
  
  private func serialize(value: GraphQLInputValue) -> NSDictionary {
    let data = try! JSONSerializationFormat.serialize(value: value)
    return try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
  }
  
  func testEncodeValue() {
    let map: GraphQLMap = ["name": "Luke Skywalker"]
    XCTAssertEqual(serialize(value: map), ["name": "Luke Skywalker"])
  }
  
  func testEncodeOptionalValue() {
    let map: GraphQLMap = ["name": "Luke Skywalker" as String?]
    XCTAssertEqual(serialize(value: map), ["name": "Luke Skywalker"])
  }
  
  func testEncodeNilValue() {
    let map: GraphQLMap = ["name": nil as String?]
    XCTAssertEqual(serialize(value: map), ["name": NSNull()])
  }
  
  func testEncodeEnumValue() {
    let map: GraphQLMap = ["favoriteEpisode": Episode.jedi]
    XCTAssertEqual(serialize(value: map), ["favoriteEpisode": "JEDI"])
  }
  
  func testEncodeMap() {
    let map: GraphQLMap = ["hero": ["name": "Luke Skywalker"]]
    XCTAssertEqual(serialize(value: map), ["hero": ["name": "Luke Skywalker"]])
  }
  
  func testEncodeOptionalMap() {
    let map: GraphQLMap = ["hero": ["name": "Luke Skywalker"] as GraphQLMap?]
    XCTAssertEqual(serialize(value: map), ["hero": ["name": "Luke Skywalker"]])
  }
  
  func testEncodeNilMap() {
    let map: GraphQLMap = ["hero": nil as GraphQLMap?]
    XCTAssertEqual(serialize(value: map), ["hero": NSNull()])
  }
  
  func testEncodeList() {
    let map: GraphQLMap = ["appearsIn": [.jedi, .empire] as [Episode]]
    XCTAssertEqual(serialize(value: map), ["appearsIn": ["JEDI", "EMPIRE"]])
  }
  
  func testEncodeOptionalList() {
    let map: GraphQLMap = ["appearsIn": [.jedi, .empire] as [Episode]?]
    XCTAssertEqual(serialize(value: map), ["appearsIn": ["JEDI", "EMPIRE"]])
  }
  
  func testEncodeNilList() {
    let map: GraphQLMap = ["appearsIn": nil as [Episode]?]
    XCTAssertEqual(serialize(value: map), ["appearsIn": NSNull()])
  }
  
  func testEncodeInputObject() {
    let review = ReviewInput(stars: 5, commentary: "This is a great movie!")
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serialize(value: map), ["review": ["stars": 5, "commentary": "This is a great movie!"]])
  }
  
  func testEncodeInputObjectWithOptionalValue() {
    let review = ReviewInput(stars: 5, commentary: "This is a great movie!" as String?)
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serialize(value: map), ["review": ["stars": 5, "commentary": "This is a great movie!"]])
  }
  
  func testEncodeInputObjectWithNilValue() {
    let review = ReviewInput(stars: 5, commentary: nil)
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serialize(value: map), ["review": ["stars": 5, "commentary": NSNull()]])
  }
}

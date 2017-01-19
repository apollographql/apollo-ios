import XCTest
@testable import Apollo

class GraphQLInputValueEncodingTests: XCTestCase {
  static var allTests : [(String, (GraphQLInputValueEncodingTests) -> () throws -> Void)] {
    return [
      ("testEncodeValue", testEncodeValue),
      ("testEncodeOptionalValue", testEncodeOptionalValue),
      ("testEncodeNilValue", testEncodeNilValue),
      ("testEncodeNullValue", testEncodeNilValue),
      ("testEncodeEnumValue", testEncodeEnumValue),
      ("testEncodeMap", testEncodeMap),
      ("testEncodeOptionalMap", testEncodeOptionalMap),
      ("testEncodeNilMap", testEncodeNilMap),
      ("testEncodeList", testEncodeList),
      ("testEncodeOptionalList", testEncodeOptionalList),
      ("testEncodeNilList", testEncodeNilList),
      ("testEncodeInputObject", testEncodeInputObject),
      ("testEncodeInputObjectWithExplicitOptionalValue", testEncodeInputObjectWithExplicitOptionalValue),
      ("testEncodeInputObjectWithoutOptionalValue", testEncodeInputObjectWithoutOptionalValue),
      ("testEncodeInputObjectWithExplicitNilValue", testEncodeInputObjectWithExplicitNilValue),
      ("testEncodeInputObjectWithNestedInputObject", testEncodeInputObjectWithNestedInputObject),
    ]
  }
  
  private func serializeAndDeserialize(value: GraphQLInputValue) -> NSDictionary {
    let data = try! JSONSerializationFormat.serialize(value: value)
    return try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
  }
  
  func testEncodeValue() {
    let map: GraphQLMap = ["name": "Luke Skywalker"]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["name": "Luke Skywalker"])
  }
  
  func testEncodeOptionalValue() {
    let map: GraphQLMap = ["name": "Luke Skywalker" as String?]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["name": "Luke Skywalker"])
  }
  
  func testEncodeNilValue() {
    let map: GraphQLMap = ["name": nil as String?]
    XCTAssertEqual(serializeAndDeserialize(value: map), [:])
  }
  
  func testEncodeNullValue() {
    let map: GraphQLMap = ["name": NSNull()]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["name": NSNull()])
  }
  
  func testEncodeEnumValue() {
    let map: GraphQLMap = ["favoriteEpisode": Episode.jedi]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["favoriteEpisode": "JEDI"])
  }
  
  func testEncodeMap() {
    let map: GraphQLMap = ["hero": ["name": "Luke Skywalker"]]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["hero": ["name": "Luke Skywalker"]])
  }
  
  func testEncodeOptionalMap() {
    let map: GraphQLMap = ["hero": ["name": "Luke Skywalker"] as GraphQLMap?]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["hero": ["name": "Luke Skywalker"]])
  }
  
  func testEncodeNilMap() {
    let map: GraphQLMap = ["hero": nil as GraphQLMap?]
    XCTAssertEqual(serializeAndDeserialize(value: map), [:])
  }
  
  func testEncodeList() {
    let map: GraphQLMap = ["appearsIn": [.jedi, .empire] as [Episode]]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["appearsIn": ["JEDI", "EMPIRE"]])
  }
  
  func testEncodeOptionalList() {
    let map: GraphQLMap = ["appearsIn": [.jedi, .empire] as [Episode]?]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["appearsIn": ["JEDI", "EMPIRE"]])
  }
  
  func testEncodeNilList() {
    let map: GraphQLMap = ["appearsIn": nil as [Episode]?]
    XCTAssertEqual(serializeAndDeserialize(value: map), [:])
  }
  
  func testEncodeInputObject() {
    let review = ReviewInput(stars: 5, commentary: "This is a great movie!")
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["review": ["stars": 5, "commentary": "This is a great movie!"]])
  }
  
  func testEncodeInputObjectWithExplicitOptionalValue() {
    let review = ReviewInput(stars: 5, commentary: "This is a great movie!" as String?)
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["review": ["stars": 5, "commentary": "This is a great movie!"]])
  }
  
  func testEncodeInputObjectWithoutOptionalValue() {
    let review = ReviewInput(stars: 5)
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["review": ["stars": 5]])
  }
  
  func testEncodeInputObjectWithExplicitNilValue() {
    let review = ReviewInput(stars: 5, commentary: nil)
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["review": ["stars": 5]])
  }
  
  func testEncodeInputObjectWithNestedInputObject() {
    let review = ReviewInput(stars: 5, favoriteColor: ColorInput(red: 0, green: 0, blue: 0))
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serializeAndDeserialize(value: map), ["review": ["stars": 5, "favoriteColor": ["red": 0, "blue": 0, "green": 0]]])
  }
}

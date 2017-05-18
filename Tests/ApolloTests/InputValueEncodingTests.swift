import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class InputValueEncodingTests: XCTestCase {
  private func serializeAndDeserialize(_ map: GraphQLMap) -> NSDictionary {
    let data = try! JSONSerializationFormat.serialize(value: map.withNilValuesRemoved)
    return try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
  }
  
  func testEncodeValue() {
    let map: GraphQLMap = ["name": "Luke Skywalker"]
    XCTAssertEqual(serializeAndDeserialize(map), ["name": "Luke Skywalker"])
  }
  
  func testEncodeOptionalValue() {
    let map: GraphQLMap = ["name": "Luke Skywalker" as Optional<String?>]
    XCTAssertEqual(serializeAndDeserialize(map), ["name": "Luke Skywalker"])
  }
  
  func testEncodeOptionalValueWithValueMissing() {
    let map: GraphQLMap = ["name": Optional<String?>.none]
    XCTAssertEqual(serializeAndDeserialize(map), [:])
  }
  
  func testEncodeOptionalValueWithExplicitNull() {
    let map: GraphQLMap = ["name": Optional<String?>.some(.none)]
    XCTAssertEqual(serializeAndDeserialize(map), ["name": NSNull()])
  }
  
  func testEncodeEnumValue() {
    let map: GraphQLMap = ["favoriteEpisode": Episode.jedi]
    XCTAssertEqual(serializeAndDeserialize(map), ["favoriteEpisode": "JEDI"])
  }
  
  func testEncodeMap() {
    let map: GraphQLMap = ["hero": ["name": "Luke Skywalker"]]
    XCTAssertEqual(serializeAndDeserialize(map), ["hero": ["name": "Luke Skywalker"]])
  }
  
  func testEncodeOptionalMapWithValueMissing() {
    let map: GraphQLMap = ["hero": Optional<GraphQLMap?>.none]
    XCTAssertEqual(serializeAndDeserialize(map), [:])
  }
  
  func testEncodeList() {
    let map: GraphQLMap = ["appearsIn": [.jedi, .empire] as [Episode]]
    XCTAssertEqual(serializeAndDeserialize(map), ["appearsIn": ["JEDI", "EMPIRE"]])
  }
  
  func testEncodeOptionalList() {
    let map: GraphQLMap = ["appearsIn": [.jedi, .empire] as Optional<[Episode]?>]
    XCTAssertEqual(serializeAndDeserialize(map), ["appearsIn": ["JEDI", "EMPIRE"]])
  }
  
  func testEncodeOptionalListWithValueMissing() {
    let map: GraphQLMap = ["appearsIn": Optional<[Episode]?>.none]
    XCTAssertEqual(serializeAndDeserialize(map), [:])
  }
  
  func testEncodeInputObject() {
    let review = ReviewInput(stars: 5, commentary: "This is a great movie!")
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serializeAndDeserialize(map), ["review": ["stars": 5, "commentary": "This is a great movie!"]])
  }
  
  func testEncodeInputObjectWithOptionalPropertyMissing() {
    let review = ReviewInput(stars: 5)
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serializeAndDeserialize(map), ["review": ["stars": 5]])
  }
  
  func testEncodeInputObjectWithExplicitNilForOptionalProperty() {
    let review = ReviewInput(stars: 5, commentary: nil)
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serializeAndDeserialize(map), ["review": ["stars": 5]])
  }
  
  func testEncodeInputObjectWithExplicitSomeNilForOptionalProperty() {
    let review = ReviewInput(stars: 5, commentary: .some(nil))
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serializeAndDeserialize(map), ["review": ["stars": 5, "commentary": NSNull()]])
  }
  
  func testEncodeInputObjectWithNestedInputObject() {
    let review = ReviewInput(stars: 5, favoriteColor: ColorInput(red: 0, green: 0, blue: 0))
    let map: GraphQLMap = ["review": review]
    XCTAssertEqual(serializeAndDeserialize(map), ["review": ["stars": 5, "favoriteColor": ["red": 0, "blue": 0, "green": 0]]])
  }
}

import XCTest
@testable import Apollo

class JSONTests: XCTestCase {
  func testMissingValueMatchable() {
    let value = JSONDecodingError.missingValue

    XCTAssertTrue(value ~= JSONDecodingError.missingValue)
    XCTAssertFalse(value ~= JSONDecodingError.nullValue)
    XCTAssertFalse(value ~= JSONDecodingError.wrongType)
    XCTAssertFalse(value ~= JSONDecodingError.couldNotConvert(value: 123, to: Int.self))
  }

  func testNullValueMatchable() {
    let value = JSONDecodingError.nullValue

    XCTAssertTrue(value ~= JSONDecodingError.nullValue)
    XCTAssertFalse(value ~= JSONDecodingError.missingValue)
    XCTAssertFalse(value ~= JSONDecodingError.wrongType)
    XCTAssertFalse(value ~= JSONDecodingError.couldNotConvert(value: 123, to: Int.self))
  }

  func testWrongTypeMatchable() {
    let value = JSONDecodingError.wrongType

    XCTAssertTrue(value ~= JSONDecodingError.wrongType)
    XCTAssertFalse(value ~= JSONDecodingError.nullValue)
    XCTAssertFalse(value ~= JSONDecodingError.missingValue)
    XCTAssertFalse(value ~= JSONDecodingError.couldNotConvert(value: 123, to: Int.self))
  }

  func testCouldNotConvertMatchable() {
    let value = JSONDecodingError.couldNotConvert(value: 123, to: Int.self)

    XCTAssertTrue(value ~= JSONDecodingError.couldNotConvert(value: 123, to: Int.self))
    XCTAssertTrue(value ~= JSONDecodingError.couldNotConvert(value: "abc", to: String.self))
    XCTAssertFalse(value ~= JSONDecodingError.wrongType)
    XCTAssertFalse(value ~= JSONDecodingError.nullValue)
    XCTAssertFalse(value ~= JSONDecodingError.missingValue)
  }
  
  func testJSONDictionaryEncodingAndDecoding() throws {
    let jsonString = """
{
  "a_dict": {
    "a_bool": true,
    "another_dict" : {
      "a_double": 23.1,
      "an_int": 8,
      "a_string": "LOL wat"
    },
    "an_array": [
      "one",
      "two",
      "three"
    ],
    "a_null": null
  }
}
"""
    let data = try XCTUnwrap(jsonString.data(using: .utf8))
    let json = try JSONSerializationFormat.deserialize(data: data)
    XCTAssertNotNil(json)
    
    let dict = try Dictionary<String, Any?>(jsonValue: json)
    XCTAssertNotNil(dict)
    
    let moarData = try JSONSerializationFormat.serialize(value: dict)
    XCTAssertNotNil(moarData)
    
    print(String(bytes: moarData, encoding: .utf8)!)
  }
  

}

extension Dictionary: JSONDecodable {
    public init(jsonValue value: JSONValue) throws {
        guard let dictionary = value as? Dictionary else {
            throw JSONDecodingError.couldNotConvert(value: value, to: Dictionary.self)
        }
        
        self = dictionary
    }
}

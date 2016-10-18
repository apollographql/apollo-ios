import XCTest
@testable import Apollo

// Because XCTAssertThrowsError expects an @autoclosure argument and that doesn't allow
// us to specify an explicit return type, we need this wrapper function to select
// the right overloaded version of the GraphQLMap method under test
private func with<T>(returnType: T.Type, _ closure: @autoclosure () throws -> T) rethrows -> T {
  let value: T = try closure()
  return value
}

class GraphQLMapDecodingTests: XCTestCase {
  static var allTests : [(String, (GraphQLMapDecodingTests) -> () throws -> Void)] {
    return [
      ("testGetValue", testGetValue),
      ("testGetValueWithMissingKey", testGetValueWithMissingKey),
      ("testGetValueWithNull", testGetValueWithNull),
      ("testGetValueWithWrongType", testGetValueWithWrongType),
      ("testGetOptionalValue", testGetOptionalValue),
      ("testGetOptionalValueWithMissingKey", testGetOptionalValueWithMissingKey),
      ("testGetOptionalValueWithNull", testGetOptionalValueWithNull),
      ("testGetOptionalValueWithWrongType", testGetOptionalValueWithWrongType),
      ("testGetList", testGetList),
      ("testGetListWithMissingKey", testGetListWithMissingKey),
      ("testGetListWithNull", testGetListWithNull),
      ("testGetListWithWrongType", testGetListWithWrongType),
      ("testGetOptionalList", testGetOptionalList),
      ("testGetOptionalListWithNull", testGetOptionalList),
      ("testGetOptionalListWithWrongType", testGetOptionalListWithWrongType),
      ("testGetOptionalListWithMissingKey", testGetOptionalListWithMissingKey),
      ("testGetListWithOptionalElements", testGetListWithOptionalElements),
      ("testGetOptionalListWithOptionalElements", testGetOptionalListWithOptionalElements)
    ]
  }
  
  func testGetValue() throws {
    let map = GraphQLMap(jsonObject: ["name": "Luke Skywalker"])
    let value: String = try map.value(forKey: "name")
    XCTAssertEqual(value, "Luke Skywalker")
  }

  func testGetValueWithMissingKey() {
    let map = GraphQLMap(jsonObject: [:])

    XCTAssertThrowsError(try with(returnType: String.self, map.value(forKey: "name"))) { (error) in
      if case JSONDecodingError.missingValue(let key) = error {
        XCTAssertEqual(key, "name")
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetValueWithNull() throws {
    let map = GraphQLMap(jsonObject: ["name": NSNull()])

    XCTAssertThrowsError(try with(returnType: String.self, map.value(forKey: "name"))) { (error) in
      if case JSONDecodingError.couldNotConvert(let value, let expectedType) = error {
        XCTAssertEqual(value as? NSNull, NSNull())
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetValueWithWrongType() throws {
    let map = GraphQLMap(jsonObject: ["name": 10])

    XCTAssertThrowsError(try with(returnType: String.self, map.value(forKey: "name"))) { (error) in
      if case JSONDecodingError.couldNotConvert(let value, let expectedType) = error {
        XCTAssertEqual(value as? Int, 10)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetOptionalValue() throws {
    let map = GraphQLMap(jsonObject: ["name": "Luke Skywalker"])
    let value: String? = try map.optionalValue(forKey: "name")
    XCTAssertEqual(value, "Luke Skywalker")
  }

  func testGetOptionalValueWithMissingKey() throws {
    let map = GraphQLMap(jsonObject: [:])
    let value: String? = try map.optionalValue(forKey: "name")
    XCTAssertNil(value)
  }

  func testGetOptionalValueWithNull() throws {
    let map = GraphQLMap(jsonObject: ["name": NSNull()])
    let value: Int? = try map.optionalValue(forKey: "name")
    XCTAssertNil(value)
  }

  func testGetOptionalValueWithWrongType() throws {
    let map = GraphQLMap(jsonObject: ["name": 10])

    XCTAssertThrowsError(try with(returnType: Optional<String>.self, map.optionalValue(forKey: "name"))) { (error) in
      if case JSONDecodingError.couldNotConvert(let value, let expectedType) = error {
        XCTAssertEqual(value as? Int, 10)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetList() throws {
    let map = GraphQLMap(jsonObject: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let value: [Episode] = try map.list(forKey: "appearsIn")
    XCTAssertEqual(value, [.newhope, .empire, .jedi])
  }

  func testGetListWithMissingKey() {
    let map = GraphQLMap(jsonObject: [:])

    XCTAssertThrowsError(try with(returnType: Array<Episode>.self, map.list(forKey: "appearsIn"))) { (error) in
      if case JSONDecodingError.missingValue(let key) = error {
        XCTAssertEqual(key, "appearsIn")
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetListWithNull() throws {
    let map = GraphQLMap(jsonObject: ["appearsIn": NSNull()])

    XCTAssertThrowsError(try with(returnType: Array<Episode>.self, map.list(forKey: "appearsIn"))) { (error) in
      if case JSONDecodingError.couldNotConvert(let value, _) = error {
        XCTAssertEqual(value as? NSNull, NSNull())
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetListWithWrongType() throws {
    let map = GraphQLMap(jsonObject: ["appearsIn": [4, 5, 6]])

    XCTAssertThrowsError(try with(returnType: Array<Episode>.self, map.list(forKey: "appearsIn"))) { (error) in
      guard case JSONDecodingError.couldNotConvert = error else {
        XCTFail("Unexpected error: \(error)")
        return
      }
    }
  }

  func testGetOptionalList() throws {
    let map = GraphQLMap(jsonObject: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let value: [Episode]? = try map.list(forKey: "appearsIn")
    XCTAssertEqual(value!, [.newhope, .empire, .jedi])
  }

  func testGetOptionalListWithMissingKey() throws {
    let map = GraphQLMap(jsonObject: [:])
    let value: [Episode]? = try map.optionalList(forKey: "appearsIn")
    XCTAssertNil(value)
  }

  func testGetOptionalListWithNull() throws {
    let map = GraphQLMap(jsonObject: ["appearsIn": NSNull()])
    let value: [Episode]? = try map.optionalList(forKey: "appearsIn")
    XCTAssertNil(value)
  }

  func testGetOptionalListWithWrongType() throws {
    let map = GraphQLMap(jsonObject: ["appearsIn": [4, 5, 6]])

    XCTAssertThrowsError(try with(returnType: Optional<Array<Episode>>.self, map.list(forKey: "appearsIn"))) { (error) in
      guard case JSONDecodingError.couldNotConvert = error else {
        XCTFail("Unexpected error: \(error)")
        return
      }
    }
  }

  func testGetListWithOptionalElements() throws {
    let map = GraphQLMap(jsonObject: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let value: [Episode?] = try map.list(forKey: "appearsIn")
    XCTAssertEqual(value.flatMap { $0 }, [.newhope, .empire, .jedi])
  }

  func testGetOptionalListWithOptionalElements() throws {
    let map = GraphQLMap(jsonObject: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let value: [Episode?]? = try map.list(forKey: "appearsIn")
    XCTAssertEqual(value!.flatMap { $0 }, [.newhope, .empire, .jedi])
  }
}

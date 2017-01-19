import XCTest
@testable import Apollo

// Because XCTAssertThrowsError expects an @autoclosure argument and that doesn't allow
// us to specify an explicit return type, we need this wrapper function to select
// the right overloaded version of the GraphQLDataReader method under test
private func with<T>(returnType: T.Type, _ body: @autoclosure () throws -> T) rethrows -> T {
  let value: T = try body()
  return value
}

private func read(from rootObject: JSONObject) -> GraphQLResultReader {
  return GraphQLResultReader { field, _, _ in
    return rootObject[field.responseName]
  }
}

class GraphQLResultReaderTests: XCTestCase {
  static var allTests: [(String, (GraphQLResultReaderTests) -> () throws -> Void)] {
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
      ("testGetOptionalListWithNull", testGetOptionalListWithNull),
      ("testGetOptionalListWithWrongType", testGetOptionalListWithWrongType),
      ("testGetOptionalListWithMissingKey", testGetOptionalListWithMissingKey),
      ("testGetListWithOptionalElements", testGetListWithOptionalElements),
      ("testGetOptionalListWithOptionalElements", testGetOptionalListWithOptionalElements)
    ]
  }
  
  func testGetValue() throws {
    let reader = read(from: ["name": "Luke Skywalker"])
    let value: String = try reader.value(for: Field(responseName: "name"))
    XCTAssertEqual(value, "Luke Skywalker")
  }

  func testGetValueWithMissingKey() {
    let reader = read(from: [:])

    XCTAssertThrowsError(try with(returnType: String.self, reader.value(for: Field(responseName: "name")))) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetValueWithNull() throws {
    let reader = read(from: ["name": NSNull()])
    
    XCTAssertThrowsError(try with(returnType: String.self, reader.value(for: Field(responseName: "name")))) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetValueWithWrongType() throws {
    let reader = read(from: ["name": 10])

    XCTAssertThrowsError(try with(returnType: String.self, reader.value(for: Field(responseName: "name")))) { (error) in
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
          XCTAssertEqual(error.path, ["name"])
          XCTAssertEqual(value as? Int, 10)
          XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetOptionalValue() throws {
    let reader = read(from: ["name": "Luke Skywalker"])
    let value: String? = try reader.optionalValue(for: Field(responseName: "name"))
    XCTAssertEqual(value, "Luke Skywalker")
  }

  func testGetOptionalValueWithMissingKey() throws {
    let reader = read(from: [:])
    
    XCTAssertThrowsError(try with(returnType: Optional<String>.self, reader.optionalValue(for: Field(responseName: "name")))) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetOptionalValueWithNull() throws {
    let reader = read(from: ["name": NSNull()])
    let value: String? = try reader.optionalValue(for: Field(responseName: "name"))
    XCTAssertNil(value)
  }

  func testGetOptionalValueWithWrongType() throws {
    let reader = read(from: ["name": 10])

    XCTAssertThrowsError(try with(returnType: Optional<String>.self, reader.optionalValue(for: Field(responseName: "name")))) { (error) in
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertEqual(value as? Int, 10)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetList() throws {
    let reader = read(from: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let value: [Episode] = try reader.list(for: Field(responseName: "appearsIn"))
    XCTAssertEqual(value, [.newhope, .empire, .jedi])
  }

  func testGetListWithMissingKey() {
    let reader = read(from: [:])

    XCTAssertThrowsError(try with(returnType: Array<Episode>.self, reader.list(for: Field(responseName: "appearsIn")))) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetListWithNull() throws {
    let reader = read(from: ["appearsIn": NSNull()])

    XCTAssertThrowsError(try with(returnType: Array<Episode>.self, reader.list(for: Field(responseName: "appearsIn")))) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetListWithWrongType() throws {
    let reader = read(from: ["appearsIn": [4, 5, 6]])

    XCTAssertThrowsError(try with(returnType: Array<Episode>.self, reader.list(for: Field(responseName: "appearsIn")))) { (error) in
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["appearsIn", "0"])
        XCTAssertEqual(value as? Int, 4)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetOptionalList() throws {
    let reader = read(from: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let value: [Episode]? = try reader.optionalList(for: Field(responseName: "appearsIn"))
    XCTAssertEqual(value!, [.newhope, .empire, .jedi])
  }

  func testGetOptionalListWithMissingKey() throws {
    let reader = read(from: [:])
    
    XCTAssertThrowsError(try with(returnType: Optional<Array<Episode>>.self, reader.optionalList(for: Field(responseName: "appearsIn")))) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetOptionalListWithNull() throws {
    let reader = read(from: ["appearsIn": NSNull()])
    let value: [Episode]? = try reader.optionalList(for: Field(responseName: "appearsIn"))
    XCTAssertNil(value)
  }

  func testGetOptionalListWithWrongType() throws {
    let reader = read(from: ["appearsIn": [4, 5, 6]])

    XCTAssertThrowsError(try with(returnType: Optional<Array<Episode>>.self, reader.optionalList(for: Field(responseName: "appearsIn")))) { (error) in
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["appearsIn", "0"])
        XCTAssertEqual(value as? Int, 4)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetListWithOptionalElements() throws {
    let reader = read(from: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let value: [Episode?] = try reader.list(for: Field(responseName: "appearsIn"))
    XCTAssertEqual(value, [.newhope, .empire, .jedi] as [Episode?])
  }

  func testGetOptionalListWithOptionalElements() throws {
    let reader = read(from: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let value: [Episode?]? = try reader.optionalList(for: Field(responseName: "appearsIn"))
    XCTAssertEqual(value, [.newhope, .empire, .jedi] as [Episode?])
  }
}

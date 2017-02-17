import XCTest
@testable import Apollo

private func read(from rootObject: JSONObject) -> GraphQLResultReader {
  return GraphQLResultReader { field, _, _ in
    return rootObject[field.responseName]
  }
}

private extension GraphQLResultReader {
  func read(_ field: Field) throws -> Any? {
    return try execute(selectionSet: [field])[0]
  }
}

class GraphQLResultReaderTests: XCTestCase {
  func testGetScalar() throws {
    let reader = read(from: ["name": "Luke Skywalker"])
    let field = Field("name", type: .nonNull(.scalar(String.self)))
    
    let value = try reader.read(field) as! String
    
    XCTAssertEqual(value, "Luke Skywalker")
  }

  func testGetScalarWithMissingKey() {
    let reader = read(from: [:])
    let field = Field("name", type: .nonNull(.scalar(String.self)))

    XCTAssertThrowsError(try reader.read(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetScalarWithNull() throws {
    let reader = read(from: ["name": NSNull()])
    let field = Field("name", type: .nonNull(.scalar(String.self)))
    
    XCTAssertThrowsError(try reader.read(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetScalarWithWrongType() throws {
    let reader = read(from: ["name": 10])
    let field = Field("name", type: .nonNull(.scalar(String.self)))

    XCTAssertThrowsError(try reader.read(field)) { (error) in
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
          XCTAssertEqual(error.path, ["name"])
          XCTAssertEqual(value as? Int, 10)
          XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetOptionalScalar() throws {
    let reader = read(from: ["name": "Luke Skywalker"])
    let field = Field("name", type: .scalar(String.self))
    
    let value = try reader.read(field) as! String?
    XCTAssertEqual(value, "Luke Skywalker")
  }

  func testGetOptionalScalarWithMissingKey() throws {
    let reader = read(from: [:])
    let field = Field("name", type: .scalar(String.self))
    
    XCTAssertThrowsError(try reader.read(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetOptionalScalarWithNull() throws {
    let reader = read(from: ["name": NSNull()])
    let field = Field("name", type: .scalar(String.self))

    let value = try reader.read(field) as! String?
    
    XCTAssertNil(value)
  }

  func testGetOptionalScalarWithWrongType() throws {
    let reader = read(from: ["name": 10])
    let field = Field("name", type: .scalar(String.self))

    XCTAssertThrowsError(try reader.read(field)) { (error) in
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertEqual(value as? Int, 10)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetScalarList() throws {
    let reader = read(from: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))

    let value = try reader.read(field) as! [Episode]
    
    XCTAssertEqual(value, [.newhope, .empire, .jedi])
  }

  func testGetScalarListWithMissingKey() {
    let reader = read(from: [:])
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))

    XCTAssertThrowsError(try reader.read(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetScalarListWithNull() throws {
    let reader = read(from: ["appearsIn": NSNull()])
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))

    XCTAssertThrowsError(try reader.read(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetScalarListWithWrongType() throws {
    let reader = read(from: ["appearsIn": [4, 5, 6]])
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))

    XCTAssertThrowsError(try reader.read(field)) { (error) in
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertEqual(value as? Int, 4)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetOptionalScalarList() throws {
    let reader = read(from: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))

    let value = try reader.read(field) as! [Episode]?
    
    XCTAssertEqual(value!, [.newhope, .empire, .jedi])
  }

  func testGetOptionalScalarListWithMissingKey() throws {
    let reader = read(from: [:])
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))

    XCTAssertThrowsError(try reader.read(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetOptionalScalarListWithNull() throws {
    let reader = read(from: ["appearsIn": NSNull()])
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))

    let value = try reader.read(field) as! [Episode]?
    
    XCTAssertNil(value)
  }

  func testGetOptionalScalarListWithWrongType() throws {
    let reader = read(from: ["appearsIn": [4, 5, 6]])
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))

    XCTAssertThrowsError(try reader.read(field)) { (error) in
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertEqual(value as? Int, 4)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testGetScalarListWithOptionalElements() throws {
    let reader = read(from: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let field = Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self))))

    let value = try reader.read(field) as! [Episode?]

    XCTAssertEqual(value, [.newhope, .empire, .jedi] as [Episode?])
  }

  func testGetOptionalScalarListWithOptionalElements() throws {
    let reader = read(from: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let field = Field("appearsIn", type: .list(.scalar(Episode.self)))

    let value = try reader.read(field) as! [Episode?]?

    XCTAssertEqual(value, [.newhope, .empire, .jedi] as [Episode?])
  }
}

import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

private struct MockSelectionSet: GraphQLSelectionSet {
  public static let selections: [Selection] = []
  static var possibleTypes = ["Mock"]
  
  public var snapshot: Snapshot
  
  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }
}

func readFieldValue(_ field: Field, from object: JSONObject) throws -> Any? {
  let executor = GraphQLExecutor { object, info in
    return Promise(fulfilled: object[info.responseKeyForField])
  }
  
  return try executor.execute(selections: [field], on: object, withKey: "", variables: [:], accumulator: GraphQLSelectionSetMapper<MockSelectionSet>()).await().snapshot[field.responseKey]!
}

class ReadFieldValueTests: XCTestCase {
  func testGetScalar() throws {
    let object: JSONObject = ["name": "Luke Skywalker"]
    let field = Field("name", type: .nonNull(.scalar(String.self)))
    
    let value = try readFieldValue(field, from: object) as! String
    
    XCTAssertEqual(value, "Luke Skywalker")
  }
  
  func testGetScalarWithMissingKey() {
    let object: JSONObject = [:]
    let field = Field("name", type: .nonNull(.scalar(String.self)))
    
    XCTAssertThrowsError(try readFieldValue(field, from: object)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetScalarWithNull() throws {
    let object: JSONObject = ["name": NSNull()]
    let field = Field("name", type: .nonNull(.scalar(String.self)))
    
    XCTAssertThrowsError(try readFieldValue(field, from: object)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetScalarWithWrongType() throws {
    let object: JSONObject = ["name": 10]
    let field = Field("name", type: .nonNull(.scalar(String.self)))
    
    XCTAssertThrowsError(try readFieldValue(field, from: object)) { (error) in
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
    let object: JSONObject = ["name": "Luke Skywalker"]
    let field = Field("name", type: .scalar(String.self))
    
    let value = try readFieldValue(field, from: object) as! String?
    XCTAssertEqual(value, "Luke Skywalker")
  }
  
  func testGetOptionalScalarWithMissingKey() throws {
    let object: JSONObject = [:]
    let field = Field("name", type: .scalar(String.self))
    
    XCTAssertThrowsError(try readFieldValue(field, from: object)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetOptionalScalarWithNull() throws {
    let object: JSONObject = ["name": NSNull()]
    let field = Field("name", type: .scalar(String.self))
    
    let value = try readFieldValue(field, from: object) as! String?
    
    XCTAssertNil(value)
  }
  
  func testGetOptionalScalarWithWrongType() throws {
    let object: JSONObject = ["name": 10]
    let field = Field("name", type: .scalar(String.self))
    
    XCTAssertThrowsError(try readFieldValue(field, from: object)) { (error) in
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
    let object: JSONObject = ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]]
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))
    
    let value = try readFieldValue(field, from: object) as! [Episode]
    
    XCTAssertEqual(value, [.newhope, .empire, .jedi])
  }
  
  func testGetEmptyScalarList() throws {
    let object: JSONObject = ["appearsIn": []]
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))
    
    let value = try readFieldValue(field, from: object) as! [Episode]
    
    XCTAssertEqual(value, [])
  }
  
  func testGetScalarListWithMissingKey() {
    let object: JSONObject = [:]
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))
    
    XCTAssertThrowsError(try readFieldValue(field, from: object)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetScalarListWithNull() throws {
    let object: JSONObject = ["appearsIn": NSNull()]
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))
    
    XCTAssertThrowsError(try readFieldValue(field, from: object)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetScalarListWithWrongType() throws {
    let object: JSONObject = ["appearsIn": [4, 5, 6]]
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))
    
    XCTAssertThrowsError(try readFieldValue(field, from: object)) { (error) in
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
    let object: JSONObject = ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]]
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))
    
    let value = try readFieldValue(field, from: object) as! [Episode]?
    
    XCTAssertEqual(value!, [.newhope, .empire, .jedi])
  }
  
  func testGetEmptyOptionalScalarList() throws {
    let object: JSONObject = ["appearsIn": []]
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))
    
    let value = try readFieldValue(field, from: object) as! [Episode]
    
    XCTAssertEqual(value, [])
  }
  
  func testGetOptionalScalarListWithMissingKey() throws {
    let object: JSONObject = [:]
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))
    
    XCTAssertThrowsError(try readFieldValue(field, from: object)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetOptionalScalarListWithNull() throws {
    let object: JSONObject = ["appearsIn": NSNull()]
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))
    
    let value = try readFieldValue(field, from: object) as! [Episode]?
    
    XCTAssertNil(value)
  }
  
  func testGetOptionalScalarListWithWrongType() throws {
    let object: JSONObject = ["appearsIn": [4, 5, 6]]
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))
    
    XCTAssertThrowsError(try readFieldValue(field, from: object)) { (error) in
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
    let object: JSONObject = ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]]
    let field = Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self))))
    
    let value = try readFieldValue(field, from: object) as! [Episode?]
    
    XCTAssertEqual(value, [.newhope, .empire, .jedi] as [Episode?])
  }
  
  func testGetOptionalScalarListWithOptionalElements() throws {
    let object: JSONObject = ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]]
    let field = Field("appearsIn", type: .list(.scalar(Episode.self)))
    
    let value = try readFieldValue(field, from: object) as! [Episode?]?
    
    XCTAssertEqual(value, [.newhope, .empire, .jedi] as [Episode?])
  }
}

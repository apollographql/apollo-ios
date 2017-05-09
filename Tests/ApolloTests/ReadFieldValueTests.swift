import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

private struct MockSelectionSet: GraphQLSelectionSet {
  public static let selections: [Selection] = []
  
  public var snapshot: Snapshot
  
  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }
}

private extension GraphQLExecutor {
  convenience init(rootObject: JSONObject) {
    self.init { object, info in
      return Promise(fulfilled: (object ?? rootObject)[info.responseKeyForField])
    }
  }
  
  func readFieldValue(_ field: Field) throws -> Any? {
    return try execute(selections: [field], withKey: "", variables: [:], accumulator: GraphQLSelectionSetMapper<MockSelectionSet>()).await().snapshot[field.responseKey]!
  }
}

class ReadFieldValueTests: XCTestCase {
  func testGetScalar() throws {
    let executor = GraphQLExecutor(rootObject: ["name": "Luke Skywalker"])
    let field = Field("name", type: .nonNull(.scalar(String.self)))
    
    let value = try executor.readFieldValue(field) as! String
    
    XCTAssertEqual(value, "Luke Skywalker")
  }
  
  func testGetScalarWithMissingKey() {
    let executor = GraphQLExecutor(rootObject: [:])
    let field = Field("name", type: .nonNull(.scalar(String.self)))
    
    XCTAssertThrowsError(try executor.readFieldValue(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetScalarWithNull() throws {
    let executor = GraphQLExecutor(rootObject: ["name": NSNull()])
    let field = Field("name", type: .nonNull(.scalar(String.self)))
    
    XCTAssertThrowsError(try executor.readFieldValue(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetScalarWithWrongType() throws {
    let executor = GraphQLExecutor(rootObject: ["name": 10])
    let field = Field("name", type: .nonNull(.scalar(String.self)))
    
    XCTAssertThrowsError(try executor.readFieldValue(field)) { (error) in
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
    let executor = GraphQLExecutor(rootObject: ["name": "Luke Skywalker"])
    let field = Field("name", type: .scalar(String.self))
    
    let value = try executor.readFieldValue(field) as! String?
    XCTAssertEqual(value, "Luke Skywalker")
  }
  
  func testGetOptionalScalarWithMissingKey() throws {
    let executor = GraphQLExecutor(rootObject: [:])
    let field = Field("name", type: .scalar(String.self))
    
    XCTAssertThrowsError(try executor.readFieldValue(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetOptionalScalarWithNull() throws {
    let executor = GraphQLExecutor(rootObject: ["name": NSNull()])
    let field = Field("name", type: .scalar(String.self))
    
    let value = try executor.readFieldValue(field) as! String?
    
    XCTAssertNil(value)
  }
  
  func testGetOptionalScalarWithWrongType() throws {
    let executor = GraphQLExecutor(rootObject: ["name": 10])
    let field = Field("name", type: .scalar(String.self))
    
    XCTAssertThrowsError(try executor.readFieldValue(field)) { (error) in
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
    let executor = GraphQLExecutor(rootObject: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))
    
    let value = try executor.readFieldValue(field) as! [Episode]
    
    XCTAssertEqual(value, [.newhope, .empire, .jedi])
  }
  
  func testGetEmptyScalarList() throws {
    let executor = GraphQLExecutor(rootObject: ["appearsIn": []])
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))
    
    let value = try executor.readFieldValue(field) as! [Episode]
    
    XCTAssertEqual(value, [])
  }
  
  func testGetScalarListWithMissingKey() {
    let executor = GraphQLExecutor(rootObject: [:])
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))
    
    XCTAssertThrowsError(try executor.readFieldValue(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetScalarListWithNull() throws {
    let executor = GraphQLExecutor(rootObject: ["appearsIn": NSNull()])
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))
    
    XCTAssertThrowsError(try executor.readFieldValue(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetScalarListWithWrongType() throws {
    let executor = GraphQLExecutor(rootObject: ["appearsIn": [4, 5, 6]])
    let field = Field("appearsIn", type: .nonNull(.list(.nonNull(.scalar(Episode.self)))))
    
    XCTAssertThrowsError(try executor.readFieldValue(field)) { (error) in
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
    let executor = GraphQLExecutor(rootObject: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))
    
    let value = try executor.readFieldValue(field) as! [Episode]?
    
    XCTAssertEqual(value!, [.newhope, .empire, .jedi])
  }
  
  func testGetEmptyOptionalScalarList() throws {
    let executor = GraphQLExecutor(rootObject: ["appearsIn": []])
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))
    
    let value = try executor.readFieldValue(field) as! [Episode]
    
    XCTAssertEqual(value, [])
  }
  
  func testGetOptionalScalarListWithMissingKey() throws {
    let executor = GraphQLExecutor(rootObject: [:])
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))
    
    XCTAssertThrowsError(try executor.readFieldValue(field)) { (error) in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGetOptionalScalarListWithNull() throws {
    let executor = GraphQLExecutor(rootObject: ["appearsIn": NSNull()])
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))
    
    let value = try executor.readFieldValue(field) as! [Episode]?
    
    XCTAssertNil(value)
  }
  
  func testGetOptionalScalarListWithWrongType() throws {
    let executor = GraphQLExecutor(rootObject: ["appearsIn": [4, 5, 6]])
    let field = Field("appearsIn", type: .list(.nonNull(.scalar(Episode.self))))
    
    XCTAssertThrowsError(try executor.readFieldValue(field)) { (error) in
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
    let executor = GraphQLExecutor(rootObject: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let field = Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self))))
    
    let value = try executor.readFieldValue(field) as! [Episode?]
    
    XCTAssertEqual(value, [.newhope, .empire, .jedi] as [Episode?])
  }
  
  func testGetOptionalScalarListWithOptionalElements() throws {
    let executor = GraphQLExecutor(rootObject: ["appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    let field = Field("appearsIn", type: .list(.scalar(Episode.self)))
    
    let value = try executor.readFieldValue(field) as! [Episode?]?
    
    XCTAssertEqual(value, [.newhope, .empire, .jedi] as [Episode?])
  }
}

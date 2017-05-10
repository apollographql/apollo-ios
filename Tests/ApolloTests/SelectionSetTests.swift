import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class SelectionSetTests: XCTestCase {
  func testFragmentWithTypeSpecificProperty() throws {
    var r2d2 = HeroDetails(__typename: "Droid", name: "R2-D2")
    r2d2.asDroid?.primaryFunction = "Protocol"
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
  }
  
  func testFragmentWithMissingTypeSpecificProperty() throws {
    let r2d2 = HeroDetails(__typename: "Droid", name: "R2-D2")
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    // FIXME: This currently crashes
    // XCTAssertNil(r2d2.asDroid?.primaryFunction)
  }
  
  func testJSONObjectFromFragment() throws {
    let r2d2 = HeroName(__typename: "Droid", name: "R2-D2")
    
    try XCTAssertEqual(try r2d2.jsonObject(), ["__typename": "Droid", "name": "R2-D2"])
  }
  
  func testJSONObjectFromFragmentWithTypeSpecificProperty() throws {
    var r2d2 = HeroDetails(__typename: "Droid", name: "R2-D2")
    r2d2.asDroid?.primaryFunction = "Protocol"
    
    try XCTAssertEqual(try r2d2.jsonObject(), ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Protocol"])
  }
  
  func testJSONObjectFromFragmentWithMissingTypeSpecificProperty() throws {
    let r2d2 = HeroDetails(__typename: "Droid", name: "R2-D2")
    
    try XCTAssertEqual(try r2d2.jsonObject(), ["__typename": "Droid", "name": "R2-D2", "primaryFunction": NSNull()])
  }
  
  func testFragmentFromJSONObject() throws {
    let r2d2 = try HeroName(jsonObject: ["__typename": "Droid", "name": "R2-D2"])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
  }
  
  func testFragmentWithTypeSpecificPropertyFromJSONObject() throws {
    let r2d2 = try HeroDetails(jsonObject: ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Protocol"])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
  }
  
  func testFragmentWithMissingTypeSpecificPropertyFromJSONObject() throws {
    XCTAssertThrowsError(try HeroDetails(jsonObject: ["__typename": "Droid", "name": "R2-D2"])) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["primaryFunction"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
}

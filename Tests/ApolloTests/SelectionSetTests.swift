import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class SelectionSetTests: XCTestCase {
  func testConstructHeroNameFragment() throws {
    let r2d2 = HeroName(__typename: "Droid", name: "R2-D2")
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
  }
  
  func testConstructHeroAppearsInFragment() throws {
    let r2d2 = HeroAppearsIn(__typename: "Droid", appearsIn: [.newhope, .empire, .jedi])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.appearsIn, [.newhope, .empire, .jedi])
  }
  
  func testConstructHeroDetailsFragmentWithTypeSpecificProperty() throws {
    let r2d2 = HeroDetails.makeDroid(name: "R2-D2", primaryFunction: "Protocol")
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
  }
  
  func testConstructHeroDetailsFragmentWithMissingTypeSpecificProperty() throws {
    let r2d2 = HeroDetails.makeDroid(name: "R2-D2")
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertNil(r2d2.asDroid?.primaryFunction)
  }
  
  func testConstructHeroDetailsFragmentWithNullTypeSpecificProperty() throws {
    let r2d2 = HeroDetails.makeDroid(name: "R2-D2", primaryFunction: nil)
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertNil(r2d2.asDroid?.primaryFunction)
  }
  
  func testJSONObjectFromHeroNameFragment() throws {
    let r2d2 = HeroName(__typename: "Droid", name: "R2-D2")
    
    XCTAssertEqual(r2d2.jsonObject, ["__typename": "Droid", "name": "R2-D2"])
  }
  
  func testJSONObjectFromHeroAppearsInFragment() throws {
    let r2d2 = HeroAppearsIn(__typename: "Droid", appearsIn: [.newhope, .empire, .jedi])
    
    XCTAssertEqual(r2d2.jsonObject, ["__typename": "Droid", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
  }
  
  func testJSONObjectFromHeroDetailsFragmentWithTypeSpecificProperty() throws {
    let r2d2 = HeroDetails.makeDroid(name: "R2-D2", primaryFunction: "Protocol")
    
    XCTAssertEqual(r2d2.jsonObject, ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Protocol"])
  }
  
  func testJSONObjectFromHeroDetailsFragmentWithMissingTypeSpecificProperty() throws {
    let r2d2 = HeroDetails.makeDroid(name: "R2-D2")
    
    XCTAssertEqual(r2d2.jsonObject, ["__typename": "Droid", "name": "R2-D2", "primaryFunction": NSNull()])
  }
  
  func testHeroNameFragmentFromJSONObject() throws {
    let r2d2 = try HeroName(jsonObject: ["__typename": "Droid", "name": "R2-D2"])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
  }
  
  func testHeroNameFragmentFromJSONObjectWithMissingName() throws {
    XCTAssertThrowsError(try HeroName(jsonObject: ["__typename": "Droid"])) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testHeroNameFragmentFromJSONObjectWithNullName() throws {
    XCTAssertThrowsError(try HeroName(jsonObject: ["__typename": "Droid", "name": NSNull()])) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testHeroAppearsInFragmentFromJSONObject() throws {
    let r2d2 = try HeroAppearsIn(jsonObject: ["__typename": "Droid", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.appearsIn, [.newhope, .empire, .jedi])
  }
  
  func testHeroDetailsFragmentWithTypeSpecificPropertyFromJSONObject() throws {
    let r2d2 = try HeroDetails(jsonObject: ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Protocol"])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
  }
  
  func testHeroDetailsFragmentWithMissingTypeSpecificPropertyFromJSONObject() throws {
    XCTAssertThrowsError(try HeroDetails(jsonObject: ["__typename": "Droid", "name": "R2-D2"])) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["primaryFunction"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testHeroDetailsFragmentWithNullTypeSpecificPropertyFromJSONObject() throws {
    let r2d2 = try HeroDetails(jsonObject: ["__typename": "Droid", "name": "R2-D2", "primaryFunction": NSNull()])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertNil(r2d2.asDroid?.primaryFunction)
  }
  
  func testConvertHeroNameAndapearsInIntoHeroNameFragment() throws {
    let heroNameAndAppearsIn = HeroNameAndAppearsIn(__typename: "Droid", name: "R2-D2", appearsIn: [.newhope, .empire, .jedi])
    
    let heroName = try HeroName(heroNameAndAppearsIn)
    
    XCTAssertEqual(heroName.__typename, "Droid")
    XCTAssertEqual(heroName.name, "R2-D2")
  }
  
  func testConvertHeroNameIntoHeroNameAndAppearsInFragment() throws {
    let heroName = HeroName(__typename: "Droid", name: "R2-D2")
    
    XCTAssertThrowsError(try HeroDetails(heroName)) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["primaryFunction"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testConvertHeroDetailsIntoHeroNameFragment() throws {
    let heroDetails = HeroDetails.makeDroid(name: "R2-D2", primaryFunction: "Protocol")
    
    let heroName = try HeroName(heroDetails)
    
    XCTAssertEqual(heroName.__typename, "Droid")
    XCTAssertEqual(heroName.name, "R2-D2")
  }
  
  func testConvertHeroNameIntoHeroDetailsFragment() throws {
    let heroName = HeroName(__typename: "Droid", name: "R2-D2")
    
    XCTAssertThrowsError(try HeroDetails(heroName)) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["primaryFunction"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
}

import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class SelectionSetTests: XCTestCase {
  func testFragmentToJSON() throws {
    let heroName = HeroName(__typename: "Human", name: "Luke Skywalker")
    
    try XCTAssertEqual(try heroName.jsonObject(), ["__typename": "Human", "name": "Luke Skywalker"])
  }
  
  func testFragmentFromJSON() throws {
    let heroName = try HeroName(jsonObject: ["__typename": "Human", "name": "Luke Skywalker"])
    
    XCTAssertEqual(heroName.name, "Luke Skywalker")
  }
}

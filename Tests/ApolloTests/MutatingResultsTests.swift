import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class MutatingResultsTests: XCTestCase {
  func testSettingNewFragment() throws {
    var hero = HeroNameWithFragmentAndIdQuery.Data.Hero.makeDroid(id: "2001", name: "R2-D2")
    
    let r2d2 = CharacterName.makeDroid(name: "Artoo")
    
    hero.fragments.characterName = r2d2
    
    XCTAssertEqual(hero.__typename, "Droid")
    XCTAssertEqual(hero.id, "2001")
    XCTAssertEqual(hero.name, "Artoo")
  }
}

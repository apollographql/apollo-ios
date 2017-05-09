import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class NormalizeQueryResults: XCTestCase {
  func testHeroNameQuery() throws {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2"]
      ]
    ])
    
    let (_, records) = try response.parseResult().await()
    
    XCTAssertEqual(records?["QUERY_ROOT"]?["hero"] as? Reference, Reference(key: "QUERY_ROOT.hero"))
    
    guard let hero = records?["QUERY_ROOT.hero"] else { XCTFail(); return }
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
  }
  
  func testHeroNameQueryWithVariable() throws {
    let query = HeroNameQuery(episode: .jedi)
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2"]
      ]
    ])
    
    let (_, records) = try response.parseResult().await()
    
    XCTAssertEqual(records?["QUERY_ROOT"]?["hero(episode:JEDI)"] as? Reference, Reference(key: "QUERY_ROOT.hero(episode:JEDI)"))
    
    guard let hero = records?["QUERY_ROOT.hero(episode:JEDI)"] else { XCTFail(); return }
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
  }
  
  func testHeroAppearsInQuery() throws {
    let query = HeroAppearsInQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]]
      ]
    ])
    
    let (_, records) = try response.parseResult().await()
    
    XCTAssertEqual(records?["QUERY_ROOT"]?["hero"] as? Reference, Reference(key: "QUERY_ROOT.hero"))
    
    guard let hero = records?["QUERY_ROOT.hero"] else { XCTFail(); return }
    XCTAssertEqual(hero["appearsIn"] as? [String], ["NEWHOPE", "EMPIRE", "JEDI"])
  }
  
  func testHeroAndFriendsNamesQueryWithoutIDs() throws {
    let query = HeroAndFriendsNamesQuery(episode: .jedi)
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": [
          "__typename": "Droid",
          "name": "R2-D2",
          "friends": [
            ["__typename": "Human", "name": "Luke Skywalker"],
            ["__typename": "Human", "name": "Han Solo"],
            ["__typename": "Human", "name": "Leia Organa"]
          ]
        ]
      ]
    ])
    
    let (_, records) = try response.parseResult().await()
    
    XCTAssertEqual(records?["QUERY_ROOT"]?["hero(episode:JEDI)"] as? Reference, Reference(key: "QUERY_ROOT.hero(episode:JEDI)"))
    
    guard let hero = records?["QUERY_ROOT.hero(episode:JEDI)"] else { XCTFail(); return }
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
    XCTAssertEqual(hero["friends"] as? [Reference], [Reference(key: "QUERY_ROOT.hero(episode:JEDI).friends.0"), Reference(key: "QUERY_ROOT.hero(episode:JEDI).friends.1"), Reference(key: "QUERY_ROOT.hero(episode:JEDI).friends.2")])
    
    guard let luke = records?["QUERY_ROOT.hero(episode:JEDI).friends.0"] else { XCTFail(); return }
    XCTAssertEqual(luke["name"] as? String, "Luke Skywalker")
  }
  
  func testHeroAndFriendsNamesQueryWithIDs() throws {
    let query = HeroAndFriendsNamesWithIDsQuery(episode: .jedi)
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": [
          "__typename": "Droid",
          "id": "2001",
          "name": "R2-D2",
          "friends": [
            ["__typename": "Human", "id": "1000", "name": "Luke Skywalker"],
            ["__typename": "Human", "id": "1002", "name": "Han Solo"],
            ["__typename": "Human", "id": "1003", "name": "Leia Organa"]
          ]
        ]
      ]
    ])
    
    let (_, records) = try response.parseResult(cacheKeyForObject: { $0["id"] }).await()
    
    XCTAssertEqual(records?["QUERY_ROOT"]?["hero(episode:JEDI)"] as? Reference, Reference(key: "2001"))
    
    guard let hero = records?["2001"] else { XCTFail(); return }
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
    XCTAssertEqual(hero["friends"] as? [Reference], [Reference(key: "1000"), Reference(key: "1002"), Reference(key: "1003")])
    
    guard let luke = records?["1000"] else { XCTFail(); return }
    XCTAssertEqual(luke["name"] as? String, "Luke Skywalker")
  }
  
  func testHeroAndFriendsNamesQueryWithIDForParentOnly() throws {
    let query = HeroAndFriendsNamesWithIdForParentOnlyQuery(episode: .jedi)
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": [
          "__typename": "Droid",
          "id": "2001",
          "name": "R2-D2",
          "friends": [
            ["__typename": "Human", "name": "Luke Skywalker"],
            ["__typename": "Human", "name": "Han Solo"],
            ["__typename": "Human", "name": "Leia Organa"]
          ]
        ]
      ]
    ])
    
    let (_, records) = try response.parseResult(cacheKeyForObject: { $0["id"] }).await()
    
    XCTAssertEqual(records?["QUERY_ROOT"]?["hero(episode:JEDI)"] as? Reference, Reference(key: "2001"))
    
    guard let hero = records?["2001"] else { XCTFail(); return }
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
    XCTAssertEqual(hero["friends"] as? [Reference], [Reference(key: "2001.friends.0"), Reference(key: "2001.friends.1"), Reference(key: "2001.friends.2")])
    
    guard let luke = records?["2001.friends.0"] else { XCTFail(); return }
    XCTAssertEqual(luke["name"] as? String, "Luke Skywalker")
  }
  
  func testSameHeroTwiceQuery() throws {
    let query = SameHeroTwiceQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2"],
        "r2": ["__typename": "Droid", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]]
      ]
    ])
    
    let (_, records) = try response.parseResult().await()
    
    guard let hero = records?["QUERY_ROOT.hero"] else { XCTFail(); return }
    XCTAssertEqual(hero["__typename"] as? String, "Droid")
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
    XCTAssertEqual(hero["appearsIn"] as? [String], ["NEWHOPE", "EMPIRE", "JEDI"])
  }
  
  func testHeroTypeDependentAliasedFieldQueryDroid() throws {
    let query = HeroTypeDependentAliasedFieldQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "property": "Astromech"]
      ]
    ])
    
    let (_, records) = try response.parseResult().await()
    
    guard let hero = records?["QUERY_ROOT.hero"] else { XCTFail(); return }
    XCTAssertEqual(hero["primaryFunction"] as? String, "Astromech")
  }
  
  func testHeroTypeDependentAliasedFieldQueryHuman() throws {
    let query = HeroTypeDependentAliasedFieldQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Human", "property": "Tatooine"]
      ]
    ])
    
    let (_, records) = try response.parseResult().await()
    
    guard let hero = records?["QUERY_ROOT.hero"] else { XCTFail(); return }
    XCTAssertEqual(hero["homePlanet"] as? String, "Tatooine")
  }
  
  func testHeroParentTypeDependentFieldDroid() throws {
    let query = HeroParentTypeDependentFieldQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": [
          "name": "R2-D2",
          "__typename": "Droid",
          "friends": [
            ["__typename": "Human", "name": "Luke Skywalker", "height": 1.72],
          ]
        ]
      ]
    ])
    
    let (_, records) = try response.parseResult().await()
    
    guard let luke = records?["QUERY_ROOT.hero.friends.0"] else { XCTFail(); return }
    XCTAssertEqual(luke["height(unit:METER)"] as? Double, 1.72)
  }
  
  func testHeroParentTypeDependentFieldHuman() throws {
    let query = HeroParentTypeDependentFieldQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": [
          "name": "Luke Skywalker",
          "__typename": "Human",
          "friends": [
            ["__typename": "Human", "name": "Han Solo", "height": 5.905512],
          ]
        ]
      ]
    ])
    
    let (_, records) = try response.parseResult().await()
    
    guard let han = records?["QUERY_ROOT.hero.friends.0"] else { XCTFail(); return }
    XCTAssertEqual(han["height(unit:FOOT)"] as? Double, 5.905512)
  }
}

import XCTest
@testable import Apollo

private extension GraphQLQuery {
  func parse(data: JSONObject) throws -> Data {
    return try Data(map: GraphQLMap(jsonObject: data))
  }
}

class ParseQueryResultDataTests: XCTestCase {
  func testHeroNameQuery() throws {
    let data = ["hero": ["__typename": "Droid", "name": "R2-D2"]]

    let query = HeroNameQuery()
    let result = try query.parse(data: data)

    XCTAssertEqual(result.hero?.name, "R2-D2")
  }

  func testHeroNameQueryWithMissingValue() {
    let data = ["hero": ["__typename": "Droid"]]

    let query = HeroNameQuery()

    XCTAssertThrowsError(try query.parse(data: data)) { error in
      if case JSONDecodingError.missingValue(let key) = error {
        XCTAssertEqual(key, "name")
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testHeroNameQueryWithWrongType() {
    let data = ["hero": ["__typename": "Droid", "name": 10]]

    let query = HeroNameQuery()

    XCTAssertThrowsError(try query.parse(data: data)) { error in
      if case JSONDecodingError.couldNotConvert(let value, let expectedType) = error {
        XCTAssertEqual(value as? Int, 10)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testHeroAndFriendsNamesQuery() throws {
    let data = [
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
         "friends": [
          ["__typename": "Human", "name": "Luke Skywalker"],
          ["__typename": "Human", "name": "Han Solo"],
          ["__typename": "Human", "name": "Leia Organa"]
        ]
      ]
    ]

    let query = HeroAndFriendsNamesQuery(episode: .jedi)
    let result = try query.parse(data: data)

    XCTAssertEqual(result.hero?.name, "R2-D2")
    let friendsNames = result.hero?.friends?.flatMap { $0?.name }
    XCTAssertEqual(friendsNames!, ["Luke Skywalker", "Han Solo", "Leia Organa"])
  }

  func testHeroAppearsInQuery() throws {
    let data = ["hero": ["__typename": "Droid", "name": "R2-D2", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]]]

    let query = HeroAppearsInQuery()
    let result = try query.parse(data: data)

    XCTAssertEqual(result.hero?.name, "R2-D2")
    let episodes = result.hero?.appearsIn.flatMap { $0 }
    XCTAssertEqual(episodes!, [.newhope, .empire, .jedi])
  }

  func testTwoHeroesQuery() throws {
    let data = ["r2": ["__typename": "Droid", "name": "R2-D2"], "luke": ["__typename": "Human", "name": "Luke Skywalker"]]

    let query = TwoHeroesQuery()
    let result = try query.parse(data: data)

    XCTAssertEqual(result.r2?.name, "R2-D2")
    XCTAssertEqual(result.luke?.name, "Luke Skywalker")
  }

  func testHeroDetailsQueryHuman() throws {
    let data = ["hero": ["__typename": "Human", "name": "Luke Skywalker", "height": 1.72]]

    let query = HeroDetailsQuery(episode: .empire)
    let result = try query.parse(data: data)

    guard let human = result.hero?.asHuman else {
      XCTFail("Wrong type")
      return
    }
    XCTAssertEqual(human.height, 1.72)
  }

  func testHeroDetailsQueryDroid() throws {
    let data = ["hero": ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Astromech"]]

    let query = HeroDetailsQuery()
    let result = try query.parse(data: data)

    guard let droid = result.hero?.asDroid else {
      XCTFail("Wrong type")
      return
    }
    XCTAssertEqual(droid.primaryFunction, "Astromech")
  }

  func testHeroDetailsQueryUnknownTypename() throws {
    let data = ["hero": ["__typename": "Pokemon", "name": "Charmander"]]

    let query = HeroDetailsQuery()
    let result = try query.parse(data: data)

    XCTAssertEqual(result.hero?.name, "Charmander")
  }

  func testHeroDetailsQueryMissingTypename() throws {
    let data = ["hero": ["name": "Luke Skywalker", "height": 1.72]]

    let query = HeroDetailsQuery(episode: .empire)

    XCTAssertThrowsError(try query.parse(data: data)) { error in
      if case JSONDecodingError.missingValue(let key) = error {
        XCTAssertEqual(key, "__typename")
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testHeroDetailsFragmentQueryHuman() throws {
    let data = ["hero": ["__typename": "Human", "name": "Luke Skywalker", "height": 1.72]]

    let query = HeroDetailsWithFragmentQuery()
    let result = try query.parse(data: data)

    guard let human = result.hero?.fragments.heroDetails.asHuman else {
      XCTFail("Wrong type")
      return
    }
    XCTAssertEqual(human.height, 1.72)
  }
}

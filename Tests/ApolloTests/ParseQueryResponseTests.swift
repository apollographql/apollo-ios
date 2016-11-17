import XCTest
@testable import Apollo

class ParseQueryResponseTests: XCTestCase {
  static var allTests : [(String, (ParseQueryResponseTests) -> () throws -> Void)] {
    return [
      ("testHeroNameQuery", testHeroNameQuery),
      ("testHeroNameQueryWithMissingValue", testHeroNameQueryWithMissingValue),
      ("testHeroNameQueryWithWrongType", testHeroNameQueryWithWrongType),
      ("testHeroAndFriendsNamesQuery", testHeroAndFriendsNamesQuery),
      ("testHeroAppearsInQuery", testHeroAppearsInQuery),
      ("testTwoHeroesQuery", testTwoHeroesQuery),
      ("testHeroDetailsQueryHuman", testHeroDetailsQueryHuman),
      ("testHeroDetailsQueryDroid", testHeroDetailsQueryDroid),
      ("testHeroDetailsQueryUnknownTypename", testHeroDetailsQueryUnknownTypename),
      ("testHeroDetailsQueryMissingTypename", testHeroDetailsQueryMissingTypename),
      ("testHeroDetailsFragmentQueryHuman", testHeroDetailsFragmentQueryHuman),
    ]
  }
  
  func testHeroNameQuery() throws {
    let query = HeroNameQuery()
    let response = GraphQLResponse(operation: query, rootObject: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2"]
      ]
    ])
    let result = try response.parseResult()

    XCTAssertEqual(result.data?.hero?.name, "R2-D2")
  }

  func testHeroNameQueryWithMissingValue() {
    let query = HeroNameQuery()
    let response = GraphQLResponse(operation: query, rootObject: [
      "data": [
        "hero": ["__typename": "Droid"]
      ]
    ])

    XCTAssertThrowsError(try response.parseResult()) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["hero", "name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testHeroNameQueryWithWrongType() {
    let query = HeroNameQuery()
    let response = GraphQLResponse(operation: query, rootObject: [
      "data": [
        "hero": ["__typename": "Droid", "name": 10]
      ]
    ])

    XCTAssertThrowsError(try response.parseResult()) { error in
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["hero", "name"])
        XCTAssertEqual(value as? Int, 10)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testHeroAndFriendsNamesQuery() throws {
    let query = HeroAndFriendsNamesQuery(episode: .jedi)
    let response = GraphQLResponse(operation: query, rootObject: [
      "data": [
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
    ])
    
    let result = try response.parseResult()

    XCTAssertEqual(result.data?.hero?.name, "R2-D2")
    let friendsNames = result.data?.hero?.friends?.flatMap { $0?.name }
    XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
  }

  func testHeroAppearsInQuery() throws {
    let query = HeroAppearsInQuery()
    let response = GraphQLResponse(operation: query, rootObject: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]]
      ]
    ])

    let result = try response.parseResult()

    XCTAssertEqual(result.data?.hero?.name, "R2-D2")
    XCTAssertEqual(result.data?.hero?.appearsIn, [.newhope, .empire, .jedi])
  }

  func testTwoHeroesQuery() throws {
    let query = TwoHeroesQuery()
    let response = GraphQLResponse(operation: query, rootObject: [
      "data": [
        "r2": ["__typename": "Droid", "name": "R2-D2"],
        "luke": ["__typename": "Human", "name": "Luke Skywalker"]
      ]
    ])

    let result = try response.parseResult()

    XCTAssertEqual(result.data?.r2?.name, "R2-D2")
    XCTAssertEqual(result.data?.luke?.name, "Luke Skywalker")
  }

  func testHeroDetailsQueryHuman() throws {
    let query = HeroDetailsQuery(episode: .empire)
    let response = GraphQLResponse(operation: query, rootObject: [
      "data": [
        "hero": ["__typename": "Human", "name": "Luke Skywalker", "height": 1.72]
      ]
    ])

    let result = try response.parseResult()

    guard let human = result.data?.hero?.asHuman else {
      XCTFail("Wrong type")
      return
    }
    XCTAssertEqual(human.height, 1.72)
  }

  func testHeroDetailsQueryDroid() throws {
    let query = HeroDetailsQuery()
    let response = GraphQLResponse(operation: query, rootObject: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Astromech"]
      ]
    ])
    
    let result = try response.parseResult()

    guard let droid = result.data?.hero?.asDroid else {
      XCTFail("Wrong type")
      return
    }
    XCTAssertEqual(droid.primaryFunction, "Astromech")
  }

  func testHeroDetailsQueryUnknownTypename() throws {
    let query = HeroDetailsQuery()
    let response = GraphQLResponse(operation: query, rootObject: [
      "data": [
        "hero": ["__typename": "Pokemon", "name": "Charmander"]
      ]
    ])

    let result = try response.parseResult()

    XCTAssertEqual(result.data?.hero?.name, "Charmander")
  }

  func testHeroDetailsQueryMissingTypename() throws {
    let query = HeroDetailsQuery(episode: .empire)
    let response = GraphQLResponse(operation: query, rootObject: [
      "data": [
        "hero": ["name": "Luke Skywalker", "height": 1.72]
      ]
    ])

    XCTAssertThrowsError(try response.parseResult()) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["hero", "__typename"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testHeroDetailsFragmentQueryHuman() throws {
    let query = HeroDetailsWithFragmentQuery()
    let response = GraphQLResponse(operation: query, rootObject: [
      "data": [
        "hero": ["__typename": "Human", "name": "Luke Skywalker", "height": 1.72]
      ]
    ])

    let result = try response.parseResult()

    guard let human = result.data?.hero?.fragments.heroDetails.asHuman else {
      XCTFail("Wrong type")
      return
    }
    XCTAssertEqual(human.height, 1.72)
  }
}

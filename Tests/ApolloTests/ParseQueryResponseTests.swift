import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class ParseQueryResponseTests: XCTestCase {
  func testHeroNameQuery() throws {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2"]
      ]
    ])
    
    let (result, _) = try response.parseResult().await()

    XCTAssertEqual(result.data?.hero?.name, "R2-D2")
  }

  func testHeroNameQueryWithMissingValue() {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid"]
      ]
    ])

    XCTAssertThrowsError(try response.parseResult().await()) { error in
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
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "name": 10]
      ]
    ])

    XCTAssertThrowsError(try response.parseResult().await()) { error in
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["hero", "name"])
        XCTAssertEqual(value as? Int, 10)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testHeroAppearsInQuery() throws {
    let query = HeroAppearsInQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]]
      ]
    ])
    
    let (result, _) = try response.parseResult().await()
    
    XCTAssertEqual(result.data?.hero?.appearsIn, [.newhope, .empire, .jedi])
  }
  
  func testHeroAppearsInQueryWithEmptyList() throws {
    let query = HeroAppearsInQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "appearsIn": []]
      ]
      ])
    
    let (result, _) = try response.parseResult().await()
    
    XCTAssertEqual(result.data?.hero?.appearsIn, [])
  }

  func testHeroAndFriendsNamesQuery() throws {
    let query = HeroAndFriendsNamesQuery()
    
    let response = GraphQLResponse(operation: query, body: [
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
    
    let (result, _) = try response.parseResult().await()

    XCTAssertEqual(result.data?.hero?.name, "R2-D2")
    let friendsNames = result.data?.hero?.friends?.flatMap { $0?.name }
    XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
  }
  
  func testHeroAndFriendsNamesQueryWithEmptyList() throws {
    let query = HeroAndFriendsNamesQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": [
          "name": "R2-D2",
          "__typename": "Droid",
          "friends": []
        ]
      ]
      ])
    
    let (result, _) = try response.parseResult().await()
    
    XCTAssertEqual(result.data?.hero?.name, "R2-D2")
    XCTAssertEqual(result.data?.hero?.friends?.isEmpty, true)
  }
  
  func testHeroAndFriendsNamesWithFragmentQuery() throws {
    let query = HeroAndFriendsNamesWithFragmentQuery()
    
    let response = GraphQLResponse(operation: query, body: [
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
    
    let (result, _) = try response.parseResult().await()
    
    XCTAssertEqual(result.data?.hero?.name, "R2-D2")
    let friendsNames = result.data?.hero?.fragments.friendsNames.friends?.flatMap { $0?.name }
    XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
  }

  func testTwoHeroesQuery() throws {
    let query = TwoHeroesQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "r2": ["__typename": "Droid", "name": "R2-D2"],
        "luke": ["__typename": "Human", "name": "Luke Skywalker"]
      ]
    ])

    let (result, _) = try response.parseResult().await()

    XCTAssertEqual(result.data?.r2?.name, "R2-D2")
    XCTAssertEqual(result.data?.luke?.name, "Luke Skywalker")
  }
  
  func testHeroDetailsQueryDroid() throws {
    let query = HeroDetailsQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Astromech"]
      ]
    ])
    
    let (result, _) = try response.parseResult().await()
    
    guard let droid = result.data?.hero?.asDroid else {
      XCTFail("Wrong type")
      return
    }
    
    XCTAssertEqual(droid.primaryFunction, "Astromech")
  }

  func testHeroDetailsQueryHuman() throws {
    let query = HeroDetailsQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Human", "name": "Luke Skywalker", "height": 1.72]
      ]
    ])

    let (result, _) = try response.parseResult().await()

    guard let human = result.data?.hero?.asHuman else {
      XCTFail("Wrong type")
      return
    }
    
    XCTAssertEqual(human.height, 1.72)
  }

  func testHeroDetailsQueryUnknownTypename() throws {
    let query = HeroDetailsQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Pokemon", "name": "Charmander"]
      ]
    ])

    let (result, _) = try response.parseResult().await()

    XCTAssertEqual(result.data?.hero?.name, "Charmander")
  }

  func testHeroDetailsQueryMissingTypename() throws {
    let query = HeroDetailsQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["name": "Luke Skywalker", "height": 1.72]
      ]
    ])

    XCTAssertThrowsError(try response.parseResult().await()) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["hero", "__typename"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testHeroDetailsWithFragmentQueryDroid() throws {
    let query = HeroDetailsWithFragmentQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Astromech"]
      ]
    ])
    
    let (result, _) = try response.parseResult().await()
    
    guard let droid = result.data?.hero?.fragments.heroDetails.asDroid else {
      XCTFail("Wrong type")
      return
    }
    
    XCTAssertEqual(droid.primaryFunction, "Astromech")
  }

  func testHeroDetailsWithFragmentQueryHuman() throws {
    let query = HeroDetailsWithFragmentQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Human", "name": "Luke Skywalker", "height": 1.72]
      ]
    ])

    let (result, _) = try response.parseResult().await()

    guard let human = result.data?.hero?.fragments.heroDetails.asHuman else {
      XCTFail("Wrong type")
      return
    }
    
    XCTAssertEqual(human.height, 1.72)
  }
  
  func testHumanQueryWithNullResult() throws {
    let query = HumanQuery(id: "9999")
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "human": NSNull()
      ]
    ])
    
    let (result, _) = try response.parseResult().await()
    
    XCTAssertNil(result.data?.human)
  }
  
  func testHumanQueryWithMissingResult() throws {
    let query = HumanQuery(id: "9999")
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [:]
    ])
    
    XCTAssertThrowsError(try response.parseResult().await()) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["human"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  // MARK: Mutations
  
  func testCreateReviewForEpisode() throws {
    let mutation = CreateReviewForEpisodeMutation(episode: .jedi, review: ReviewInput(stars: 5, commentary: "This is a great movie!"))
    
    let response = GraphQLResponse(operation: mutation, body: [
      "data": [
        "createReview": [
          "__typename": "Review",
          "stars": 5,
          "commentary": "This is a great movie!"
        ]
      ]
    ])
    
    let (result, _) = try response.parseResult().await()
    
    XCTAssertEqual(result.data?.createReview?.stars, 5)
    XCTAssertEqual(result.data?.createReview?.commentary, "This is a great movie!")
  }
  
  // MARK: - Error responses
  
  func testErrorResponseWithoutLocation() throws {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "errors": [
        [
          "message": "Some error",
        ]
      ]
      ])
    
    let (result, _) = try response.parseResult().await()
    
    XCTAssertNil(result.data)
    XCTAssertEqual(result.errors?.first?.message, "Some error")
    XCTAssertNil(result.errors?.first?.locations)
  }
  
  func testErrorResponseWithLocation() throws {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "errors": [
        [
          "message": "Some error",
          "locations": [
            ["line": 1, "column": 2]
          ]
        ]
      ]
    ])
    
    let (result, _) = try response.parseResult().await()
    
    XCTAssertNil(result.data)
    XCTAssertEqual(result.errors?.first?.message, "Some error")
    XCTAssertEqual(result.errors?.first?.locations?.first?.line, 1)
    XCTAssertEqual(result.errors?.first?.locations?.first?.column, 2)
  }
  
  func testErrorResponseWithCustomError() throws {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "errors": [
        [
          "message": "Some error",
          "userMessage": "Some message"
        ]
      ]
    ])
    
    let (result, _) = try response.parseResult().await()
    
    XCTAssertNil(result.data)
    XCTAssertEqual(result.errors?.first?.message, "Some error")
    XCTAssertEqual(result.errors?.first?["userMessage"] as? String, "Some message")
  }
}

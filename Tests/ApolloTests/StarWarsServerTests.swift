import XCTest
@testable import Apollo

class StarWarsServerTests: XCTestCase {
  static var allTests: [(String, (StarWarsServerTests) -> () throws -> Void)] {
    return [
      ("testHeroNameQuery", testHeroNameQuery),
      ("testHeroAppearsInQuery", testHeroAppearsInQuery),
      ("testHeroAndFriendsNamesQuery", testHeroAndFriendsNamesQuery),
      ("testHeroDetailsQueryDroid", testHeroDetailsQueryDroid),
      ("testHeroDetailsQueryHuman", testHeroDetailsQueryHuman),
      ("testHeroDetailsWithFragmentQueryDroid", testHeroDetailsWithFragmentQueryDroid),
      ("testHeroDetailsWithFragmentQueryHuman", testHeroDetailsWithFragmentQueryHuman),
      ("testHeroTypeDependentAliasedFieldDroid", testHeroTypeDependentAliasedFieldDroid),
      ("testHeroTypeDependentAliasedFieldHuman", testHeroTypeDependentAliasedFieldHuman),
      ("testHeroParentTypeDependentFieldDroid", testHeroParentTypeDependentFieldDroid),
      ("testHeroParentTypeDependentFieldHuman", testHeroParentTypeDependentFieldHuman),
      ("testCreateReviewForEpisode", testCreateReviewForEpisode),
    ]
  }

  var client: ApolloClient!

  override func setUp() {
    super.setUp()

    client = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)
  }

  // MARK: Queries

  func testHeroNameQuery() {
    fetch(query: HeroNameQuery()) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
  }

  func testHeroNameQueryWithVariable() {
    fetch(query: HeroNameQuery(episode: .empire)) { data in
      XCTAssertEqual(data.hero?.name, "Luke Skywalker")
    }
  }

  func testHeroAppearsInQuery() {
    fetch(query: HeroAppearsInQuery()) { data in
      XCTAssertEqual(data.hero?.appearsIn, [.newhope, .empire, .jedi])
    }
  }

  func testHeroAndFriendsNamesQuery() {
    fetch(query: HeroAndFriendsNamesQuery()) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }

  func testHumanWithNullMassQuery() {
    fetch(query: HumanWithNullMassQuery()) { data in
      XCTAssertEqual(data.human?.name, "Wilhuff Tarkin")
      XCTAssertNil(data.human?.mass)
    }
  }

  func testHeroDetailsQueryDroid() {
    fetch(query: HeroDetailsQuery()) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")

      guard let droid = data.hero?.asDroid else {
        XCTFail("Wrong type")
        return
      }

      XCTAssertEqual(droid.primaryFunction, "Astromech")
    }
  }

  func testHeroDetailsQueryHuman() {
    fetch(query: HeroDetailsQuery(episode: .empire)) { data in
      XCTAssertEqual(data.hero?.name, "Luke Skywalker")

      guard let human = data.hero?.asHuman else {
        XCTFail("Wrong type")
        return
      }

      XCTAssertEqual(human.height, 1.72)
    }
  }

  func testHeroDetailsWithFragmentQueryDroid() {
    fetch(query: HeroDetailsWithFragmentQuery()) { data in
      XCTAssertEqual(data.hero?.fragments.heroDetails.name, "R2-D2")

      guard let droid = data.hero?.fragments.heroDetails.asDroid else {
        XCTFail("Wrong type")
        return
      }

      XCTAssertEqual(droid.primaryFunction, "Astromech")
    }
  }

  func testHeroDetailsWithFragmentQueryHuman() {
    fetch(query: HeroDetailsWithFragmentQuery(episode: .empire)) { data in
      XCTAssertEqual(data.hero?.fragments.heroDetails.name, "Luke Skywalker")

      guard let human = data.hero?.fragments.heroDetails.asHuman else {
        XCTFail("Wrong type")
        return
      }

      XCTAssertEqual(human.height, 1.72)
    }
  }

  func testHeroTypeDependentAliasedFieldDroid() {
    fetch(query: HeroTypeDependentAliasedFieldQuery()) { data in
      XCTAssertEqual(data.hero?.asDroid?.property, "Astromech")
      XCTAssertNil(data.hero?.asHuman?.property)
    }
  }

  func testHeroTypeDependentAliasedFieldHuman() {
    fetch(query: HeroTypeDependentAliasedFieldQuery(episode: .empire)) { data in
      XCTAssertEqual(data.hero?.asHuman?.property, "Tatooine")
      XCTAssertNil(data.hero?.asDroid?.property)
    }
  }

  func testHeroParentTypeDependentFieldDroid() {
    fetch(query: HeroParentTypeDependentFieldQuery()) { data in
      XCTAssertEqual(data.hero?.asDroid?.friends?.first??.asHuman?.height, 1.72)
    }
  }

  func testHeroParentTypeDependentFieldHuman() {
    fetch(query: HeroParentTypeDependentFieldQuery(episode: .empire)) { data in
      XCTAssertEqual(data.hero?.asHuman?.friends?.first??.asHuman?.height, 5.905512)
    }
  }
  
  func testStarshipCoordinates() {
    fetch(query: StarshipQuery()) { data in
      XCTAssertEqual(data.starship?.coordinates?[0], [1, 2])
      XCTAssertEqual(data.starship?.coordinates?[1], [3, 4])
    }
  }

  // MARK: Mutations

  func testCreateReviewForEpisode() {
    perform(mutation: CreateReviewForEpisodeMutation(episode: .jedi, review: ReviewInput(stars: 5, commentary: "This is a great movie!"))) { data in
      XCTAssertEqual(data.createReview?.stars, 5)
      XCTAssertEqual(data.createReview?.commentary, "This is a great movie!")
    }
  }

  // MARK: - Helpers

  private func fetch<Query: GraphQLQuery>(query: Query, completionHandler: @escaping (_ data: Query.Data) -> Void) {
    let expectation = self.expectation(description: "Fetching query")

    client.fetch(query: query) { (result, error) in
      defer { expectation.fulfill() }

      if let error = error { XCTFail("Error while fetching query: \(error.localizedDescription)");  return }
      guard let result = result else { XCTFail("No query result");  return }

      if let errors = result.errors {
        XCTFail("Errors in query result: \(errors)")
      }

      guard let data = result.data else { XCTFail("No query result data");  return }

      completionHandler(data)
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  private func perform<Mutation: GraphQLMutation>(mutation: Mutation, completionHandler: @escaping (_ data: Mutation.Data) -> Void) {
    let expectation = self.expectation(description: "Performing mutation")

    client.perform(mutation: mutation) { (result, error) in
      defer { expectation.fulfill() }

      if let error = error { XCTFail("Error while performing mutation: \(error.localizedDescription)");  return }
      guard let result = result else { XCTFail("No mutation result");  return }

      if let errors = result.errors {
        XCTFail("Errors in mutation result: \(errors)")
      }

      guard let data = result.data else { XCTFail("No mutation result data");  return }

      completionHandler(data)
    }

    waitForExpectations(timeout: 1, handler: nil)
  }
}

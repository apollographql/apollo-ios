import XCTest
@testable import Apollo

class StarWarsServerTests: XCTestCase {
  static var allTests : [(String, (StarWarsServerTests) -> () throws -> Void)] {
    return [
      ("testHeroNameQuery", testHeroNameQuery),
      ("testHeroAndFriendsNamesQuery", testHeroAndFriendsNamesQuery),
      ("testHeroAppearsInQuery", testHeroAppearsInQuery),
      ("testHeroDetailsQueryDroid", testHeroDetailsQueryDroid),
      ("testHeroDetailsQueryHuman", testHeroDetailsQueryHuman),
      ("testHeroDetailsFragmentQueryHuman", testHeroDetailsFragmentQueryHuman),
      ("testCreateReviewForEpisode", testCreateReviewForEpisode),
    ]
  }

  var client: ApolloClient!

  override func setUp() {
    super.setUp()

    client = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)
  }

  func testHeroNameQuery() {
    fetch(query: HeroNameQuery()) { (data) in
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
  }
  
  func testHeroNameConditionalInclusionQuery() {
    fetch(query: HeroNameConditionalInclusionQuery(includeName: true)) { (data) in
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
    
    fetch(query: HeroNameConditionalInclusionQuery(includeName: false)) { (data) in
      XCTAssertNil(data.hero?.name)
    }
  }
  
  func testHeroNameConditionalExclusionQuery() {
    fetch(query: HeroNameConditionalExclusionQuery(skipName: true)) { (data) in
      XCTAssertNil(data.hero?.name)
    }
    
    fetch(query: HeroNameConditionalExclusionQuery(skipName: false)) { (data) in
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
  }

  func testHeroAndFriendsNamesQuery() {
    fetch(query: HeroAndFriendsNamesQuery(episode: .jedi)) { (data) in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }

  func testHeroAppearsInQuery() {
    fetch(query: HeroAppearsInQuery()) { (data) in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      XCTAssertEqual(data.hero?.appearsIn, [.newhope, .empire, .jedi])
    }
  }

  func testHumanWithNullHeightQuery() {
    fetch(query: HumanWithNullHeightQuery()) { (data) in
      XCTAssertEqual(data.human?.name, "Wilhuff Tarkin")
      XCTAssertNil(data.human?.mass)
    }
  }

  func testHeroDetailsQueryDroid() {
    fetch(query: HeroDetailsQuery()) { (data) in
      XCTAssertEqual(data.hero?.name, "R2-D2")

      guard let droid = data.hero?.asDroid else {
        XCTFail("Wrong type")
        return
      }
      XCTAssertEqual(droid.primaryFunction, "Astromech")
    }
  }

  func testHeroDetailsQueryHuman() {
    fetch(query: HeroDetailsQuery(episode: .empire)) { (data) in
      XCTAssertEqual(data.hero?.name, "Luke Skywalker")

      guard let human = data.hero?.asHuman else {
        XCTFail("Wrong type")
        return
      }
      XCTAssertEqual(human.height, 1.72)
    }
  }

  func testHeroDetailsFragmentQueryHuman() {
    fetch(query: HeroDetailsWithFragmentQuery(episode: .empire)) { (data) in
      XCTAssertEqual(data.hero?.fragments.heroDetails.name, "Luke Skywalker")

      guard let human = data.hero?.fragments.heroDetails.asHuman else {
        XCTFail("Wrong type")
        return
      }
      XCTAssertEqual(human.height, 1.72)
    }
  }

  func testCreateReviewForEpisode() {
    perform(mutation: CreateReviewForEpisodeMutation(episode: .jedi, review: ReviewInput(stars: 5, commentary: "This is a great movie!"))) { (data) in
      XCTAssertEqual(data.createReview?.stars, 5)
      XCTAssertEqual(data.createReview?.commentary, "This is a great movie!")
    }
  }
  
  func testHeroTypeDependentAliasedFieldDroid() {
    fetch(query: HeroTypeDependentAliasedFieldQuery(episode: .jedi)) { (data) in
      XCTAssertEqual(data.hero?.asDroid?.property, "Astromech")
      XCTAssertNil(data.hero?.asHuman?.property)
    }
  }
  
  func testHeroTypeDependentAliasedFieldHuman() {
    fetch(query: HeroTypeDependentAliasedFieldQuery(episode: .empire)) { (data) in
      XCTAssertEqual(data.hero?.asHuman?.property, "Tatooine")
      XCTAssertNil(data.hero?.asDroid?.property)
    }
  }
  
  func testHeroParentTypeDependentFieldDroid() {
    fetch(query: HeroParentTypeDependentFieldQuery(episode: .jedi)) { (data) in
      XCTAssertEqual(data.hero?.asDroid?.friends?.first??.asHuman?.height?.rounded(), 2)
    }
  }
  
  func testHeroParentTypeDependentFieldHuman() {
    fetch(query: HeroParentTypeDependentFieldQuery(episode: .empire)) { (data) in
      XCTAssertEqual(data.hero?.asHuman?.friends?.first??.asHuman?.height?.rounded(), 6)
    }
  }

  private func fetch<Query: GraphQLQuery>(query: Query, completionHandler: @escaping (_ data: Query.Data) -> Void) {
    let expectation = self.expectation(description: "Fetching query")

    _  = client.fetch(query: query) { (result, error) in
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

    _ = client.perform(mutation: mutation) { (result, error) in
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

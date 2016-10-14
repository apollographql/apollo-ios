import XCTest
@testable import Apollo

class StarWarsServerTests: XCTestCase {
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

  func testHeroAndFriendsNamesQuery() {
    fetch(query: HeroAndFriendsNamesQuery(episode: .jedi)) { (data) in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames!, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }

  func testHeroAppearsInQuery() {
    fetch(query: HeroAppearsInQuery()) { (data) in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let episodes = data.hero?.appearsIn.flatMap { $0 }
      XCTAssertEqual(episodes!, [.newhope, .empire, .jedi])
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
}

import XCTest
import Apollo
import ApolloInternalTestHelpers
@testable import ApolloWebSocket
import StarWarsAPI
import ApolloAPI

class StarWarsWebSocketTests: XCTestCase, CacheDependentTesting {
    
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  static let defaultWaitTimeout: TimeInterval = 5
  
  var cache: NormalizedCache!
  var client: ApolloClient!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
        
    cache = try makeNormalizedCache()
    let store = ApolloStore(cache: cache)
    
    let networkTransport = WebSocketTransport(
      websocket: WebSocket(request: URLRequest(url: TestServerURL.starWarsWebSocket.url),
                           protocol: .graphql_ws),
      store: store
    )
    
    client = ApolloClient(networkTransport: networkTransport, store: store)
  }
  
  override func tearDownWithError() throws {
    cache = nil
    client = nil
    
    try super.tearDownWithError()
  }

  // MARK: Queries

  func testHeroNameQuery() {
    fetch(query: HeroNameQuery(episode: nil)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
  }

  func testHeroNameQueryWithVariable() {
    fetch(query: HeroNameQuery(episode: .init(.EMPIRE))) { data in
      XCTAssertEqual(data.hero?.name, "Luke Skywalker")
    }
  }

  func testHeroAppearsInQuery() {
    fetch(query: HeroAppearsInQuery()) { data in
      XCTAssertEqual(data.hero?.appearsIn, [.init(.NEWHOPE), .init(.EMPIRE), .init(.JEDI)])
    }
  }

  func testHeroAndFriendsNamesQuery() {
    fetch(query: HeroAndFriendsNamesQuery(episode: nil)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }
  
  func testHeroFriendsOfFriendsNamesQuery() {
    fetch(query: HeroFriendsOfFriendsNamesQuery(episode: nil)) { data in
      let friendsOfFirstFriendNames = data.hero?.friends?.first??.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsOfFirstFriendNames, ["Han Solo", "Leia Organa", "C-3PO", "R2-D2"])
    }
  }

  func testHumanQueryWithNullMass() {
    fetch(query: HumanQuery(id: "1004")) { data in
      XCTAssertEqual(data.human?.name, "Wilhuff Tarkin")
      XCTAssertNil(data.human?.mass)
    }
  }
  
  func testHumanQueryWithNullResult() {
    fetch(query: HumanQuery(id: "9999")) { data in
      XCTAssertNil(data.human)
    }
  }

  func testHeroDetailsQueryDroid() {
    fetch(query: HeroDetailsQuery(episode: nil)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")

      guard let droid = data.hero?.asDroid else {
        XCTFail("Wrong type")
        return
      }

      XCTAssertEqual(droid.primaryFunction, "Astromech")
    }
  }

  func testHeroDetailsQueryHuman() {
    fetch(query: HeroDetailsQuery(episode: .init(.EMPIRE))) { data in
      XCTAssertEqual(data.hero?.name, "Luke Skywalker")

      guard let human = data.hero?.asHuman else {
        XCTFail("Wrong type")
        return
      }

      XCTAssertEqual(human.height, 1.72)
    }
  }

  func testHeroDetailsWithFragmentQueryDroid() {
    fetch(query: HeroDetailsWithFragmentQuery(episode: nil)) { data in
      XCTAssertEqual(data.hero?.fragments.heroDetails.name, "R2-D2")

      guard let droid = data.hero?.fragments.heroDetails.asDroid else {
        XCTFail("Wrong type")
        return
      }

      XCTAssertEqual(droid.primaryFunction, "Astromech")
    }
  }

  func testHeroDetailsWithFragmentQueryHuman() {
    fetch(query: HeroDetailsWithFragmentQuery(episode: .init(.EMPIRE))) { data in
      XCTAssertEqual(data.hero?.fragments.heroDetails.name, "Luke Skywalker")

      guard let human = data.hero?.fragments.heroDetails.asHuman else {
        XCTFail("Wrong type")
        return
      }

      XCTAssertEqual(human.height, 1.72)
    }
  }
  
  func testDroidDetailsWithFragmentQueryDroid() {
    fetch(query: DroidDetailsWithFragmentQuery(episode: nil)) { data in
      XCTAssertEqual(data.hero?.asDroid?.name, "R2-D2")
      XCTAssertEqual(data.hero?.asDroid?.primaryFunction, "Astromech")
    }
  }
  
  func testDroidDetailsWithFragmentQueryHuman() {
    fetch(query: DroidDetailsWithFragmentQuery(episode: .init(.EMPIRE))) { data in
      XCTAssertNil(data.hero?.asDroid)
    }
  }


  func testHeroTypeDependentAliasedFieldDroid() {
    fetch(query: HeroTypeDependentAliasedFieldQuery(episode: nil)) { data in
      XCTAssertEqual(data.hero?.asDroid?.property, "Astromech")
      XCTAssertNil(data.hero?.asHuman?.property)
    }
  }

  func testHeroTypeDependentAliasedFieldHuman() {
    fetch(query: HeroTypeDependentAliasedFieldQuery(episode: .init(.EMPIRE))) { data in
      XCTAssertEqual(data.hero?.asHuman?.property, "Tatooine")
      XCTAssertNil(data.hero?.asDroid?.property)
    }
  }

  func testHeroParentTypeDependentFieldDroid() {
    fetch(query: HeroParentTypeDependentFieldQuery(episode: nil)) { data in
      XCTAssertEqual(data.hero?.asDroid?.friends?.first??.asHuman?.height, 1.72)
    }
  }

  func testHeroParentTypeDependentFieldHuman() {
    fetch(query: HeroParentTypeDependentFieldQuery(episode: .init(.EMPIRE))) { data in
      XCTAssertEqual(data.hero?.asHuman?.friends?.first??.asHuman?.height, 5.905512)
    }
  }
  
  func testStarshipCoordinates() {
    fetch(query: StarshipQuery()) { data in
      XCTAssertEqual(data.starship?.coordinates?[0], [1, 2])
      XCTAssertEqual(data.starship?.coordinates?[1], [3, 4])
    }
  }
  
  // MARK: @skip / @include directives
  
  func testHeroNameConditionalExclusion() {
    fetch(query: HeroNameConditionalExclusionQuery(skipName: false)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
    
    fetch(query: HeroNameConditionalExclusionQuery(skipName: true)) { data in
      XCTAssertNil(data.hero?.name)
    }
  }
  
  func testHeroNameConditionalInclusion() {
    fetch(query: HeroNameConditionalInclusionQuery(includeName: true)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
    
    fetch(query: HeroNameConditionalInclusionQuery(includeName: false)) { data in
      XCTAssertNil(data.hero?.name)
    }
  }
  
  func testHeroNameConditionalBoth() {
    fetch(query: HeroNameConditionalBothQuery(skipName: false, includeName: true)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
    
    fetch(query: HeroNameConditionalBothQuery(skipName: true, includeName: true)) { data in
      XCTAssertNil(data.hero?.name)
    }
    
    fetch(query: HeroNameConditionalBothQuery(skipName: false, includeName: false)) { data in
      XCTAssertNil(data.hero?.name)
    }
    
    fetch(query: HeroNameConditionalBothQuery(skipName: true, includeName: false)) { data in
      XCTAssertNil(data.hero?.name)
    }
  }
  
  func testHeroNameConditionalBothSeparate() {
    fetch(query: HeroNameConditionalBothSeparateQuery(skipName: false, includeName: true)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
    
    fetch(query: HeroNameConditionalBothSeparateQuery(skipName: true, includeName: true)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
    
    fetch(query: HeroNameConditionalBothSeparateQuery(skipName: false, includeName: false)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
    
    fetch(query: HeroNameConditionalBothSeparateQuery(skipName: true, includeName: false)) { data in
      XCTAssertNil(data.hero?.name)
    }
  }
  
  func testHeroDetailsInlineConditionalInclusion() {
    fetch(query: HeroDetailsInlineConditionalInclusionQuery(includeDetails: true)) { data in
      XCTAssertEqual(data.hero?.ifIncludeDetails?.name, "R2-D2")
      XCTAssertEqual(data.hero?.ifIncludeDetails?.appearsIn, [.init(.NEWHOPE), .init(.EMPIRE), .init(.JEDI)])
    }
    
    fetch(query: HeroDetailsInlineConditionalInclusionQuery(includeDetails: false)) { data in
      XCTAssertNil(data.hero?.ifIncludeDetails?.name)
      XCTAssertNil(data.hero?.ifIncludeDetails?.appearsIn)
    }
  }
  
  func testHeroDetailsFragmentConditionalInclusion() {
    fetch(query: HeroDetailsFragmentConditionalInclusionQuery(includeDetails: true)) { data in
      XCTAssertEqual(data.hero?.ifIncludeDetails?.name, "R2-D2")
      XCTAssertEqual(data.hero?.ifIncludeDetails?.fragments.heroDetails.asDroid?.primaryFunction, "Astromech")
    }
    
    fetch(query: HeroDetailsFragmentConditionalInclusionQuery(includeDetails: false)) { data in
      XCTAssertNil(data.hero?.ifIncludeDetails?.name)
      XCTAssertNil(data.hero?.ifIncludeDetails?.fragments.heroDetails.asDroid?.primaryFunction)
    }
  }
  
  func testHeroNameTypeSpecificConditionalInclusion() {
    fetch(query: HeroNameTypeSpecificConditionalInclusionQuery(
      episode: nil,
      includeName: true
    )) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      XCTAssertEqual(data.hero?.asDroid?.name, "R2-D2")
    }
    
    fetch(query: HeroNameTypeSpecificConditionalInclusionQuery(
      episode: nil,
      includeName: false
    )) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      XCTAssertEqual(data.hero?.asDroid?.name, "R2-D2")
    }
    
    fetch(query: HeroNameTypeSpecificConditionalInclusionQuery(
      episode: .init(.EMPIRE),
      includeName: true
    )) { data in
      XCTAssertEqual(data.hero?.name, "Luke Skywalker")
    }
    
    fetch(query: HeroNameTypeSpecificConditionalInclusionQuery(
      episode: .init(.EMPIRE),
      includeName: false
    )) { data in
      XCTAssertNil(data.hero?.name)
    }
  }

  // MARK: Mutations

  func testCreateReviewForEpisode() {
    perform(mutation: CreateReviewForEpisodeMutation(
      episode: .init(.JEDI),
      review: ReviewInput(stars: 5, commentary: "This is a great movie!")
    )) { data in
      XCTAssertEqual(data.createReview?.stars, 5)
      XCTAssertEqual(data.createReview?.commentary, "This is a great movie!")
    }
  }

  // MARK: - Helpers
  
  private func fetch<Query: GraphQLQuery>(query: Query, file: StaticString = #filePath, line: UInt = #line, completionHandler: @escaping (_ data: Query.Data) -> Void) {
    let resultObserver = makeResultObserver(for: query, file: file, line: line)
        
    let expectation = resultObserver.expectation(description: "Fetched query from server", file: file, line: line) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .server, file: file, line: line)
        XCTAssertNil(graphQLResult.errors, file: file, line: line)
        
        let data = try XCTUnwrap(graphQLResult.data, file: file, line: line)
        completionHandler(data)
      }
    }
    
    client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, resultHandler: resultObserver.handler)
    
    wait(for: [expectation], timeout: Self.defaultWaitTimeout)
  }
  
  private func perform<Mutation: GraphQLMutation>(mutation: Mutation, file: StaticString = #filePath, line: UInt = #line, completionHandler: @escaping (_ data: Mutation.Data) -> Void) {
    let resultObserver = makeResultObserver(for: mutation, file: file, line: line)
        
    let expectation = resultObserver.expectation(description: "Performing mutation on server", file: file, line: line) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .server, file: file, line: line)
        XCTAssertNil(graphQLResult.errors, file: file, line: line)
        
        let data = try XCTUnwrap(graphQLResult.data, file: file, line: line)
        completionHandler(data)
      }
    }
    
    client.perform(mutation: mutation, resultHandler: resultObserver.handler)
    
    wait(for: [expectation], timeout: Self.defaultWaitTimeout)
  }
}

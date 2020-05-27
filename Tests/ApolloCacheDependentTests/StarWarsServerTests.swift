import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI


protocol TestConfig {
  func network() -> HTTPNetworkTransport
}

class DefaultConfig: TestConfig {
  let transport =  HTTPNetworkTransport(url: URL(string: "http://localhost:8080/graphql")!)
  func network() -> HTTPNetworkTransport {
    return transport
  }
}

class APQsConfig: TestConfig {
  let transport = HTTPNetworkTransport(url: URL(string: "http://localhost:8080/graphql")!,
                                       enableAutoPersistedQueries: true)
  func network() -> HTTPNetworkTransport {
    return transport
  }
}

class APQsWithGetMethodConfig: TestConfig, HTTPNetworkTransportRetryDelegate{
  
  var alreadyRetried = false
  func networkTransport(_ networkTransport: HTTPNetworkTransport, receivedError error: Error, for request: URLRequest, response: URLResponse?, continueHandler: @escaping (HTTPNetworkTransport.ContinueAction) -> Void) {
    continueHandler(!alreadyRetried ? .retry : .fail(error))
    alreadyRetried = true
  }
  
  func network() -> HTTPNetworkTransport {
    let transport = HTTPNetworkTransport(url: URL(string: "http://localhost:8080/graphql")!,
                                enableAutoPersistedQueries: true,
                                useGETForPersistedQueryRetry: true)
    transport.delegate = self
    return transport
  }
  
}

class StarWarsServerAPQsGetMethodTests: StarWarsServerTests {
  override func setUp() {
    super.setUp()
    config = APQsWithGetMethodConfig()
  }
}

class StarWarsServerAPQsTests: StarWarsServerTests {
  override func setUp() {
    super.setUp()
    config = APQsConfig()
  }
}

class StarWarsServerTests: XCTestCase, CacheTesting {
  // MARK: Queries
  var config: TestConfig!

  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  override func setUp() {
    super.setUp()
    config = DefaultConfig()
  }
  
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
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }
  
  func testHeroFriendsOfFriendsNamesQuery() {
    fetch(query: HeroFriendsOfFriendsNamesQuery()) { data in
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
  
  func testDroidDetailsWithFragmentQueryDroid() {
    fetch(query: DroidDetailsWithFragmentQuery()) { data in
      XCTAssertEqual(data.hero?.fragments.droidDetails?.name, "R2-D2")
      XCTAssertEqual(data.hero?.fragments.droidDetails?.primaryFunction, "Astromech")
    }
  }
  
  func testDroidDetailsWithFragmentQueryHuman() {
    fetch(query: DroidDetailsWithFragmentQuery(episode: .empire)) { data in
      XCTAssertNil(data.hero?.fragments.droidDetails)
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
      XCTAssertEqual(data.hero?.name, "R2-D2")
      XCTAssertEqual(data.hero?.appearsIn, [.newhope, .empire, .jedi])
    }
    
    fetch(query: HeroDetailsInlineConditionalInclusionQuery(includeDetails: false)) { data in
      XCTAssertNil(data.hero?.name)
      XCTAssertNil(data.hero?.appearsIn)
    }
  }
  
  func testHeroDetailsFragmentConditionalInclusion() {
    fetch(query: HeroDetailsFragmentConditionalInclusionQuery(includeDetails: true)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      XCTAssertEqual(data.hero?.asDroid?.primaryFunction, "Astromech")
    }
    
    fetch(query: HeroDetailsFragmentConditionalInclusionQuery(includeDetails: false)) { data in
      XCTAssertNil(data.hero?.name)
      XCTAssertNil(data.hero?.asDroid?.primaryFunction)
    }
  }
  
  func testHeroNameTypeSpecificConditionalInclusion() {
    fetch(query: HeroNameTypeSpecificConditionalInclusionQuery(includeName: true)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      XCTAssertEqual(data.hero?.asDroid?.name, "R2-D2")
    }
    
    fetch(query: HeroNameTypeSpecificConditionalInclusionQuery(includeName: false)) { data in
      XCTAssertEqual(data.hero?.name, "R2-D2")
      XCTAssertEqual(data.hero?.asDroid?.name, "R2-D2")
    }
    
    fetch(query: HeroNameTypeSpecificConditionalInclusionQuery(episode: .empire, includeName: true)) { data in
      XCTAssertEqual(data.hero?.name, "Luke Skywalker")
    }
    
    fetch(query: HeroNameTypeSpecificConditionalInclusionQuery(episode: .empire, includeName: false)) { data in
      XCTAssertNil(data.hero?.name)
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
    withCache { (cache) in
      
      let store = ApolloStore(cache: cache)
      let client = ApolloClient(networkTransport: config.network(), store: store)

      let expectation = self.expectation(description: "Fetching query")

      client.fetch(query: query) { result in
        defer { expectation.fulfill() }
      
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          guard let data = graphQLResult.data else {
            XCTFail("No query result data")
            return
          }
          
          completionHandler(data)
        case .failure(let error):
          if let responseError = error as? GraphQLHTTPResponseError {
            XCTFail("Response error: \(responseError.bodyDescription)")
          } else {
            XCTFail("Unexpected error: \(error)")
          }
        }
      }
      
      waitForExpectations(timeout: 5, handler: nil)
    }
  }

  private func perform<Mutation: GraphQLMutation>(mutation: Mutation, completionHandler: @escaping (_ data: Mutation.Data) -> Void) {
    withCache { (cache) in
      
      let store = ApolloStore(cache: cache)
      let client = ApolloClient(networkTransport: config.network(), store: store)

      let expectation = self.expectation(description: "Performing mutation")

      client.perform(mutation: mutation) { result in
        defer { expectation.fulfill() }
        
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          
          guard let data = graphQLResult.data else {
            XCTFail("No mutation result data")
            return
          }
          
          completionHandler(data)
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
      
      waitForExpectations(timeout: 5, handler: nil)
    }
  }
}

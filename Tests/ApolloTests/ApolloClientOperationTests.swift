import Apollo
import ApolloTestSupport
import StarWarsAPI
import XCTest

final class ApolloClientOperationTests: XCTestCase, CacheDependentTesting {
  var cacheType: TestCacheProvider.Type { InMemoryTestCacheProvider.self }

  var defaultWaitTimeout: TimeInterval { 1 }

  var cache: NormalizedCache!
  var server: MockGraphQLServer!
  var client: ApolloClient!

  override func setUpWithError() throws {
    try super.setUpWithError()

    self.cache = try self.makeNormalizedCache()
    let store = ApolloStore(cache: cache)

    self.server = MockGraphQLServer()
    self.client = ApolloClient(
      networkTransport: MockNetworkTransport(server: self.server, store: store),
      store: store
    )
  }

  override func tearDownWithError() throws {
    self.cache = nil
    self.server = nil
    self.client = nil

    try super.tearDownWithError()
  }

  func testPerformMutationRespectsPublishResultToStoreBoolean() throws {
    let mutation = CreateReviewForEpisodeMutation(episode: .newhope, review: .init(stars: 3))
    let resultObserver = self.makeResultObserver(for: mutation)

    let serverRequestExpectation = self.server.expect(CreateReviewForEpisodeMutation.self) { _ in
      [
        "data": [
          "createReview": [
            "__typename": "Review",
            "stars": 3,
            "commentary": ""
          ]
        ]
      ]
    }
    let performResultFromServerExpectation = resultObserver.expectation(description: "Mutation was successful") { _ in }

    self.client.perform(mutation: mutation, publishResultToStore: false, resultHandler: resultObserver.handler)

    self.wait(for: [serverRequestExpectation, performResultFromServerExpectation], timeout: self.defaultWaitTimeout)

    let cacheExpectation = self.expectation(description: "Cache returns nil data for review mutation")
    self.cache.loadRecords(
      forKeys: ["MUTATION_ROOT.createReview(episode:NEWHOPE,[review:stars:3])"],
      callbackQueue: .main,
      completion: { result in
        switch result {
        case let .success(cacheData) where cacheData.allSatisfy({ $0 == nil }):
          cacheExpectation.fulfill()

        default: XCTFail("Expected nil data, instead received result: \(result)")
        }
      }
    )

    self.wait(for: [cacheExpectation], timeout: self.defaultWaitTimeout)
  }
}

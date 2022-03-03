import Apollo
import ApolloTestSupport
import StarWarsAPI
import XCTest

final class ApolloClientOperationTests: XCTestCase, CacheDependentTesting, StoreLoading {
  var cacheType: TestCacheProvider.Type { InMemoryTestCacheProvider.self }

  var cache: NormalizedCache!
  var store: ApolloStore!
  var server: MockGraphQLServer!
  var client: ApolloClient!

  override func setUpWithError() throws {
    try super.setUpWithError()

    self.cache = try self.makeNormalizedCache()
    self.store = ApolloStore(cache: cache)
    self.server = MockGraphQLServer()
    self.client = ApolloClient(
      networkTransport: MockNetworkTransport(server: self.server, store: self.store),
      store: self.store
    )
  }

  override func tearDownWithError() throws {
    self.cache = nil
    self.store = nil
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

    self.loadFromStore(query: mutation) {
      try XCTAssertFailureResult($0) { error in
        switch error as? JSONDecodingError {
        // expected case, nothing to do
        case .missingValue:
          break

        // unexpected error, rethrow
        case .none:
          throw error

        default:
          XCTFail("Unexpected json error: \(error)")
        }
      }
    }

    self.wait(for: [serverRequestExpectation, performResultFromServerExpectation], timeout: Self.defaultWaitTimeout)
  }
}

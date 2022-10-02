import Apollo
import XCTest
import StarWarsAPI

/// Tests that the `DefaultInterceptorProvider` configures an `ApolloClient` that successfully
/// communicates with an external Apollo Server.
///
/// - Precondition: These tests will only pass if a local instance of the Star Wars server is
/// running on port 8080.
/// This server can be found at https://github.com/apollographql/starwars-server
class DefaultInterceptorProviderIntegrationTests: XCTestCase {

  var client: ApolloClient!

  override func setUp() {
    let url = TestServerURL.starWarsServer.url
    let store = ApolloStore()
    let provider = DefaultInterceptorProvider(store: store)
    let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                 endpointURL: url)

    client = ApolloClient(networkTransport: transport, store: store)
  }

  override func tearDown() {
    client = nil
    
    super.tearDown()
  }

  func testLoading() {
    let expectation = self.expectation(description: "loaded with default client")
    client.fetch(query: HeroNameQuery(episode: nil)) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")

      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10)
  }

  func testInitialLoadFromNetworkAndSecondaryLoadFromCache() {
    let initialLoadExpectation = self.expectation(description: "loaded with default client")
    client.fetch(query: HeroNameQuery(episode: nil)) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")

      }
      initialLoadExpectation.fulfill()
    }

    self.wait(for: [initialLoadExpectation], timeout: 10)

    let secondLoadExpectation = self.expectation(description: "loaded with default client")
    client.fetch(query: HeroNameQuery(episode: nil)) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")

      }
      secondLoadExpectation.fulfill()
    }

    self.wait(for: [secondLoadExpectation], timeout: 10)
  }
}

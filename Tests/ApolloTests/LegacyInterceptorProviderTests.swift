import XCTest
import Apollo
import ApolloTestSupport
import StarWarsAPI

class LegacyInterceptorProviderTests: XCTestCase {

  var client: ApolloClient!
  var mockServer: MockGraphQLServer!

  static let mockData: JSONObject = [
    "data": [
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid"
      ]
    ]
  ]

  override func setUp() {
    mockServer = MockGraphQLServer()
    let store = ApolloStore()
    let networkTransport = MockNetworkTransport(server: mockServer, store: store)
    client = ApolloClient(networkTransport: networkTransport, store: store)
  }

  override func tearDown() {
    client = nil
    mockServer = nil
    
    super.tearDown()
  }

  func testLoading() {
    let expectation = mockServer.expect(HeroNameQuery.self) { _ in
      LegacyInterceptorProviderTests.mockData
    }

    client.fetch(query: HeroNameQuery()) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
    }

    self.wait(for: [expectation], timeout: 10)
  }

  func testInitialLoadFromNetworkAndSecondaryLoadFromCache() {
    let initialLoadExpectation = mockServer.expect(HeroNameQuery.self) { _ in
      LegacyInterceptorProviderTests.mockData
    }
    initialLoadExpectation.assertForOverFulfill = false

    client.fetch(query: HeroNameQuery()) { result in
      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
    }

    self.wait(for: [initialLoadExpectation], timeout: 10)

    let secondLoadExpectation = self.expectation(description: "loaded With legacy client")

    client.fetch(query: HeroNameQuery()) { result in
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

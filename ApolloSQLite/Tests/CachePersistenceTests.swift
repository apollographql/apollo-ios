import XCTest
@testable import Apollo
import StarWarsAPI

class CachePersistenceTests: XCTestCase {

  func testFetchAndPersist() {
    let query = HeroNameQuery()
    let sqliteFileURL = TestCacheProvider.temporarySQLiteFileURL()

    TestCacheProvider.withCache(fileURL: sqliteFileURL) { (cache) in
      let store = ApolloStore(cache: cache)
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "name": "Luke Skywalker",
            "__typename": "Human"
          ]
        ]
        ])
      let client = ApolloClient(networkTransport: networkTransport, store: store)

      let networkExpectation = self.expectation(description: "Fetching query from network")
      let newCacheExpectation = self.expectation(description: "Fetch query from new cache")

      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { (result, error) in
        defer { networkExpectation.fulfill() }
        guard let result = result else { XCTFail("No query result");  return }
        XCTAssertEqual(result.data?.hero?.name, "Luke Skywalker")

        // Do another fetch from cache to ensure that data is cached before creating new cache
        client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { (result, error) in
          TestCacheProvider.withCache(fileURL: sqliteFileURL) { (cache) in
            let newStore = ApolloStore(cache: cache)
            let newClient = ApolloClient(networkTransport: networkTransport, store: newStore)
            newClient.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { (result, error) in
              defer { newCacheExpectation.fulfill() }
              guard let result = result else { XCTFail("No query result");  return }
              XCTAssertEqual(result.data?.hero?.name, "Luke Skywalker")
              _ = newClient // Workaround for a bug - ensure that newClient is retained until this block is run
            }
          }
        }
      }
      self.waitForExpectations(timeout: 2, handler: nil)
    }
  }
}

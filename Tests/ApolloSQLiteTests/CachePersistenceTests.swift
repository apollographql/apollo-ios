import XCTest
@testable import Apollo
@testable import ApolloSQLite
import ApolloTestSupport
import ApolloSQLiteTestSupport
import StarWarsAPI

class CachePersistenceTests: XCTestCase {

  func testFetchAndPersist() {
    let query = HeroNameQuery()
    let sqliteFileURL = SQLiteTestCacheProvider.temporarySQLiteFileURL()

    SQLiteTestCacheProvider.withCache(fileURL: sqliteFileURL) { (cache) in
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
          SQLiteTestCacheProvider.withCache(fileURL: sqliteFileURL) { (cache) in
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

  func testClearCache() {
    let query = HeroNameQuery()
    let sqliteFileURL = SQLiteTestCacheProvider.temporarySQLiteFileURL()

    SQLiteTestCacheProvider.withCache(fileURL: sqliteFileURL) { (cache) in
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
      let emptyCacheExpectation = self.expectation(description: "Fetch query from empty cache")
    
      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { (result, error) in
        defer { networkExpectation.fulfill() }
        guard let result = result else { XCTFail("No query result");  return }
        XCTAssertEqual(result.data?.hero?.name, "Luke Skywalker")

        do { try client.clearCache().await() }
        catch { XCTFail() }

        client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { (result, error) in
          defer { emptyCacheExpectation.fulfill() }
          XCTAssertNil(result)
          XCTAssertNil(error)
        }
      }

      self.waitForExpectations(timeout: 2, handler: nil)
    }
  }
  
  func testDeleteSingleWithKey() {
    let query = HeroAndFriendsNamesWithIDsQuery()
    let sqliteFileURL = SQLiteTestCacheProvider.temporarySQLiteFileURL()
    
    SQLiteTestCacheProvider.withCache(fileURL: sqliteFileURL) { (cache) in
      let store = ApolloStore(cache: cache)
      
      let networkTransport = MockNetworkTransport(body: [
        "data": [
          "hero": [
            "id": "2001",
            "name": "R2-D2",
            "__typename": "Droid",
            "friends": [
              ["id": "1000", "name": "Luke Skywalker", "__typename": "Human"],
              ["id": "1002", "name": "Han Solo", "__typename": "Human"],
              ["id": "1003", "name": "Leia Organa", "__typename": "Human"]
            ]
          ]
        ]
        ])
      let client = ApolloClient(networkTransport: networkTransport, store: store)
      client.cacheKeyForObject = { $0["id"] }
      
      let notifyWatcherExpectation = self.expectation(description: "Watcher notified of deleted item")

      let watcher = GraphQLQueryWatcher<HeroAndFriendsNamesWithIDsQuery>(client: client, query: query, handlerQueue: DispatchQueue.main) { result, error in
        guard let result = result else { XCTFail("No query result");  return }
        XCTAssertEqual(result.data?.hero?.name, "R2-D2")
        
        
        if let friendNames = result.data?.hero?.friends?.compactMap({ $0?.name }), !friendNames.contains { $0 == "Luke Skywalker" } {
          notifyWatcherExpectation.fulfill()
        }
        
        DispatchQueue.main.async {
          do {
            try client.store.withinReadWriteTransaction { transaction in
              return transaction.delete(withId: "1000")
              }.await()
          } catch {
            XCTAssertFalse(true, "delete threw expection")
          }
        }
        
      }
      
      watcher.fetch(cachePolicy: CachePolicy.fetchIgnoringCacheData)

      self.waitForExpectations(timeout: 2, handler: nil)
    }
  }

}

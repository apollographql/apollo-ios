import XCTest
@testable import Apollo
@testable import ApolloSQLite
import ApolloTestSupport
import ApolloSQLiteTestSupport
import StarWarsAPI
import SQLite

class CachePersistenceTests: XCTestCase {

  func testDatabaseSetup() throws {
    // Create a database with a state corresponding to the first schema version.
    let sqliteFileURL = SQLiteTestCacheProvider.temporarySQLiteFileURL()
    let db = try Connection(.uri(sqliteFileURL.absoluteString), readonly: false)
    try db.run("""
    CREATE TABLE IF NOT EXISTS "records" ("_id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "key" TEXT NOT NULL UNIQUE, "record" TEXT NOT NULL)
    """)
    try db.run("""
    CREATE UNIQUE INDEX IF NOT EXISTS "index_records_on_key" ON "records" ("key")
    """)

    // Add en entry
    try db.run("""
    INSERT OR REPLACE INTO "records" ("key", "record") VALUES ("QUERY_ROOT.hero", "{""name"":""Luke Skywalker"",""__typename"":""Human""}")
    """)

    // Creates a new database, which will run all migrations
    try SQLiteTestCacheProvider.withCache(fileURL: sqliteFileURL) { (cache) in
      guard let sqlCache = cache as? SQLiteNormalizedCache else {
        XCTFail("The cache is not using SQLite")
        return
      }
      let version = try sqlCache.readSchemaVersion()
      XCTAssertEqual(version, 1)
    }

    // Inserts some entries in the database
    testFetchAndPersist()
  }

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

      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { outerResult in
        defer { networkExpectation.fulfill() }
        
        switch outerResult {
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
          return
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
          // Do another fetch from cache to ensure that data is cached before creating new cache
          client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { innerResult in
            SQLiteTestCacheProvider.withCache(fileURL: sqliteFileURL) { cache in
              let newStore = ApolloStore(cache: cache)
              let newClient = ApolloClient(networkTransport: networkTransport, store: newStore)
              newClient.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { newClientResult in
                defer { newCacheExpectation.fulfill() }
                switch newClientResult {
                case .success(let newClientGraphQLResult):
                  XCTAssertEqual(newClientGraphQLResult.data?.hero?.name, "Luke Skywalker")
                case .failure(let error):
                  XCTFail("Unexpected error with new client: \(error)")
                }
                _ = newClient // Workaround for a bug - ensure that newClient is retained until this block is run
              }
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
      let cacheClearExpectation = self.expectation(description: "cache cleared")

      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { outerResult in
        defer { networkExpectation.fulfill() }
        
        switch outerResult {
        case .failure(let error):
          XCTFail("Unexpected faillure: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
        }
        
        client.clearCache(completion: { result in
          switch result {
          case .success:
            break
          case .failure(let error):
            XCTFail("Error clearing cache: \(error)")
          }
          cacheClearExpectation.fulfill()
        })

        client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { innerResult in
          defer { emptyCacheExpectation.fulfill() }
          
          switch innerResult {
          case .success:
            XCTFail("This should have returned an error")
          case .failure(let error):
            if let resultError = error as? JSONDecodingError {
              switch resultError {
              case .missingValue:
                // Correct error!
                break
              default:
                XCTFail("Unexpected JSON error: \(error)")
              }
            } else {
              XCTFail("Unexpected error: \(error)")
            }
          }
        }
      }

      self.waitForExpectations(timeout: 2, handler: nil)
    }
  }
}

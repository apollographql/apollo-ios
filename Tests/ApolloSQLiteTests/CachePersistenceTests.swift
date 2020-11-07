import XCTest
@testable import Apollo
@testable import ApolloSQLite
import ApolloTestSupport
import ApolloSQLiteTestSupport
import StarWarsAPI
import SQLite

class CachePersistenceTests: XCTestCase {

  func testDatabaseSetup() throws {
    // loop through each of the database snapshots to run through migrations
    // if a migration fails, then it will throw an error
    // we verify the migration is successful by comparing the iteration to the schema version (assigned after the migration)
    let testBundle = Bundle(for: Self.self)
    try testBundle.paths(forResourcesOfType: "sqlite3", inDirectory: nil)
      .sorted() // make sure they run in order
      .map(URL.init(fileURLWithPath:))
      .enumerated()
      .forEach { previousSchemaVersion, fileURL in
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
          XCTFail("expected snapshot file '\(fileURL.lastPathComponent)' could not be found")
          return
        }

        // open a connection to the snapshot that is expected to be migrated to the next version
        try SQLiteTestCacheProvider.withCache(fileURL: fileURL) { cache in
          guard let sqlCache = cache as? SQLiteNormalizedCache else {
            XCTFail("The cache is not using SQLite")
            return
          }

          // verify that the current schema version is now incremented from the snapshot
          let schemaVersion = try sqlCache.readSchemaVersion()
          XCTAssertEqual(schemaVersion, Int64(previousSchemaVersion + 1))

          // inserts some entries in the database to verify the file is useable after the migration
          runTestFetchAndPersist(againstFileAt: fileURL)
        }
      }
  }

  func testFetchAndPersist() {
    self.runTestFetchAndPersist(againstFileAt: SQLiteTestCacheProvider.temporarySQLiteFileURL())
  }

  func testPassInConnectionDoesNotThrow() {
    XCTAssertNoThrow(try SQLiteNormalizedCache(db: Connection()))
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
      ], store: store)
      let client = ApolloClient(networkTransport: networkTransport, store: store)

      let networkExpectation = self.expectation(description: "Fetching query from network")
      let emptyCacheExpectation = self.expectation(description: "Fetch query from empty cache")
      let cacheClearExpectation = self.expectation(description: "cache cleared")

      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { outerResult in
        defer { networkExpectation.fulfill() }
        
        switch outerResult {
        case .failure(let error):
          XCTFail("Unexpected failure: \(error)")
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

extension CachePersistenceTests {
  private func runTestFetchAndPersist(
    againstFileAt sqliteFileURL: URL,
    file: StaticString = #file,
    line: UInt = #line
  ) {
      let query = HeroNameQuery()

      SQLiteTestCacheProvider.withCache(fileURL: sqliteFileURL) { (cache) in
        let store = ApolloStore(cache: cache)
        let networkTransport = MockNetworkTransport(body: [
          "data": [
            "hero": [
              "name": "Luke Skywalker",
              "__typename": "Human"
            ]
          ]
        ], store: store)
        let client = ApolloClient(networkTransport: networkTransport, store: store)

        let networkExpectation = self.expectation(description: "Fetching query from network")
        let newCacheExpectation = self.expectation(description: "Fetch query from new cache")

        client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { outerResult in
          defer { networkExpectation.fulfill() }

          switch outerResult {
          case .failure(let error):
            XCTFail("Unexpected error: \(error)", file: file, line: line)
            return
          case .success(let graphQLResult):
            XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker", file: file, line: line)
            // Do another fetch from cache to ensure that data is cached before creating new cache
            client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { innerResult in
              SQLiteTestCacheProvider.withCache(fileURL: sqliteFileURL) { cache in
                let newStore = ApolloStore(cache: cache)
                let newClient = ApolloClient(networkTransport: networkTransport, store: newStore)
                newClient.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { newClientResult in
                  defer { newCacheExpectation.fulfill() }
                  switch newClientResult {
                  case .success(let newClientGraphQLResult):
                    XCTAssertEqual(newClientGraphQLResult.data?.hero?.name, "Luke Skywalker", file: file, line: line)
                  case .failure(let error):
                    XCTFail("Unexpected error with new client: \(error)", file: file, line: line)
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
}

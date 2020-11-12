import XCTest
@testable import Apollo
@testable import ApolloSQLite
import ApolloTestSupport
import ApolloSQLiteTestSupport
import StarWarsAPI
import SQLite

class CachePersistenceTests: XCTestCase {

  func testFetchAndPersist() {
    let query = HeroNameQuery()
    let sqliteFileURL = SQLiteTestCacheProvider.temporarySQLiteFileURL()

    SQLiteTestCacheProvider.withCache(fileURL: sqliteFileURL) { (cache) in
      let store = ApolloStore(cache: cache)
      
      let server = MockGraphQLServer()
      let networkTransport = MockNetworkTransport(server: server, store: store)
      
      let client = ApolloClient(networkTransport: networkTransport, store: store)
      
      _ = server.expect(HeroNameQuery.self) { request in
        [
          "data": [
            "hero": [
              "name": "Luke Skywalker",
              "__typename": "Human"
            ]
          ]
        ]
      }

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

  func testPassInConnectionDoesNotThrow() {
    XCTAssertNoThrow(try SQLiteNormalizedCache(db: Connection()))
  }
}

// MARK: Cache clearing

extension CachePersistenceTests {
  func testClearMatchingKeyPattern() {
    self.testCacheClearing(withPolicy: .allMatchingKeyPattern("*hero*")) {
      guard let error = $0 as? GraphQLResultError else { return XCTFail("Unexpected error \($0)") }
      switch error.underlying as? JSONDecodingError {
      // nothing to do, this is what we expected
      case .missingValue: break

      default:
        XCTFail("Unexpected JSON error: \(error)")
      }
    }
  }

  func testClearAllRecords() {
    self.testCacheClearing(withPolicy: .allRecords) { error in
      switch error as? JSONDecodingError {
      // nothing to do, this is what we expected
      case .missingValue: break

      default:
        XCTFail("Unexpected error \(error)")
      }
    }
  }

  private func testCacheClearing(
    withPolicy policy: CacheClearingPolicy,
    validateError: @escaping (Error) -> Void,
    file: StaticString = #filePath, line: UInt = #line
  ) {
    let query = TwoHeroesQuery()
    let sqliteFileURL = SQLiteTestCacheProvider.temporarySQLiteFileURL()

    SQLiteTestCacheProvider.withCache(fileURL: sqliteFileURL) { (cache) in
      let store = ApolloStore(cache: cache)
      
      let server = MockGraphQLServer()
      let networkTransport = MockNetworkTransport(server: server, store: store)
      
      let client = ApolloClient(networkTransport: networkTransport, store: store)
      
      _ = server.expect(TwoHeroesQuery.self) { _ in
        [
          "data": [
            "luke": ["name": "Luke Skywalker", "__typename": "Human"],
            "r2": ["name": "R2-D2", "__typename": "Droid"]
          ]
        ]
      }

      let networkExpectation = self.expectation(description: "Fetching query from network")
      let emptyCacheExpectation = self.expectation(description: "Fetch query from empty cache")
      let cacheClearExpectation = self.expectation(description: "cache cleared")

      // load the cache for the test
      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { initialResult in
        defer { networkExpectation.fulfill() }

        // sanity check that the test is ready
        do {
          let data = try initialResult.get().data
          XCTAssertEqual(data?.luke?.name, "Luke Skywalker", file: file, line: line)
        } catch {
          XCTFail("Unexpected failure: \(error)", file: file, line: line)
          return
        }

        // clear the cache as specified for the test
        client.clearCache(usingPolicy: policy) { result in
          defer { cacheClearExpectation.fulfill() }

          switch result {
          case .success: break

          case let .failure(error):
            XCTFail("Error clearing cache: \(error)", file: file, line: line)
          }
        }

        // validate the test
        client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { finalResult in
          defer { emptyCacheExpectation.fulfill() }

          do {
            _ = try finalResult.get()
            XCTFail("This should have returned an error", file: file, line: line)
          } catch {
            validateError(error)
          }
        }
      }

      self.waitForExpectations(timeout: 2)
    }
  }
}

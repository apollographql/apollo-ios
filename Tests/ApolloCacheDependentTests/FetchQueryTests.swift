import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class FetchQueryTests: XCTestCase, CacheTesting {
  
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  func testFetchIgnoringCacheData() throws {
    let query = HeroNameQuery()
    
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { cache in
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
      
      let expectation = self.expectation(description: "Fetching query")
      
      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
        defer { expectation.fulfill() }
        
        switch result {
        case .success(let queryResult):
          XCTAssertEqual(queryResult.data?.hero?.name, "Luke Skywalker")
        case .failure(let error):
          XCTFail("Error: \(error)")
        }
      }
      
      self.waitForExpectations(timeout: 5, handler: nil)
    }
  }
  
  func testReturnCacheDataAndFetch() throws {
    let query = HeroNameQuery()
    
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { cache in
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
      
      let expectation = self.expectation(description: "Fetching query")
      
      client.fetch(query: query, cachePolicy: .returnCacheDataAndFetch) { result in
        
        switch result {
        case .success(let queryResult):
          if queryResult.data?.hero?.name == "R2-D2" {
            // ignore first result assuming from cache, and wait for second callback with fetched result
            return
          } else {
            XCTAssertEqual(queryResult.data?.hero?.name, "Luke Skywalker")
            expectation.fulfill()
          }
        case .failure(let error):
          XCTFail("Error: \(error)")
          expectation.fulfill()
        }
      }
      
      self.waitForExpectations(timeout: 5, handler: nil)
    }
  }
  
  func testReturnCacheDataElseFetchWithCachedData() throws {
    let query = HeroNameQuery()
    
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { (cache) in
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
      
      let expectation = self.expectation(description: "Fetching query")
      
      client.fetch(query: query, cachePolicy: .returnCacheDataElseFetch) { result in
        defer { expectation.fulfill() }
        
        switch result {
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
      
      self.waitForExpectations(timeout: 5, handler: nil)
    }
  }
  
  func testReturnCacheDataElseFetchWithMissingData() throws {
    let query = HeroNameQuery()
    
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { (cache) in
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
      
      let expectation = self.expectation(description: "Fetching query")
      
      client.fetch(query: query, cachePolicy: .returnCacheDataElseFetch) { result in
        defer { expectation.fulfill() }
        
        switch result {
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
      
      self.waitForExpectations(timeout: 5, handler: nil)
    }
  }
  
  func testReturnCacheDataDontFetchWithCachedData() throws {
    let query = HeroNameQuery()
    
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { (cache) in
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
      
      let expectation = self.expectation(description: "Fetching query")
      
      client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { result in
        defer { expectation.fulfill() }
        
        switch result {
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
      
      self.waitForExpectations(timeout: 5, handler: nil)
    }
  }
  
  func testClearCache() throws {
    let query = HeroNameQuery()
    
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { (cache) in
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
      
      let expectation = self.expectation(description: "Fetching query")
      
      client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { result in
        defer { expectation.fulfill() }
        
        switch result {
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
      
      self.waitForExpectations(timeout: 5, handler: nil)
      
      let clearCacheExpectation = self.expectation(description: "cache cleared")
      client.clearCache(completion: { result in
        switch result {
        case .success:
          break
        case .failure(let error):
          XCTFail("Error clearing cache: \(error)")
        }
        
        clearCacheExpectation.fulfill()
      })
      
      self.waitForExpectations(timeout: 1, handler: nil)
      
      let expectation2 = self.expectation(description: "Fetching query")
      
      client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { result in
        defer { expectation2.fulfill() }
        switch result {
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
      
      self.waitForExpectations(timeout: 5, handler: nil)
    }
  }
  
  func testReturnCacheDataDontFetchWithMissingData() throws {
    let query = HeroNameQuery()
    
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { (cache) in
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
      
      let expectation = self.expectation(description: "Fetching query")
      
      client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { result in
        defer { expectation.fulfill() }
        switch result {
        case .success:
          XCTFail("This should have returned an error!")
        case .failure(let error):
          if
            let resultError = error as? GraphQLResultError,
            let underlyingError = resultError.underlying as? JSONDecodingError {
            switch underlyingError {
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
      
      self.waitForExpectations(timeout: 5, handler: nil)
    }
  }
  
  func testCompletionHandlerIsCalledOnTheSpecifiedQueue() {
    let queue = DispatchQueue(label: "label")
    
    let key = DispatchSpecificKey<Void>()
    queue.setSpecific(key: key, value: ())
    
    let query = HeroNameQuery()
    
    let networkTransport = MockNetworkTransport(body: [
      "data": [
        "hero": [
          "name": "Luke Skywalker",
          "__typename": "Human"
        ]
      ]
      ])
    
    withCache { (cache) in
      let store = ApolloStore(cache: cache)
      let client = ApolloClient(networkTransport: networkTransport, store: store)
      
      let expectation = self.expectation(description: "Fetching query")
      
      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, queue: queue) { _ in
        defer { expectation.fulfill() }
        
        XCTAssertNotNil(DispatchQueue.getSpecific(key: key))
      }
      
      waitForExpectations(timeout: 5, handler: nil)
    }
  }
  
  func testThreadedCache() throws {
    let cache = InMemoryNormalizedCache()
    
    let networkTransport1 = MockNetworkTransport(body: [
      "data": [
        "hero": [
          "id": "1000",
          "name": "Luke Skywalker",
          "__typename": "Human",
          "friends": [
            ["__typename": "Human", "name": "Leia Organa", "id": "1003"],
            ["__typename": "Human", "name": "Han Solo", "id": "1002"],
          ]
        ]
      ]
    ])
    
    let networkTransport2 = MockNetworkTransport(body: [
      "data": [
        "hero": [
          "id": "1002",
          "name": "Han Solo",
          "__typename": "Human",
          "friends": [
            ["__typename": "Human", "name": "Leia Organa", "id": "1003"],
            ["__typename": "Human", "name": "Luke Skywalker", "id": "1000"],
          ]
        ]
      ]
    ])
    
    let store = ApolloStore(cache: cache)
    let store2 = ApolloStore(cache: cache)
    
    let client1 = ApolloClient(networkTransport: networkTransport1, store: store)
    let client2 = ApolloClient(networkTransport: networkTransport2, store: store2)
    
    let group = DispatchGroup()
    
    let watcherQueue = DispatchQueue(label: "test watcher queue")
    var watchers = [GraphQLQueryWatcher<HeroAndFriendsNamesWithIDsQuery>]()
    
    for _ in 0...1000 {
      
      group.enter()
      DispatchQueue.global().async {
        let watcher =
          client1.watch(
          query: HeroAndFriendsNamesWithIDsQuery(), cachePolicy: .returnCacheDataAndFetch) { result in
            if result.apollo.value?.source == .some(.server) {
              group.leave()
            }
        }
        
        watcherQueue.sync {
          watchers.append(watcher)
        }
      }
      
      group.enter()
      DispatchQueue.global().async {
        let watcher =
          client2.watch(
          query: HeroAndFriendsNamesWithIDsQuery(), cachePolicy: .returnCacheDataAndFetch) { result in
            if result.apollo.value?.source == .some(.server) {
              group.leave()
            }
        }
        
        watcherQueue.sync {
          watchers.append(watcher)
        }
      }
      
      group.enter()
      DispatchQueue.global().async {
        _ = client1.clearCache() { _ in
          group.leave()
        }
      }
      
    }
    
    let expectation = self.expectation(description: "Fetching query")
    group.notify(queue: .main) {
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 10)
    
    for watcher in watchers {
      watcher.cancel()
    }
  }
}

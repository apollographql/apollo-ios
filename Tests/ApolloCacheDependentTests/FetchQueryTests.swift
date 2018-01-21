import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class FetchQueryTests: XCTestCase {
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

      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { (result, error) in
        defer { expectation.fulfill() }

        guard let result = result else { XCTFail("No query result");  return }

        XCTAssertEqual(result.data?.hero?.name, "Luke Skywalker")
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
      
      client.fetch(query: query, cachePolicy: .returnCacheDataAndFetch) { (result, error) in
        // ignore first result assuming from cache, and then make sure we get fetched result
        if result?.data?.hero?.name != "R2-D2" {
          defer { expectation.fulfill() }
          
          guard let result = result else { XCTFail("No query result");  return }
          
          XCTAssertEqual(result.data?.hero?.name, "Luke Skywalker")
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

      client.fetch(query: query, cachePolicy: .returnCacheDataElseFetch) { (result, error) in
        defer { expectation.fulfill() }

        guard let result = result else { XCTFail("No query result");  return }

        XCTAssertEqual(result.data?.hero?.name, "R2-D2")
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

      client.fetch(query: query, cachePolicy: .returnCacheDataElseFetch) { (result, error) in
        defer { expectation.fulfill() }

        guard let result = result else { XCTFail("No query result");  return }

        XCTAssertEqual(result.data?.hero?.name, "Luke Skywalker")
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

      client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { (result, error) in
        defer { expectation.fulfill() }

        guard let result = result else { XCTFail("No query result");  return }

        XCTAssertEqual(result.data?.hero?.name, "R2-D2")
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

        client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { (result, error) in
          defer { expectation.fulfill() }
          guard let result = result else { XCTFail("No query result");  return }
          XCTAssertEqual(result.data?.hero?.name, "R2-D2")
        }

        self.waitForExpectations(timeout: 5, handler: nil)

        do { try client.clearCache().await() }
        catch { XCTFail() }

        let expectation2 = self.expectation(description: "Fetching query")

        client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { (result, error) in
          defer { expectation2.fulfill() }
          XCTAssertNil(result)
          XCTAssertNil(error)
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

      client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch) { (result, error) in
        defer { expectation.fulfill() }

        XCTAssertNil(error)
        XCTAssertNil(result)
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

      client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, queue: queue) { (result, error) in
        defer { expectation.fulfill() }

        XCTAssertNotNil(DispatchQueue.getSpecific(key: key))
      }

      waitForExpectations(timeout: 5, handler: nil)
    }
  }
}

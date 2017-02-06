import XCTest
@testable import Apollo

class FetchQueryTests: XCTestCase {
  func testFetchIgnoringCacheData() throws {
    let query = HeroNameQuery()
    
    let store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
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
    
    waitForExpectations(timeout: 1, handler: nil)
  }
  
  func testReturnCacheDataElseFetchWithCachedData() throws {
    let query = HeroNameQuery()
    
    let store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
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
    
    waitForExpectations(timeout: 1, handler: nil)
  }
  
  func testReturnCacheDataElseFetchWithMissingData() throws {
    let query = HeroNameQuery()
    
    let store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
      ]
    ])
    
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
    
    waitForExpectations(timeout: 1, handler: nil)
  }
  
  func testReturnCacheDataDontFetchWithCachedData() throws {
    let query = HeroNameQuery()
    
    let store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
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
    
    waitForExpectations(timeout: 1, handler: nil)
  }
  
  func testReturnCacheDataDontFetchWithMissingData() throws {
    let query = HeroNameQuery()
    
    let store = ApolloStore(records: [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
      ]
    ])
    
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
    
    waitForExpectations(timeout: 1, handler: nil)
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
    
    let client = ApolloClient(networkTransport: networkTransport)
    
    let expectation = self.expectation(description: "Fetching query")
    
    client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, queue: queue) { (result, error) in
      defer { expectation.fulfill() }
      
      XCTAssertNotNil(DispatchQueue.getSpecific(key: key))
    }
    
    waitForExpectations(timeout: 1, handler: nil)
  }
}

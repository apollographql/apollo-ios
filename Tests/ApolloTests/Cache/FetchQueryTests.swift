import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class FetchQueryTests: XCTestCase, CacheDependentTesting {
  
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  static let defaultWaitTimeout: TimeInterval = 1
  
  var cache: NormalizedCache!
  var server: MockGraphQLServer!
  var client: ApolloClient!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    cache = try makeNormalizedCache()
    let store = ApolloStore(cache: cache)
    
    server = MockGraphQLServer()
    let networkTransport = MockNetworkTransport(server: server, store: store)
    
    client = ApolloClient(networkTransport: networkTransport, store: store)
  }
  
  override func tearDownWithError() throws {
    cache = nil
    server = nil
    client = nil
    
    try super.tearDownWithError()
  }
  
  func testFetchIgnoringCacheDataOnlyHitsNetwork() throws {
    let query = HeroNameQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
      [
        "data": [
          "hero": [
            "name": "Luke Skywalker",
            "__typename": "Human"
          ]
        ]
      ]
    }
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultFromServerExpectation = resultObserver.expectation(description: "Received result from server") { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Luke Skywalker")
      }
    }
    
    client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, resultHandler: resultObserver.handler)
    
    wait(for: [serverRequestExpectation, fetchResultFromServerExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReturnCacheDataAndFetchHitsCacheFirstAndNetworkAfter() throws {
    let query = HeroNameQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
      [
        "data": [
          "hero": [
            "name": "Luke Skywalker",
            "__typename": "Human"
          ]
        ]
      ]
    }
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultFromCacheExpectation = resultObserver.expectation(description: "Received result from cache") { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
    }
    
    let fetchResultFromServerExpectation = resultObserver.expectation(description: "Received result from server") { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Luke Skywalker")
      }
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataAndFetch, resultHandler: resultObserver.handler)
    
    wait(for: [fetchResultFromCacheExpectation, serverRequestExpectation, fetchResultFromServerExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReturnCacheDataElseFetchWhenDataIsCachedDoesntHitNetwork() throws {
    let query = HeroNameQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultFromCacheExpectation = resultObserver.expectation(description: "Received result from cache") { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataElseFetch, resultHandler: resultObserver.handler)
    
    wait(for: [fetchResultFromCacheExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReturnCacheDataElseFetchWhenNotAllDataIsCachedHitsNetwork() throws {
    let query = HeroNameAndAppearsInQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid"
      ]
    ])
    
    let serverRequestExpectation = server.expect(HeroNameAndAppearsInQuery.self) { request in
      [
        "data": [
          "hero": [
            "name": "R2-D2",
            "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"],
            "__typename": "Droid"
          ]
        ]
      ]
    }
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultFromServerExpectation = resultObserver.expectation(description: "Received result from server") { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .server)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        XCTAssertEqual(data.hero?.appearsIn, [.newhope, .empire, .jedi])
      }
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataAndFetch, resultHandler: resultObserver.handler)
    
    wait(for: [serverRequestExpectation, fetchResultFromServerExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReturnCacheDataDontFetchWhenDataIsCachedDoesntHitNetwork() throws {
    let query = HeroNameQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultFromCacheExpectation = resultObserver.expectation(description: "Received result from cache") { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch, resultHandler: resultObserver.handler)
    
    wait(for: [fetchResultFromCacheExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReturnCacheDataDontFetchWhenNotAllDataIsCachedReturnsError() throws {
    let query = HeroNameAndAppearsInQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid"
      ]
    ])
    
    let resultObserver = makeResultObserver(for: query)
    
    let cacheMissResultExpectation = resultObserver.expectation(description: "Received cache miss error") { result in
      // TODO: We should check for a specific error type once we've defined a cache miss error.
      XCTAssertThrowsError(try result.get())
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch, resultHandler: resultObserver.handler)
    
    wait(for: [cacheMissResultExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testClearCache() throws {
    let query = HeroNameQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultFromCacheExpectation = resultObserver.expectation(description: "Received result from cache") { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch, resultHandler: resultObserver.handler)
    
    wait(for: [fetchResultFromCacheExpectation], timeout: Self.defaultWaitTimeout)
    
    let cacheMissResultExpectation = resultObserver.expectation(description: "Received cache miss error") { result in
      // TODO: We should check for a specific error type once we've defined a cache miss error.
      XCTAssertThrowsError(try result.get())
    }
    
    let cacheClearedExpectation = expectation(description: "Cache cleared")
    client.clearCache { result in
      XCTAssertSuccessResult(result)
      cacheClearedExpectation.fulfill()
    }
    
    wait(for: [cacheClearedExpectation], timeout: Self.defaultWaitTimeout)
    
    client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch, resultHandler: resultObserver.handler)
    
    wait(for: [cacheMissResultExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testCompletionHandlerIsCalledOnTheSpecifiedQueue() {
    let queue = DispatchQueue(label: "label")
    
    let key = DispatchSpecificKey<Void>()
    queue.setSpecific(key: key, value: ())
    
    let query = HeroNameQuery()
    
    let serverRequestExpectation = server.expect(HeroNameQuery.self) { request in
      [
        "data": [
          "hero": [
            "name": "Luke Skywalker",
            "__typename": "Human"
          ]
        ]
      ]
    }
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultExpectation = resultObserver.expectation(description: "Received fetch result") { result in
      XCTAssertNotNil(DispatchQueue.getSpecific(key: key))
    }
    
    client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, queue: queue, resultHandler: resultObserver.handler)
    
    wait(for: [serverRequestExpectation, fetchResultExpectation], timeout: Self.defaultWaitTimeout)
  }
}

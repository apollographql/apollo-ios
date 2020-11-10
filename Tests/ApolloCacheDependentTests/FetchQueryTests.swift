import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class FetchQueryTests: XCTestCase, CacheDependentTesting {
  
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  var defaultWaitTimeout: TimeInterval = 1
  
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
  
  func testFetchIgnoringCacheData() throws {
    let query = HeroNameQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
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
      let graphQLResult = try result.get()
      XCTAssertEqual(graphQLResult.source, .server)
      XCTAssertNil(graphQLResult.errors)
      
      let data = try XCTUnwrap(graphQLResult.data)
      XCTAssertEqual(data.hero?.name, "Luke Skywalker")
    }
    
    client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, resultHandler: resultObserver.handler)
    
    wait(for: [serverRequestExpectation, fetchResultFromServerExpectation], timeout: defaultWaitTimeout)
  }
  
  func testReturnCacheDataAndFetch() throws {
    let query = HeroNameQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
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
      let graphQLResult = try result.get()
      XCTAssertEqual(graphQLResult.source, .cache)
      XCTAssertNil(graphQLResult.errors)
      
      let data = try XCTUnwrap(graphQLResult.data)
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
    
    let fetchResultFromServerExpectation = resultObserver.expectation(description: "Received result from server") { result in
      let graphQLResult = try result.get()
      XCTAssertEqual(graphQLResult.source, .server)
      XCTAssertNil(graphQLResult.errors)
      
      let data = try XCTUnwrap(graphQLResult.data)
      XCTAssertEqual(data.hero?.name, "Luke Skywalker")
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataAndFetch, resultHandler: resultObserver.handler)
    
    wait(for: [fetchResultFromCacheExpectation, serverRequestExpectation, fetchResultFromServerExpectation], timeout: defaultWaitTimeout)
  }
  
  func testReturnCacheDataElseFetchWhenDataIsCached() throws {
    let query = HeroNameQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": Reference(key: "QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultFromCacheExpectation = resultObserver.expectation(description: "Received result from cache") { result in
      let graphQLResult = try result.get()
      XCTAssertEqual(graphQLResult.source, .cache)
      XCTAssertNil(graphQLResult.errors)
      
      let data = try XCTUnwrap(graphQLResult.data)
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataElseFetch, resultHandler: resultObserver.handler)
    
    wait(for: [fetchResultFromCacheExpectation], timeout: defaultWaitTimeout)
  }
  
  func testReturnCacheDataElseFetchWhenNotAllDataIsCached() throws {
    let query = HeroNameAndAppearsInQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
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
      let graphQLResult = try result.get()
      XCTAssertEqual(graphQLResult.source, .server)
      XCTAssertNil(graphQLResult.errors)
      
      let data = try XCTUnwrap(graphQLResult.data)
      XCTAssertEqual(data.hero?.name, "R2-D2")
      XCTAssertEqual(data.hero?.appearsIn, [.newhope, .empire, .jedi])
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataAndFetch, resultHandler: resultObserver.handler)
    
    wait(for: [serverRequestExpectation, fetchResultFromServerExpectation], timeout: defaultWaitTimeout)
  }
  
  func testReturnCacheDataDontFetchWhenDataIsCached() throws {
    let query = HeroNameQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultFromCacheExpectation = resultObserver.expectation(description: "Received result from cache") { result in
      let graphQLResult = try result.get()
      XCTAssertEqual(graphQLResult.source, .cache)
      XCTAssertNil(graphQLResult.errors)
      
      let data = try XCTUnwrap(graphQLResult.data)
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch, resultHandler: resultObserver.handler)
    
    wait(for: [fetchResultFromCacheExpectation], timeout: defaultWaitTimeout)
  }
  
  func testReturnCacheDataDontFetchWhenNotAllDataIsCached() throws {
    let query = HeroNameAndAppearsInQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
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
    
    wait(for: [cacheMissResultExpectation], timeout: defaultWaitTimeout)
  }
  
  func testClearCache() throws {
    let query = HeroNameQuery()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultFromCacheExpectation = resultObserver.expectation(description: "Received result from cache") { result in
      let graphQLResult = try result.get()
      XCTAssertEqual(graphQLResult.source, .cache)
      XCTAssertNil(graphQLResult.errors)
      
      let data = try XCTUnwrap(graphQLResult.data)
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch, resultHandler: resultObserver.handler)
    
    wait(for: [fetchResultFromCacheExpectation], timeout: defaultWaitTimeout)
    
    let cacheMissResultExpectation = resultObserver.expectation(description: "Received cache miss error") { result in
      // TODO: We should check for a specific error type once we've defined a cache miss error.
      XCTAssertThrowsError(try result.get())
    }
    
    let cacheClearedExpectation = expectSuccessfulResult(description: "Cache cleared") { handler in
      client.clearCache(completion: handler)
    }
    
    wait(for: [cacheClearedExpectation], timeout: defaultWaitTimeout)
    
    client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch, resultHandler: resultObserver.handler)
    
    wait(for: [cacheMissResultExpectation], timeout: defaultWaitTimeout)
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
    
    wait(for: [serverRequestExpectation, fetchResultExpectation], timeout: defaultWaitTimeout)
  }
}

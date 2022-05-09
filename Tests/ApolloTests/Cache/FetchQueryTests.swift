import XCTest
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

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
  
  func test__fetch__givenCachePolicy_fetchIgnoringCacheData_onlyHitsNetwork() throws {
    class HeroNameSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }
    }

    let query = MockQuery<HeroNameSelectionSet>()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let serverRequestExpectation =
      server.expect(MockQuery<HeroNameSelectionSet>.self) { request in
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
    
    let fetchResultFromServerExpectation = resultObserver.expectation(
      description: "Received result from server"
    ) { result in
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
  
  func test__fetch__givenCachePolicy_returnCacheDataAndFetch_hitsCacheFirstAndNetworkAfter() throws {
    class HeroNameSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }
    }

    let query = MockQuery<HeroNameSelectionSet>()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let serverRequestExpectation =
      server.expect(MockQuery<HeroNameSelectionSet>.self) { request in
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
    
    let fetchResultFromCacheExpectation = resultObserver.expectation(
      description: "Received result from cache"
    ) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
    }
    
    let fetchResultFromServerExpectation = resultObserver.expectation(
      description: "Received result from server"
    ) { result in
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
  
  func test__fetch__givenCachePolicy_returnCacheDataElseFetch_givenDataIsCached_doesntHitNetwork() throws {
    class HeroNameSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }
    }

    let query = MockQuery<HeroNameSelectionSet>()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultFromCacheExpectation = resultObserver.expectation(
      description: "Received result from cache"
    ) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
    }
    
    client.fetch(query: query,
                 cachePolicy: .returnCacheDataElseFetch,
                 resultHandler: resultObserver.handler)
    
    wait(for: [fetchResultFromCacheExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func test__fetch__givenCachePolicy_returnCacheDataElseFetch_givenNotAllDataIsCached_hitsNetwork() throws {
    class HeroNameAndAppearsInSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("appearsIn", [String]?.self)
        ]}
      }
    }

    let query = MockQuery<HeroNameAndAppearsInSelectionSet>()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid"
      ]
    ])
    
    let serverRequestExpectation =
      server.expect(MockQuery<HeroNameAndAppearsInSelectionSet>.self) { request in
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
        XCTAssertEqual(data.hero?.appearsIn, ["NEWHOPE", "EMPIRE", "JEDI"])
      }
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataAndFetch, resultHandler: resultObserver.handler)
    
    wait(for: [serverRequestExpectation, fetchResultFromServerExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func test__fetch__givenCachePolicy_returnCacheDataDontFetch_givenDataIsCached_doesntHitNetwork() throws {
    class HeroNameSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }
    }

    let query = MockQuery<HeroNameSelectionSet>()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
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
  
  func test__fetch__givenCachePolicy_returnCacheDataDontFetch_givenNotAllDataIsCached_returnsError() throws {
    class HeroNameAndAppearsInSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("appearsIn", [String]?.self)
        ]}
      }
    }

    let query = MockQuery<HeroNameAndAppearsInSelectionSet>()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
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
    
    client.fetch(query: query,
                 cachePolicy: .returnCacheDataDontFetch,
                 resultHandler: resultObserver.handler)
    
    wait(for: [cacheMissResultExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func test__fetch_afterClearCache_givenCachePolicy_returnCacheDataDontFetch_throwsCacheMissError() throws {
    class HeroNameSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }
    }

    let query = MockQuery<HeroNameSelectionSet>()
    
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ])
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultFromCacheExpectation = resultObserver.expectation(
      description: "Received result from cache"
    ) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }
    }
    
    client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch, resultHandler: resultObserver.handler)
    
    wait(for: [fetchResultFromCacheExpectation], timeout: Self.defaultWaitTimeout)

    runActivity("Clear the cache") { _ in
      let cacheClearedExpectation = expectation(description: "Cache cleared")
      client.clearCache { result in
        XCTAssertSuccessResult(result)
        cacheClearedExpectation.fulfill()
      }

      wait(for: [cacheClearedExpectation], timeout: Self.defaultWaitTimeout)
    }

    runActivity("Fetch from cache and expect cache miss failure") { _ in
      let cacheMissResultExpectation = resultObserver.expectation(description: "Received cache miss error") { result in
        // TODO: We should check for a specific error type once we've defined a cache miss error.
        XCTAssertThrowsError(try result.get())
      }

      client.fetch(query: query, cachePolicy: .returnCacheDataDontFetch, resultHandler: resultObserver.handler)

      wait(for: [cacheMissResultExpectation], timeout: Self.defaultWaitTimeout)
    }
  }
  
  func testCompletionHandlerIsCalledOnTheSpecifiedQueue() {
    let queue = DispatchQueue(label: "label")
    
    let key = DispatchSpecificKey<Void>()
    queue.setSpecific(key: key, value: ())
    
    let query = MockQuery.mock()
    
    let serverRequestExpectation = server.expect(MockQuery<MockSelectionSet>.self) { request in
      ["data": [:]]
    }
    
    let resultObserver = makeResultObserver(for: query)
    
    let fetchResultExpectation = resultObserver.expectation(
      description: "Received fetch result"
    ) { result in
      XCTAssertNotNil(DispatchQueue.getSpecific(key: key))
    }
    
    client.fetch(query: query,
                 cachePolicy: .fetchIgnoringCacheData,
                 queue: queue, resultHandler: resultObserver.handler)
    
    wait(for: [serverRequestExpectation, fetchResultExpectation], timeout: Self.defaultWaitTimeout)
  }
}

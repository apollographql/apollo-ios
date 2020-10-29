import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class FetchQueryTests: ClientIntegrationTests {
  
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
  
  func testThreadedCache() throws {
    throw XCTSkip("Test is broken, will be replaced.")
    
    let cache = InMemoryNormalizedCache()
    let store = ApolloStore(cache: cache)
    let store2 = ApolloStore(cache: cache)
    
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
    ], store: store)
    
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
    ], store: store2)
    
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
        client1.clearCache() { _ in
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

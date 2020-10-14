//
//  RawCacheDataHelperTests.swift
//  Apollo
//
//  Created by Ellen Shapiro on 10/7/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import XCTest
import Apollo
import ApolloTestSupport
import StarWarsAPI

class RawCacheDataHelperTests: XCTestCase, CacheTesting {
  
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  private class TestFetcher: RawNetworkFetcher {
    func fetchData<Operation: GraphQLOperation>(operation: Operation, completion: @escaping (Result<Data, Error>) -> Void) {
      let json = """
{
  "data": {
    "hero": {
      "__typename": "Human",
      "name": "Luke Skywalker"
    }
  },
  "errors": null
}
"""
      
      completion(.success(json.data(using: .utf8)!))
    }
  }
  
  fileprivate class ErrorFetcher: RawNetworkFetcher {
    enum TestError: Error {
      case anError
    }
    
    func fetchData<Operation: GraphQLOperation>(operation: Operation, completion: @escaping (Result<Data, Error>) -> Void) {
      completion(.failure(TestError.anError))
    }
  }
  
  func testFetchIgnoringCacheCompletelyIgnoresExistingCacheAndReturnsDataAndDoesNotWriteToCache() {
    
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .fetchIgnoringCacheCompletely,
                                        store: store,
                                        networkFetcher: TestFetcher()) { cacheHelperResult in
        // This should have the result from the network:
        switch cacheHelperResult {
        case .failure(let error):
          XCTFail("Unexpected error with cache helper: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Human")
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        // The existing item in the cache should not have been touched:
        switch cacheResult {
        case .failure(let error):
          XCTFail("Unexpected error fetching from cache: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Droid")
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testFetchIgnoringCacheCompletelyPropagatesNetworkErrorAndDoesNotAffectCache() {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .fetchIgnoringCacheCompletely,
                                        store: store,
                                        networkFetcher: ErrorFetcher()) { cacheHelperResult in
        switch cacheHelperResult {
        case .success:
          XCTFail("This should not have succeeded")
        case .failure(let error):
          switch error {
          case ErrorFetcher.TestError.anError:
            // This is what we want
            break
          default:
            XCTFail("Unexpected error with cache helper: \(error)")
          }
        }
        
        fetchExpectation.fulfill()
      }
      
      self.wait(for: [fetchExpectation], timeout: 2)
      
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        // The existing item in the cache should not have been touched:
        switch cacheResult {
        case .failure(let error):
          XCTFail("Unexpected error fetching from cache: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Droid")
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testFetchIgnoringCacheDataIgnoresExistingCacheAndReturnsDataAndWritesToCache() {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .fetchIgnoringCacheData,
                                        store: store,
                                        networkFetcher: TestFetcher()) { cacheHelperResult in
        // This should have the result from the network:
        switch cacheHelperResult {
        case .failure(let error):
          XCTFail("Unexpected error with cache helper: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Human")
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      // The existing item in the cache should have been updated
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        switch cacheResult {
        case .failure(let error):
          XCTFail("Unexpected error fetching from cache: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Human")
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testFetchIgnoringCacheDataPropagatesErrorAndDoesNotAffectCache() {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .fetchIgnoringCacheData,
                                        store: store,
                                        networkFetcher: ErrorFetcher()) { cacheHelperResult in
        switch cacheHelperResult {
        case .success:
          XCTFail("This should not have succeeded")
        case .failure(let error):
          switch error {
          case ErrorFetcher.TestError.anError:
            // This is what we want
            break
          default:
            XCTFail("Unexpected error with cache helper: \(error)")
          }
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      // The existing item in the cache should not have been updated
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        switch cacheResult {
        case .failure(let error):
          XCTFail("Unexpected error fetching from cache: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Droid")
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testReturnCacheDataDontFetchWithRecordReturnsTheRecordWithoutHittingNetworkAndDoesNotUpdateTheCache() {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .returnCacheDataDontFetch,
                                        store: store,
                                        networkFetcher: ErrorFetcher()) { cacheHelperResult in
        // This should have the result from the network:
        switch cacheHelperResult {
        case .failure(let error):
          XCTFail("Unexpected error with cache helper: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Droid")
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      // The existing item in the cache should have been updated
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        switch cacheResult {
        case .failure(let error):
          XCTFail("Unexpected error fetching from cache: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Droid")
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testReturnCacheDataDontFetchWithoutRecordReturnsACacheErrorAndDoesNotUpdateTheCache() {
    withCache { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .returnCacheDataDontFetch,
                                        store: store,
                                        networkFetcher: ErrorFetcher()) { cacheHelperResult in
        // This should be an error since there's nothing in the initial cache and we're not going out to fetch:
        switch cacheHelperResult {
        case .failure(let error):
          switch error {
          case JSONDecodingError.missingValue:
            // This is what we expect.
            break
          case ErrorFetcher.TestError.anError:
            XCTFail("This went through and called the network fetcher when it shouldn't have")
          default:
            XCTFail("Unexpected error type: \(error)")
          }
        case .success:
          XCTFail("This fetch should not have succeeded with an empty cache!")
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        // There should still be nothing in the cache
        switch cacheResult {
        case .failure(let error):
          switch error {
          case JSONDecodingError.missingValue:
            // This is what we expect.
            break
          default:
            XCTFail("Unexpected error type: \(error)")
          }
        case .success:
          XCTFail("This fetch should not have succeeded with an empty cache!")
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testReturnCacheDataElseFetchWithRecordReturnsTheRecordWithoutHittingNetworkAndDoesNotUpdateTheCache() {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .returnCacheDataElseFetch,
                                        store: store,
                                        networkFetcher: ErrorFetcher()) { cacheHelperResult in
        // This should have the result from the network:
        switch cacheHelperResult {
        case .failure(let error):
          XCTFail("Unexpected error with cache helper: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Droid")
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        // The existing item in the cache should not have been touched:
        switch cacheResult {
        case .failure(let error):
          XCTFail("Unexpected error fetching from cache: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Droid")
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testReturnCacheDataElseFetchWithoutRecordReturnsRecordFromNetworkAndUpdatesTheCache() {
    withCache { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .returnCacheDataElseFetch,
                                        store: store,
                                        networkFetcher: TestFetcher()) { cacheHelperResult in
        // We should get the result from the network here
        switch cacheHelperResult {
        case .failure(let error):
          XCTFail("Unexpected error with cache helper: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Human")
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        // Result from network should now be in cache
        switch cacheResult {
        case .failure(let error):
          XCTFail("Unexpected error fetching from cache: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Human")
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testReturnCacheDataElseFetchWithoutRecordPropagatesErrorFromNetworkAndDoesNotUpdateCache() {
    withCache { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .returnCacheDataElseFetch,
                                        store: store,
                                        networkFetcher: ErrorFetcher()) { cacheHelperResult in
        switch cacheHelperResult {
        case .success:
          XCTFail("This should not have succeeded")
        case .failure(let error):
          switch error {
          case ErrorFetcher.TestError.anError:
            // This is what we want
            break
          default:
            XCTFail("Unexpected error with cache helper: \(error)")
          }
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        // Cache should still be empty
        switch cacheResult {
        case .success:
          XCTFail("This should not have succeeded")
        case .failure(let error):
          switch error {
          case JSONDecodingError.missingValue:
            // This is what we want
            break
          default:
            XCTFail("Unexpected error fetching from cache: \(error)")
          }
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testReturnCacheDataAndFetchWithRecordReturnsCacheRecordThenNetworkRecordAndUpdatesCache() {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      fetchExpectation.expectedFulfillmentCount = 2
      var callbackCount = 0
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .returnCacheDataAndFetch,
                                        store: store,
                                        networkFetcher: TestFetcher()) { cacheHelperResult in
        callbackCount += 1
        switch cacheHelperResult {
        case .failure(let error):
          XCTFail("Unexpected error with cache helper: \(error)")
        case .success(let graphQLResult):
          switch callbackCount {
          case 1:
            // This should have the result from the cache:
            XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
            XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Droid")
          case 2:
            // This should have the result from the network:
            XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
            XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Human")
          default:
            XCTFail("Too many callbacks!")
          }
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        // This should now have the result from the network:
        switch cacheResult {
        case .failure(let error):
          XCTFail("Unexpected error fetching from cache: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Human")
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testReturnCacheDataAndFetchWithRecordReturnsCacheRecordThenPropagatesNetworkErrorAndDoesNotUpdateCache() {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": [
        "name": "R2-D2",
        "__typename": "Droid",
      ]
    ]
    
    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      fetchExpectation.expectedFulfillmentCount = 2
      var callbackCount = 0
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .returnCacheDataAndFetch,
                                        store: store,
                                        networkFetcher: ErrorFetcher()) { cacheHelperResult in
        callbackCount += 1
        switch cacheHelperResult {
        case .failure(let error):
          if callbackCount == 2 {
            switch error {
            case ErrorFetcher.TestError.anError:
              // this is what we want
              break
            default:
              XCTFail("Unexpected error on callback \(callbackCount) with cache helper: \(error)")
            }
          } else {
            XCTFail("Unexpected error on callback \(callbackCount) with cache helper: \(error)")
          }
        case .success(let graphQLResult):
          if callbackCount == 1 {
            // This should have the result from the cache:
            XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
            XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Droid")
          } else {
            XCTFail("Callback \(callbackCount) should not have succeeded!")
          }
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        // This should still be the result from the cache:
        switch cacheResult {
        case .failure(let error):
          XCTFail("Unexpected error fetching from cache: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "R2-D2")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Droid")
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testReturnCacheDataAndFetchWithoutRecordReturnsOnceWithFetchedRecordAndUpdatesCache() {
    withCache { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .returnCacheDataAndFetch,
                                        store: store,
                                        networkFetcher: TestFetcher()) { cacheHelperResult in
        // We should get the result from the network here, and only once
        switch cacheHelperResult {
        case .failure(let error):
          XCTFail("Unexpected error with cache helper: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Human")
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        // Result from network should now be in cache
        switch cacheResult {
        case .failure(let error):
          XCTFail("Unexpected error fetching from cache: \(error)")
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Luke Skywalker")
          XCTAssertEqual(graphQLResult.data?.hero?.__typename, "Human")
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
  
  func testReturnCacheDataAndFetchWithoutRecordReturnsOnceWithNetworkErrorAndDoesNotUpdateCache() {
    withCache { cache in
      let store = ApolloStore(cache: cache)
      
      let fetchExpectation = self.expectation(description: "Fetch complete")
      RawDataCacheHelper().sendViaCache(operation: HeroNameQuery(),
                                        cachePolicy: .returnCacheDataAndFetch,
                                        store: store,
                                        networkFetcher: ErrorFetcher()) { cacheHelperResult in
        // We should get the result from the network here, and only once
        switch cacheHelperResult {
        case .success:
          XCTFail("This should not have succeeded")
        case .failure(let error):
          switch error {
          case ErrorFetcher.TestError.anError:
            // This is what we want
            break
          case JSONDecodingError.missingValue:
            XCTFail("Cache error was returned instead of network error")
          default:
            XCTFail("Unexpected error with cache helper: \(error)")
          }
        }
        
        fetchExpectation.fulfill()
      }
      self.wait(for: [fetchExpectation], timeout: 2)
      
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroNameQuery()) { cacheResult in
        // The cache should still be empty
        switch cacheResult {
        case .success:
          XCTFail("This should not have succeeded")
        case .failure(let error):
          switch error {
          case JSONDecodingError.missingValue:
            // This is what wew want
            break
          default:
            XCTFail("Unexpected error fetching from cache: \(error)")
          }
        }
        
        loadExpectation.fulfill()
      }
      self.wait(for: [loadExpectation], timeout: 2)
    }
  }
}

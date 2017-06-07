import XCTest
@testable import Apollo
import StarWarsAPI

private final class MockBatchedNormalizedCache: NormalizedCache {
  private var records: RecordSet
  
  init(records: RecordSet) {
    self.records = records
  }
  
  func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    return Promise { fulfill, reject in
      DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
        let records = keys.map { self.records[$0] }
        fulfill(records)
      }
    }
  }
  
  func merge(records: RecordSet) -> Promise<Set<CacheKey>> {
    return Promise { fulfill, reject in
      DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
        let changedKeys = self.records.merge(records: records)
        fulfill(changedKeys)
      }
    }
  }
}

class NormalizedCachingTests: XCTestCase {
  func testParallelLoads() {
    let records: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "2001")],
      "2001": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          Reference(key: "1000"),
          Reference(key: "1002"),
          Reference(key: "1003")
        ]
      ],
      "1000": ["__typename": "Human", "name": "Luke Skywalker"],
      "1002": ["__typename": "Human", "name": "Han Solo"],
      "1003": ["__typename": "Human", "name": "Leia Organa"],
    ]
    
    let cache = MockBatchedNormalizedCache(records: records)
    let store = ApolloStore(cache: cache)
    
    let query = HeroAndFriendsNamesQuery()
    
    measure {
      (1...100).forEach { number in
        let expectation = self.expectation(description: "Loading query #\(number) from store")
        
        store.load(query: query) { (result, error) in
          XCTAssertEqual(result?.data?.hero?.name, "R2-D2")
          expectation.fulfill()
        }
      }
      
      self.waitForExpectations(timeout: 5)
    }
  }
  
  func testLoadsWithInterleavedWrites() {
    let records: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "2001")],
      "2001": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          Reference(key: "1000"),
          Reference(key: "1002"),
          Reference(key: "1003")
        ]
      ],
      "1000": ["__typename": "Human", "name": "Luke Skywalker"],
      "1002": ["__typename": "Human", "name": "Han Solo"],
      "1003": ["__typename": "Human", "name": "Leia Organa"],
    ]
    
    let cache = MockBatchedNormalizedCache(records: records)
    let store = ApolloStore(cache: cache)
    
    let query = HeroAndFriendsNamesQuery()
    
    measure {
      (1...10).forEach { number in
        _ = store.publish(records: [
          "2001": [
            "friends": [
              Reference(key: "new_\(number)"),
            ]
          ],
          "new_\(number)": ["__typename": "Droid", "name": "Droid #\(number)"]
        ], context: nil)
        
        (1...10).forEach { _ in
          let expectation = self.expectation(description: "Loading query #\(number) from store")
          
          store.load(query: query) { (result, error) in
            XCTAssertEqual(result?.data?.hero?.friends?.first??.name, "Droid #\(number)")
            expectation.fulfill()
          }
        }
      }
      
      self.waitForExpectations(timeout: 5)
    }
  }
}

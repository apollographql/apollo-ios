import XCTest
@testable import Apollo
import StarWarsAPI

public final class DelayedCache: NormalizedCache {
  private var records: RecordSet
  
  public init(records: RecordSet) {
    self.records = records
  }
  
  public func loadRecord(forKey key: CacheKey) -> Promise<Record?> {
    return Promise { fulfill, reject in
      DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(10)) {
        fulfill(self.records[key])
      }
    }
  }
  
  public func merge(records: RecordSet) -> Set<CacheKey> {
    return self.records.merge(records: records)
  }
}

public final class BatchedNormalizedCache: NormalizedCache {
  private var records: RecordSet
  private var loader: DataLoader<CacheKey, Record?>!
  
  public init(records: RecordSet) {
    self.records = records
    self.loader = DataLoader(loadRecords)
  }
  
  func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    return Promise { fulfill, reject in
      DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(10)) {
        let records = keys.map { self.records[$0] }
        fulfill(records)
      }
    }
  }
  
  public func loadRecord(forKey key: CacheKey) -> Promise<Record?> {
    return loader.load(key: key)
  }
  
  public func merge(records: RecordSet) -> Set<CacheKey> {
    return self.records.merge(records: records)
  }
}

class BatchedLoadTests: XCTestCase {
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
    
    let store = ApolloStore(cache: DelayedCache(records: records))
    
    let query = HeroAndFriendsNamesQuery()
    
    measure {
      (1...100).forEach { number in
        let expectation = self.expectation(description: "Loading query #\(number) from store")
        
        store.load(query: query, cacheKeyForObject: nil) { (result, error) in
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
    
    let store = ApolloStore(cache: DelayedCache(records: records))
    
    let query = HeroAndFriendsNamesQuery()
    
    measure {
      (1...10).forEach { number in
        store.publish(records: [
          "2001": [
            "friends": [
              Reference(key: "new_\(number)"),
            ]
          ],
          "new_\(number)": ["__typename": "Droid", "name": "Droid #\(number)"]
        ], context: nil)
        
        (1...100).forEach { _ in
          let expectation = self.expectation(description: "Loading query #\(number) from store")
          
          store.load(query: query, cacheKeyForObject: nil) { (result, error) in
            XCTAssertEqual(result?.data?.hero?.friends?.first??.name, "Droid #\(number)")
            expectation.fulfill()
          }
        }
      }
      
      self.waitForExpectations(timeout: 5)
    }
  }
}

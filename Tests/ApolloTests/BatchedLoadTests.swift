import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

private final class MockBatchedNormalizedCache: NormalizedCache {
  private var records: RecordSet
  
  var numberOfBatchLoads: Int32 = 0
  
  init(records: RecordSet) {
    self.records = records
  }
  
  func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    OSAtomicIncrement32(&numberOfBatchLoads)
    
    return Promise { fulfill, reject in
      DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1)) {
        let records = keys.map { self.records[$0] }
        fulfill(records)
      }
    }
  }
  
  func merge(records: RecordSet) -> Promise<Set<CacheKey>> {
    return Promise { fulfill, reject in
      DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1)) {
        let changedKeys = self.records.merge(records: records)
        fulfill(changedKeys)
      }
    }
  }
	
  func clear() -> Promise<Void> {
    return Promise { fulfill, reject in
      DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1)) {
        self.records.clear()
        fulfill(())
      }
    }
  }
}

class BatchedLoadTests: XCTestCase {  
  func testListsAreLoadedInASingleBatch() {
    var records = RecordSet()
    let drones = (1...100).map { number in
      Record(key: "Drone_\(number)", ["__typename": "Droid", "name": "Droid #\(number)"])
    }
    
    records.insert(Record(key: "QUERY_ROOT", ["hero": Reference(key: "2001")]))
    records.insert(Record(key: "2001", [
      "name": "R2-D2",
      "__typename": "Droid",
      "friends": drones.map { Reference(key: $0.key) }
    ]))
    records.insert(contentsOf: drones)
    
    let cache = MockBatchedNormalizedCache(records: records)
    let store = ApolloStore(cache: cache)
    
    let query = HeroAndFriendsNamesQuery()
    
    let expectation = self.expectation(description: "Loading query from store")
    
    store.load(query: query) { (result, error) in
      XCTAssertNil(error)
      XCTAssertNil(result?.errors)
      
      guard let data = result?.data else { XCTFail(); return }
      XCTAssertEqual(data.hero?.name, "R2-D2")
      XCTAssertEqual(data.hero?.friends?.count, 100)
      
      expectation.fulfill()
    }
    
    self.waitForExpectations(timeout: 1)
    
    XCTAssertEqual(cache.numberOfBatchLoads, 3)
  }
  
  func testParallelLoadsUseIndependentBatching() {
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
    
    (1...10).forEach { number in
      let expectation = self.expectation(description: "Loading query #\(number) from store")
      
      store.load(query: query) { (result, error) in
        XCTAssertNil(error)
        XCTAssertNil(result?.errors)
        
        guard let data = result?.data else { XCTFail(); return }
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.flatMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        
        expectation.fulfill()
      }
    }
    
    self.waitForExpectations(timeout: 1)
    
    XCTAssertEqual(cache.numberOfBatchLoads, 30)
  }
}

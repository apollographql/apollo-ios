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
  
  public func loadRecords(forKeys keys: Set<CacheKey>) throws -> [CacheKey: Record] {
    OSAtomicIncrement32(&numberOfBatchLoads)

    return keys.reduce(into: [:]) { results, key in
      results[key] = records[key]
    }
  }
  
  func loadRecords(forKeys keys: [CacheKey],
                   callbackQueue: DispatchQueue?,
                   completion: @escaping (Result<[Record?], Error>) -> Void) {
    OSAtomicIncrement32(&numberOfBatchLoads)
    
    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1)) {
      let records = keys.map { self.records[$0] }
      DispatchQueue.apollo.returnResultAsyncIfNeeded(on: callbackQueue,
                                                     action: completion,
                                                     result: .success(records))
    }
  }
  
  func removeRecord(for key: CacheKey) throws {
    records.removeRecord(for: key)
  }
  
  func merge(records: RecordSet) throws -> Set<CacheKey> {
    return self.records.merge(records: records)
  }
  
  func merge(records: RecordSet,
             callbackQueue: DispatchQueue?,
             completion: @escaping (Result<Set<CacheKey>, Error>) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1)) {
      let changedKeys = self.records.merge(records: records)
      DispatchQueue.apollo.returnResultAsyncIfNeeded(on: callbackQueue,
                                                     action: completion,
                                                     result: .success(changedKeys))
    }
  }
  
  func clear(callbackQueue: DispatchQueue?, completion: ((Result<Void, Error>) -> Void)?) {
    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1)) {
      self.records.clear()
      DispatchQueue.apollo.returnResultAsyncIfNeeded(on: callbackQueue,
                                                     action: completion,
                                                     result: .success(()))
    }
  }
  
  func clear() throws {
    records.clear()
  }
}

class BatchedLoadTests: XCTestCase {  
  func testListsAreLoadedInASingleBatch() {
    var records = RecordSet()
    let drones = (1...100).map { number in
      Record(key: "Drone_\(number)", ["__typename": "Droid", "name": "Droid #\(number)"])
    }
    
    records.insert(Record(key: "QUERY_ROOT", ["hero": CacheReference(key: "2001")]))
    records.insert(Record(key: "2001", [
      "name": "R2-D2",
      "__typename": "Droid",
      "friends": drones.map { CacheReference(key: $0.key) }
    ]))
    records.insert(contentsOf: drones)
    
    let cache = MockBatchedNormalizedCache(records: records)
    let store = ApolloStore(cache: cache)
    
    let query = HeroAndFriendsNamesQuery()
    
    let expectation = self.expectation(description: "Loading query from store")
    
    store.load(query: query) { result in
      defer {
        expectation.fulfill()
      }
      
      switch result {
      case .success(let graphQLResult):
        XCTAssertNil(graphQLResult.errors)
        
        guard let data = graphQLResult.data else {
          XCTFail("No data returned with result!")
          return
        }
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        XCTAssertEqual(data.hero?.friends?.count, 100)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
    }
    
    self.waitForExpectations(timeout: 1)
    
    XCTAssertEqual(cache.numberOfBatchLoads, 3)
  }
  
  func testParallelLoadsUseIndependentBatching() {
    let records: RecordSet = [
      "QUERY_ROOT": ["hero": CacheReference(key: "2001")],
      "2001": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          CacheReference(key: "1000"),
          CacheReference(key: "1002"),
          CacheReference(key: "1003")
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
      
      store.load(query: query) { result in
        defer {
          expectation.fulfill()
        }
        
        switch result {
        case .success(let graphQLResult):
          XCTAssertNil(graphQLResult.errors)
          
          guard let data = graphQLResult.data else {
            XCTFail("No data returned with query!")
            return
          
          }
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
    
    self.waitForExpectations(timeout: 1)
    
    XCTAssertEqual(cache.numberOfBatchLoads, 30)
  }
}

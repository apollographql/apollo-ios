import XCTest
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

private final class MockBatchedNormalizedCache: NormalizedCache {
  private var records: RecordSet
  
  @Atomic var numberOfBatchLoads: Int32 = 0
  
  init(records: RecordSet) {
    self.records = records
  }
  
  public func loadRecords(forKeys keys: Set<CacheKey>) throws -> [CacheKey: Record] {
    $numberOfBatchLoads.increment()

    return keys.reduce(into: [:]) { results, key in
      results[key] = records[key]
    }
  }
  
  func loadRecords(forKeys keys: [CacheKey],
                   callbackQueue: DispatchQueue?,
                   completion: @escaping (Result<[Record?], Error>) -> Void) {
    $numberOfBatchLoads.increment()
    
    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1)) {
      let records = keys.map { self.records[$0] }
      DispatchQueue.returnResultAsyncIfNeeded(on: callbackQueue,
                                                     action: completion,
                                                     result: .success(records))
    }
  }
  
  func removeRecord(for key: CacheKey) throws {
    records.removeRecord(for: key)
  }

  func removeRecords(matching pattern: CacheKey) throws {
    records.removeRecords(matching: pattern)
  }
  
  func merge(records: RecordSet) throws -> Set<CacheKey> {
    return self.records.merge(records: records)
  }
  
  func merge(records: RecordSet,
             callbackQueue: DispatchQueue?,
             completion: @escaping (Result<Set<CacheKey>, Error>) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1)) {
      let changedKeys = self.records.merge(records: records)
      DispatchQueue.returnResultAsyncIfNeeded(on: callbackQueue,
                                                     action: completion,
                                                     result: .success(changedKeys))
    }
  }
  
  func clear(callbackQueue: DispatchQueue?, completion: ((Result<Void, Error>) -> Void)?) {
    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1)) {
      self.records.clear()
      DispatchQueue.returnResultAsyncIfNeeded(on: callbackQueue,
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
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self)
      ]}

      var hero: Hero? { __data["hero"] }

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self),
        ]}

        var friends: [Friend]? { __data["friends"] }

        class Friend: MockSelectionSet {
          override class var __selections: [Selection] {[
            .field("__typename", String.self),
            .field("name", String.self),
          ]}

          var name: String { __data["name"] }
        }
      }
    }

    var records = RecordSet()
    let drones = (1...100).map { number in
      Record(key: "Drone_\(number)", ["__typename": "Droid", "name": "Droid #\(number)"])
    }
    
    records.insert(Record(key: "QUERY_ROOT", ["hero": CacheReference("2001")]))
    records.insert(Record(key: "2001", [
      "name": "R2-D2",
      "__typename": "Droid",
      "friends": drones.map { CacheReference($0.key) }
    ]))
    records.insert(contentsOf: drones)
    
    let cache = MockBatchedNormalizedCache(records: records)
    let store = ApolloStore(cache: cache)
    
    let query = MockQuery<GivenSelectionSet>()

    // when
    let expectation = self.expectation(description: "Loading query from store")

    store.load(query) { result in
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

    // then
    XCTAssertEqual(cache.numberOfBatchLoads, 3)
  }

  func test_batchedLoading_cacheKeyResolution_usingDeeplyNestedReferencedObjects_isDeferredToBatch() {
    // given
    MockSchemaMetadata.stub_cacheKeyInfoForType_Object = { type, data in
      switch type.typename {
      case "Human":
        return try? .init(jsonValue: data["friends"]?[0]?["nestedInfo"]?["id"])
      case "Droid":
        return try? .init(jsonValue: data["nestedInfo"]?["id"])
      default: return nil
      }
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self)
      ]}

      var hero: Hero? { __data["hero"] }

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("__typename", String.self),
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self),
        ]}

        var friends: [Friend]? { __data["friends"] }

        class Friend: MockSelectionSet {
          override class var __selections: [Selection] {[
            .field("__typename", String.self),
            .field("id", String.self),
            .field("name", String.self),
            .field("nestedInfo", NestedInfo.self),
          ]}

          var name: String { __data["name"] }

          class NestedInfo: MockSelectionSet {
            override class var __selections: [Selection] {[
              .field("__typename", String.self),
              .field("id", String.self),
            ]}
          }
        }
      }
    }

    var records = RecordSet()
    let friends = (1...10).map { number in
      records.insert(Record(
        key: "NestedInfo:\(number)", [
          "__typename": "NestedInfo",
          "id": "Nested_\(number)"
        ])
      )
      return Record(key: "Droid:\(number)", [
        "__typename": "Droid",
        "id": String(number),
        "name": "Droid #\(number)",
        "nestedInfo": CacheReference("NestedInfo:\(number)")
      ])
    }

    records.insert(Record(key: "QUERY_ROOT", ["hero": CacheReference("Human:2001")]))
    records.insert(Record(key: "Human:2001", [
      "name": "Luke",
      "__typename": "Human",
      "id": "2001",
      "friends": friends.map { CacheReference($0.key) }
    ]))
    records.insert(contentsOf: friends)

    let cache = MockBatchedNormalizedCache(records: records)
    let store = ApolloStore(cache: cache)

    let query = MockQuery<GivenSelectionSet>()

    // when
    let expectation = self.expectation(description: "Loading query from store")

    store.load(query) { result in
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

        XCTAssertEqual(data.hero?.name, "Luke")
        XCTAssertEqual(data.hero?.friends?.count, 10)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
    }

    self.waitForExpectations(timeout: 1)

    // then
    XCTAssertEqual(cache.numberOfBatchLoads, 3)
  }


  #warning("TODO: write test for batch loading nested objects for cache key resolution during WRITE transaction")

  func testParallelLoadsUseIndependentBatching() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self)
      ]}

      var hero: Hero? { __data["hero"] }

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
          .field("friends", [Friend]?.self),
        ]}

        var friends: [Friend]? { __data["friends"] }

        class Friend: MockSelectionSet {
          override class var __selections: [Selection] {[
            .field("__typename", String.self),
            .field("name", String.self),
          ]}

          var name: String { __data["name"] }
        }
      }
    }

    let records: RecordSet = [
      "QUERY_ROOT": ["hero": CacheReference("2001")],
      "2001": [
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          CacheReference("1000"),
          CacheReference("1002"),
          CacheReference("1003")
        ]
      ],
      "1000": ["__typename": "Human", "name": "Luke Skywalker"],
      "1002": ["__typename": "Human", "name": "Han Solo"],
      "1003": ["__typename": "Human", "name": "Leia Organa"],
    ]
    
    let cache = MockBatchedNormalizedCache(records: records)
    let store = ApolloStore(cache: cache)
    
    let query = MockQuery<GivenSelectionSet>()
    
    (1...10).forEach { number in
      let expectation = self.expectation(description: "Loading query #\(number) from store")
      
      store.load(query) { result in
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
          let friendsNames = data.hero?.friends?.compactMap { $0.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
      }
    }
    
    self.waitForExpectations(timeout: 1)

    // then
    XCTAssertEqual(cache.numberOfBatchLoads, 30)
  }
}

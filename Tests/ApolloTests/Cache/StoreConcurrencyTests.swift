import XCTest
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

class StoreConcurrencyTests: XCTestCase, CacheDependentTesting {
  
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  var defaultWaitTimeout: TimeInterval = 60
  
  var cache: NormalizedCache!
  var store: ApolloStore!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    cache = try makeNormalizedCache()
    store = ApolloStore(cache: cache)
  }
  
  override func tearDownWithError() throws {
    cache = nil
    store = nil
    
    try super.tearDownWithError()
  }

  // MARK: - Mocks

  class GivenSelectionSet: MockSelectionSet {
    override class var selections: [Selection] {[
      .field("hero", Hero?.self)
    ]}

    var hero: Hero? { data["hero"] }

    class Hero: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("name", String.self),
        .field("friends", [Friend]?.self),
      ]}

      var friends: [Friend]? { data["friends"] }

      class Friend: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
        ]}

        var name: String { data["name"] }
      }
    }
  }

  // MARK - Tests
  
  func testConcurrentReadsInitiatedFromMainThread() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let query = MockQuery<GivenSelectionSet>()
    
    let numberOfReads = 1000
    
    let allReadsCompletedExpectation = XCTestExpectation(description: "All reads completed")
    allReadsCompletedExpectation.expectedFulfillmentCount = numberOfReads
    
    for _ in 0..<numberOfReads {
      store.withinReadTransaction({ transaction in
        let data = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.map { $0.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }, completion: { result in
        defer { allReadsCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      })
    }
    
    self.wait(for: [allReadsCompletedExpectation], timeout: defaultWaitTimeout)
  }
  
  func testConcurrentReadsInitiatedFromBackgroundThreads() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let query = MockQuery<GivenSelectionSet>()
    
    let numberOfReads = 1000
    
    let allReadsCompletedExpectation = XCTestExpectation(description: "All reads completed")
    allReadsCompletedExpectation.expectedFulfillmentCount = numberOfReads
    
    DispatchQueue.concurrentPerform(iterations: numberOfReads) { _ in
      store.withinReadTransaction({ transaction in
        let data = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.map { $0.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }, completion: { result in
        defer { allReadsCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      })
    }
    
    self.wait(for: [allReadsCompletedExpectation], timeout: defaultWaitTimeout)
  }

  #warning("TODO: Fix these tests when mutable cache is implemented.")
//  func testConcurrentUpdatesInitiatedFromMainThread() throws {
//    mergeRecordsIntoCache([
//      "QUERY_ROOT": ["hero": CacheReference("2001")],
//      "2001": [
//        "name": "R2-D2",
//        "__typename": "Droid",
//        "friends": []
//      ]
//    ])
//    
//    let query = MockQuery<GivenSelectionSet>()
//    
//    let numberOfUpdates = 200
//    
//    let allUpdatesCompletedExpectation = XCTestExpectation(description: "All store updates completed")
//    allUpdatesCompletedExpectation.expectedFulfillmentCount = numberOfUpdates
//    
//    for i in 0..<numberOfUpdates {
//      store.withinReadWriteTransaction({ transaction in
//        try transaction.update(query: query) { data in
//          data.hero?.name = "Artoo"
//          data.hero?.friends?.append(.makeDroid(name: "Droid #\(i)"))
//        }
//        
//        let data = try transaction.read(query: query)
//        
//        XCTAssertEqual(data.hero?.name, "Artoo")
//        XCTAssertEqual(data.hero?.friends?.last??.name, "Droid #\(i)")
//      }, completion: { result in
//        defer { allUpdatesCompletedExpectation.fulfill() }
//        XCTAssertSuccessResult(result)
//      })
//    }
//    
//    self.wait(for: [allUpdatesCompletedExpectation], timeout: defaultWaitTimeout)
//    
//    let readCompletedExpectation = expectation(description: "Read completed")
//    
//    store.withinReadTransaction({ transaction in
//      let data = try transaction.read(query: query)
//      
//      XCTAssertEqual(data.hero?.name, "Artoo")
//      
//      let friendsNames = try XCTUnwrap(data.hero?.friends?.compactMap { $0?.name })
//      let expectedFriendsNames = (0..<numberOfUpdates).map { i in "Droid #\(i)" }
//      XCTAssertEqualUnordered(friendsNames, expectedFriendsNames)
//    }, completion: { result in
//      defer { readCompletedExpectation.fulfill() }
//      XCTAssertSuccessResult(result)
//    })
//    
//    self.wait(for: [readCompletedExpectation], timeout: 5)
//  }
//  
//  func testConcurrentUpdatesInitiatedFromBackgroundThreads() throws {
//    mergeRecordsIntoCache([
//      "QUERY_ROOT": ["hero": CacheReference("2001")],
//      "2001": [
//        "name": "R2-D2",
//        "__typename": "Droid",
//        "friends": []
//      ]
//    ])
//    
//    let query = MockQuery<GivenSelectionSet>()
//    
//    let numberOfUpdates = 200
//    
//    let allUpdatesCompletedExpectation = XCTestExpectation(description: "All store updates completed")
//    allUpdatesCompletedExpectation.expectedFulfillmentCount = numberOfUpdates
//    
//    DispatchQueue.concurrentPerform(iterations: numberOfUpdates) { i in      
//      store.withinReadWriteTransaction({ transaction in
//        try transaction.update(query: query) { data in
//          data.hero?.name = "Artoo"
//          data.hero?.friends?.append(.makeDroid(name: "Droid #\(i)"))
//        }
//        
//        let data = try transaction.read(query: query)
//        
//        XCTAssertEqual(data.hero?.name, "Artoo")
//        XCTAssertEqual(data.hero?.friends?.last??.name, "Droid #\(i)")
//      }, completion: { result in
//        defer { allUpdatesCompletedExpectation.fulfill() }
//        XCTAssertSuccessResult(result)
//      })
//    }
//    
//    self.wait(for: [allUpdatesCompletedExpectation], timeout: defaultWaitTimeout)
//    
//    let readCompletedExpectation = expectation(description: "Read completed")
//    
//    store.withinReadTransaction({ transaction in
//      let data = try transaction.read(query: query)
//      
//      XCTAssertEqual(data.hero?.name, "Artoo")
//      
//      let friendsNames = try XCTUnwrap(data.hero?.friends?.compactMap { $0?.name })
//      let expectedFriendsNames = (0..<numberOfUpdates).map { i in "Droid #\(i)" }
//      XCTAssertEqualUnordered(friendsNames, expectedFriendsNames)
//    }, completion: { result in
//      defer { readCompletedExpectation.fulfill() }
//      XCTAssertSuccessResult(result)
//    })
//    
//    self.wait(for: [readCompletedExpectation], timeout: 5)
//  }
}

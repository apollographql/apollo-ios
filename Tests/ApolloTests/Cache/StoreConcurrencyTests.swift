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

    var hero: Hero? { __data["hero"] }

    class Hero: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("name", String.self),
        .field("friends", [Friend]?.self),
      ]}

      var friends: [Friend]? { __data["friends"] }

      class Friend: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self),
        ]}

        var name: String { __data["name"] }
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

  func testConcurrentUpdatesInitiatedFromMainThread() throws {
    /// given
    struct GivenSelectionSet: MockMutableRootSelectionSet {
      public var __data: DataDict = DataDict([:], variables: nil)
      init(data: DataDict) { __data = data }

      static var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      var hero: Hero {
        get { __data["hero"] }
        set { __data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var __data: DataDict = DataDict([:], variables: nil)
        init(data: DataDict) { __data = data }

        static var selections: [Selection] { [
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self),
        ]}

        var id: String {
          get { __data["id"] }
          set { __data["id"] = newValue }
        }

        var name: String? {
          get { __data["name"] }
          set { __data["name"] = newValue }
        }

        var friends: [Friend] {
          get { __data["friends"] }
          set { __data["friends"] = newValue }
        }

        struct Friend: MockMutableRootSelectionSet {
          public var __data: DataDict = DataDict([:], variables: nil)
          init(data: DataDict) { __data = data }

          static var selections: [Selection] { [
            .field("id", String.self),
            .field("name", String.self),
          ]}

          var id: String {
            get { __data["id"] }
            set { __data["id"] = newValue }
          }

          var name: String {
            get { __data["name"] }
            set { __data["name"] = newValue }
          }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("2001")],
      "2001": [
        "name": "R2-D2",
        "id": "2001",
        "__typename": "Droid",
        "friends": []
      ]
    ])

    let cacheMutation = MockLocalCacheMutation<GivenSelectionSet>()
    let query = MockQuery<GivenSelectionSet>()

    let numberOfUpdates = 100

    let allUpdatesCompletedExpectation = XCTestExpectation(description: "All store updates completed")
    allUpdatesCompletedExpectation.expectedFulfillmentCount = numberOfUpdates

    for i in 0..<numberOfUpdates {
      store.withinReadWriteTransaction({ transaction in
        try transaction.update(cacheMutation) { data in
          data.hero.name = "Artoo"

          var newDroid = GivenSelectionSet.Hero.Friend()
          newDroid.__typename = "Droid"
          newDroid.id = "\(i)"
          newDroid.name = "Droid #\(i)"
          data.hero.friends.append(newDroid)
        }

        let data = try transaction.read(query: query)

        XCTAssertEqual(data.hero.name, "Artoo")
        XCTAssertEqual(data.hero.friends.last?.name, "Droid #\(i)")
      }, completion: { result in
        defer { allUpdatesCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      })
    }

    self.wait(for: [allUpdatesCompletedExpectation], timeout: defaultWaitTimeout)

    let readCompletedExpectation = expectation(description: "Read completed")

    store.withinReadTransaction({ transaction in
      let data = try transaction.read(query: query)

      XCTAssertEqual(data.hero.name, "Artoo")

      let friendsNames: [String] = try XCTUnwrap(
        data.hero.friends.compactMap { $0.name }
      )
      let expectedFriendsNames = (0..<numberOfUpdates).map { "Droid #\($0)" }
      XCTAssertEqualUnordered(friendsNames, expectedFriendsNames)
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })

    self.wait(for: [readCompletedExpectation], timeout: 5)
  }

  func testConcurrentUpdatesInitiatedFromBackgroundThreads() throws {
    /// given
    struct GivenSelectionSet: MockMutableRootSelectionSet {
      public var __data: DataDict = DataDict([:], variables: nil)
      init(data: DataDict) { __data = data }

      static var selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      var hero: Hero {
        get { __data["hero"] }
        set { __data["hero"] = newValue }
      }

      struct Hero: MockMutableRootSelectionSet {
        public var __data: DataDict = DataDict([:], variables: nil)
        init(data: DataDict) { __data = data }

        static var selections: [Selection] { [
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self),
        ]}

        var id: String {
          get { __data["id"] }
          set { __data["id"] = newValue }
        }

        var name: String? {
          get { __data["name"] }
          set { __data["name"] = newValue }
        }

        var friends: [Friend] {
          get { __data["friends"] }
          set { __data["friends"] = newValue }
        }

        struct Friend: MockMutableRootSelectionSet {
          public var __data: DataDict = DataDict([:], variables: nil)
          init(data: DataDict) { __data = data }

          static var selections: [Selection] { [
            .field("id", String.self),
            .field("name", String.self),
          ]}

          var id: String {
            get { __data["id"] }
            set { __data["id"] = newValue }
          }

          var name: String {
            get { __data["name"] }
            set { __data["name"] = newValue }
          }
        }
      }
    }

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference("2001")],
      "2001": [
        "name": "R2-D2",
        "id": "2001",
        "__typename": "Droid",
        "friends": []
      ]
    ])

    let cacheMutation = MockLocalCacheMutation<GivenSelectionSet>()
    let query = MockQuery<GivenSelectionSet>()

    let numberOfUpdates = 100

    let allUpdatesCompletedExpectation = XCTestExpectation(description: "All store updates completed")
    allUpdatesCompletedExpectation.expectedFulfillmentCount = numberOfUpdates

    DispatchQueue.concurrentPerform(iterations: numberOfUpdates) { i in
      store.withinReadWriteTransaction({ transaction in
        try transaction.update(cacheMutation) { data in
          data.hero.name = "Artoo"

          var newDroid = GivenSelectionSet.Hero.Friend()
          newDroid.__typename = "Droid"
          newDroid.id = "\(i)"
          newDroid.name = "Droid #\(i)"
          data.hero.friends.append(newDroid)
        }

        let data = try transaction.read(query: query)

        XCTAssertEqual(data.hero.name, "Artoo")
        XCTAssertEqual(data.hero.friends.last?.name, "Droid #\(i)")
      }, completion: { result in
        defer { allUpdatesCompletedExpectation.fulfill() }
        XCTAssertSuccessResult(result)
      })
    }

    self.wait(for: [allUpdatesCompletedExpectation], timeout: defaultWaitTimeout)

    let readCompletedExpectation = expectation(description: "Read completed")

    store.withinReadTransaction({ transaction in
      let data = try transaction.read(query: query)

      XCTAssertEqual(data.hero.name, "Artoo")

      let friendsNames: [String] = try XCTUnwrap(
        data.hero.friends.compactMap { $0.name }
      )

      let expectedFriendsNames = (0..<numberOfUpdates).map { "Droid #\($0)" }
      XCTAssertEqualUnordered(friendsNames, expectedFriendsNames)
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })

    self.wait(for: [readCompletedExpectation], timeout: 5)
  }
}

import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class ReadWriteFromStoreTests: XCTestCase, CacheDependentTesting, StoreLoading {
  
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  static let defaultWaitTimeout: TimeInterval = 5.0
  
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
  
  func testReadHeroNameQuery() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery()
    
    let readCompletedExpectation = expectation(description: "Read completed")
    
    store.withinReadTransaction({ transaction in
      let data = try transaction.read(query: query)
      
      XCTAssertEqual(data.hero?.__typename, "Droid")
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReadHeroNameQueryAfterRemovingRecord() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery()
    
    let readCompletedExpectation = expectation(description: "Read completed")
    
    store.withinReadWriteTransaction({ transaction in
      let data = try transaction.read(query: query)
      
      XCTAssertEqual(data.hero?.__typename, "Droid")
      XCTAssertEqual(data.hero?.name, "R2-D2")
      
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
    
    let removeCompletedExpectation = expectation(description: "Remove completed")

    store.withinReadWriteTransaction({ transaction in
      try transaction.removeObject(for: "hero")
    }, completion: { result in
      defer { removeCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
        
    self.wait(for: [removeCompletedExpectation], timeout: Self.defaultWaitTimeout)
    
    let refetchExpectation = expectation(description: "Refetch completed")

    store.withinReadWriteTransaction({ transaction in
      _ = try transaction.read(query: query)
    }, completion: { result in
      defer { refetchExpectation.fulfill() }
      XCTAssertFailureResult(result) { refetchError in
        guard let error = refetchError as? GraphQLResultError else {
          XCTFail("Unexpected error trying to load a removed record: \(refetchError)")
          return
        }
        
        XCTAssertEqual(error.path, ["hero"])

        switch error.underlying {
        case JSONDecodingError.missingValue:
          // This is correct.
          break
        default:
          XCTFail("Unexpected error trying to load a removed record: \(refetchError)")
        }
      }
    })
    
    self.wait(for: [refetchExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testHeroNameQueryStillLoadsAfterAttemptingToDeleteFieldKey() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery()
    
    let readCompletedExpectation = expectation(description: "Read completed")
    
    store.withinReadWriteTransaction({ transaction in
      let data = try transaction.read(query: query)
      
      XCTAssertEqual(data.hero?.__typename, "Droid")
      XCTAssertEqual(data.hero?.name, "R2-D2")
      
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
    
    let removeCompletedExpectation = expectation(description: "Remove completed")

    store.withinReadWriteTransaction({ transaction in
      try transaction.removeObject(for: "hero.name")
    }, completion: { result in
      defer { removeCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
        
    self.wait(for: [removeCompletedExpectation], timeout: Self.defaultWaitTimeout)
    
    let refetchExpectation = expectation(description: "Refetch completed")

    store.withinReadWriteTransaction({ transaction in
      _ = try transaction.read(query: query)
    }, completion: { result in
      defer { refetchExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [refetchExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReadHeroNameQueryWithVariable() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero(episode:JEDI)": CacheReference(key: "hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery(episode: .jedi)
    
    let readCompletedExpectation = expectation(description: "Read completed")
    
    store.withinReadTransaction({ transaction in
      let data = try transaction.read(query: query)
      
      XCTAssertEqual(data.hero?.__typename, "Droid")
      XCTAssertEqual(data.hero?.name, "R2-D2")
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReadHeroNameQueryWithMissingName() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "hero")],
      "hero": ["__typename": "Droid"]
    ])
    
    let query = HeroNameQuery()
    
    let readCompletedExpectation = expectation(description: "Read completed")
    
    store.withinReadTransaction({ transaction in
      XCTAssertThrowsError(try transaction.read(query: query)) { error in
        if case let error as GraphQLResultError = error {
          XCTAssertEqual(error.path, ["hero", "name"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testUpdateHeroNameQuery() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": CacheReference(key: "QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery()
    
    let updateCompletedExpectation = expectation(description: "Update completed")
    
    store.withinReadWriteTransaction({ transaction in
      try transaction.update(query: query) { data in
        data.hero?.name = "Artoo"
      }
    }, completion: { result in
      defer { updateCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [updateCompletedExpectation], timeout: Self.defaultWaitTimeout)
    
    loadFromStore(query: query) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "Artoo")
      }
    }
  }
  
  func testWriteHeroNameQueryWhenErrorIsThrown() throws {
    let writeCompletedExpectation = expectation(description: "Write completed")
    
    store.withinReadWriteTransaction({ transaction in
      let data = HeroNameQuery.Data(unsafeResultMap: [:])
      try transaction.write(data: data, forQuery: HeroNameQuery(episode: nil))
    }, completion: { result in
      defer { writeCompletedExpectation.fulfill() }
      
      XCTAssertFailureResult(result) { error in
        if let error = error as? GraphQLResultError {
          XCTAssertEqual(error.path, ["hero"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    })
    
    self.wait(for: [writeCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReadHeroAndFriendsNamesQuery() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    let readCompletedExpectation = expectation(description: "Read completed")
    
    store.withinReadTransaction({ transaction in
      let data = try transaction.read(query: query)
      
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReadHeroAndFriendsNamesQueryFailsAfterRemovingFriendRecord() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    let readWriteCompletedExpectation = expectation(description: "ReadWrite completed")
    
    store.withinReadWriteTransaction({ transaction in
      let data = try transaction.read(query: query)
      
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      
      try transaction.removeObject(for: "1003")
    }, completion: { result in
      defer { readWriteCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [readWriteCompletedExpectation], timeout: Self.defaultWaitTimeout)
    
    let readCompletedExpectation = expectation(description: "Read completed")
    
    store.withinReadTransaction({ transaction in
      _ = try transaction.read(query: query)
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertFailureResult(result) { readError in
        guard let error = readError as? GraphQLResultError else {
          XCTFail("Unexpected error for reading removed record: \(readError)")
          return
        }
        
        /// The error should occur when trying to load all the hero's friend references, since one has been deleted
        XCTAssertEqual(error.path, ["hero", "friends"])
        
        switch error.underlying {
        case JSONDecodingError.missingValue:
          // This is what we want
          return
        default:
          XCTFail("Unexpected error for reading removed record: \(error.underlying)")
        }
      }
    })
    
    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testUpdateHeroAndFriendsNamesQuery() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    let updateCompletedExpectation = expectation(description: "Update completed")
    
    store.withinReadWriteTransaction({ transaction in
      try transaction.update(query: query) { data in
        data.hero?.friends?.append(.makeDroid(name: "C-3PO"))
      }
    }, completion: { result in
      defer { updateCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [updateCompletedExpectation], timeout: Self.defaultWaitTimeout)
    
    loadFromStore(query: query) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
      }
    }
  }
  
  func testUpdateHeroAndFriendsNamesQueryWithVariable() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero(episode:NEWHOPE)": CacheReference(key: "2001")],
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
    ])
    
    let query = HeroAndFriendsNamesQuery(episode: Episode.newhope)
    
    let updateCompletedExpectation = expectation(description: "Update completed")
    
    store.withinReadWriteTransaction({ transaction in
      try transaction.update(query: query) { data in
        data.hero?.friends?.append(.makeDroid(name: "C-3PO"))
      }
    }, completion: { result in
      defer { updateCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [updateCompletedExpectation], timeout: Self.defaultWaitTimeout)
    
    loadFromStore(query: query) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
      }
    }
  }
  
  func testReadAfterUpdateWithinSameTransaction() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    let readAfterUpdateCompletedExpectation = expectation(description: "Read after update completed")
    
    store.withinReadWriteTransaction({ transaction in
      try transaction.update(query: query) { data in
        data.hero?.name = "Artoo"
        data.hero?.friends?.append(.makeDroid(name: "C-3PO"))
      }
      
      let data = try transaction.read(query: query)
      
      XCTAssertEqual(data.hero?.name, "Artoo")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
    }, completion: { result in
      defer { readAfterUpdateCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [readAfterUpdateCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReadHeroDetailsFragmentWithTypeSpecificProperty() throws {
    mergeRecordsIntoCache([
      "2001": ["name": "R2-D2", "__typename": "Droid", "primaryFunction": "Protocol"]
    ])
    
    let readCompletedExpectation = expectation(description: "Read completed")
    
    store.withinReadTransaction({ transaction in
      let r2d2 = try transaction.readObject(ofType: HeroDetails.self, withKey: "2001")
      
      XCTAssertEqual(r2d2.name, "R2-D2")
      XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReadHeroDetailsFragmentWithMissingTypeSpecificProperty() throws {
    mergeRecordsIntoCache([
      "2001": ["name": "R2-D2", "__typename": "Droid"]
    ])
    
    let readCompletedExpectation = expectation(description: "Read completed")
    
    store.withinReadTransaction({ transaction in
      XCTAssertThrowsError(try transaction.readObject(ofType: HeroDetails.self, withKey: "2001")) { error in
        if case let error as GraphQLResultError = error {
          XCTAssertEqual(error.path, ["primaryFunction"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testReadFriendsNamesFragment() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let readCompletedExpectation = expectation(description: "Read completed")
    
    store.withinReadTransaction({ transaction in
      let friendsNamesFragment = try transaction.readObject(ofType: FriendsNames.self, withKey: "2001")
      
      let friendsNames = friendsNamesFragment.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [readCompletedExpectation], timeout: Self.defaultWaitTimeout)
  }
  
  func testUpdateFriendsNamesFragment() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let updateCompletedExpectation = expectation(description: "Update completed")
    
    store.withinReadWriteTransaction({ transaction in
      try transaction.updateObject(ofType: FriendsNames.self, withKey: "2001") { friendsNames in
        friendsNames.friends?.append(.makeDroid(name: "C-3PO"))
      }
    }, completion: { result in
      defer { updateCompletedExpectation.fulfill() }
      XCTAssertSuccessResult(result)
    })
    
    self.wait(for: [updateCompletedExpectation], timeout: Self.defaultWaitTimeout)
    
    loadFromStore(query: HeroAndFriendsNamesQuery()) { result in
      try XCTAssertSuccessResult(result) { graphQLResult in
        XCTAssertEqual(graphQLResult.source, .cache)
        XCTAssertNil(graphQLResult.errors)
        
        let data = try XCTUnwrap(graphQLResult.data)
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
      }
    }
  }

  func test_removeObjectsMatchingPattern_givenPatternNotMatchingKeyCase_deletesCaseInsensitiveMatchingRecords() throws {
    let heroKey = "hero"

    //
    // 1. Merge all required records into the cache with lowercase key
    //

    mergeRecordsIntoCache([
      "QUERY_ROOT": ["\(heroKey.lowercased())": CacheReference(key: "QUERY_ROOT.\(heroKey.lowercased())")],
      "QUERY_ROOT.\(heroKey.lowercased())": ["__typename": "Droid", "name": "R2-D2"]
    ])

    //
    // 2. Attempt to successfully read out the record
    //

    let query = HeroNameQuery()
    let readCompletedExpectation = expectation(description: "Read hero object from cache")

    store.withinReadTransaction({ transaction in
      let data = try transaction.read(query: query)

      XCTAssertEqual(data.hero?.name, "R2-D2")
      XCTAssertEqual(data.hero?.__typename, "Droid")

    }, completion: { result in
      defer { readCompletedExpectation.fulfill() }

      XCTAssertSuccessResult(result)
    })

    waitForExpectations(timeout: Self.defaultWaitTimeout)

    //
    // 3. Remove object matching case insensitive (uppercase) key
    // - This should remove `QUERY_ROOT.hero` using pattern `QUERY_ROOT.HERO`
    //

    let removeRecordsCompletedExpectation = expectation(description: "Remove cache record by key pattern")

    store.withinReadWriteTransaction({ transaction in
      try transaction.removeObjects(matching: "\(heroKey.uppercased())")
    }, completion: { result in
      defer { removeRecordsCompletedExpectation.fulfill() }

      XCTAssertSuccessResult(result)
    })

    waitForExpectations(timeout: Self.defaultWaitTimeout)

    //
    // 4. Attempt to read records after pattern removal - expected FAIL
    //

    let readAfterRemoveCompletedExpectation = expectation(description: "Read from cache after removal by pattern")

    store.withinReadTransaction({ transaction in
      _ = try transaction.read(query: query)

    }, completion: { result in
      defer { readAfterRemoveCompletedExpectation.fulfill() }

      XCTAssertFailureResult(result) { error in
        if let error = error as? GraphQLResultError {
          XCTAssertEqual(error.path, ["hero"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    })

    waitForExpectations(timeout: Self.defaultWaitTimeout)
  }

  func test_removeObjectsMatchingPattern_givenKeyMatchingSubrangePattern_deletesMultipleRecords() throws {

    //
    // 1. Merge all required records into the cache
    //

    mergeRecordsIntoCache([
      "QUERY_ROOT": [
        "hero(episode:NEWHOPE)": CacheReference(key: "1002"),
        "hero(episode:JEDI)": CacheReference(key: "1101"),
        "hero(episode:EMPIRE)": CacheReference(key: "2001")
      ],
      "2001": [
        "id": "2001",
        "name": "R2-D2",
        "__typename": "Droid",
        "friends": [
          CacheReference(key: "1101"),
          CacheReference(key: "1003")
        ]
      ],
      "1101": ["__typename": "Human", "name": "Luke Skywalker", "id": "1101", "friends": []],
      "1002": ["__typename": "Human", "name": "Han Solo", "id": "1002", "friends": []],
      "1003": ["__typename": "Human", "name": "Leia Organa", "id": "1003", "friends": []],
    ])

    //
    // 2. Attempt to successfully read out the three queries
    //

    let readHeroNewHopeCompletedExpectation = expectation(description: "Read hero object for .newhope episode from cache")

    store.withinReadTransaction({ transaction in
      let query = HeroAndFriendsNamesWithIDsQuery(episode: .newhope)
      let data = try transaction.read(query: query)

      XCTAssertEqual(data.hero?.__typename, "Human")
      XCTAssertEqual(data.hero?.name, "Han Solo")

      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, [])

    }, completion: { newHopeResult in
      defer { readHeroNewHopeCompletedExpectation.fulfill() }

      XCTAssertSuccessResult(newHopeResult)
    })

    let readHeroJediCompletedExpectation = expectation(description: "Read hero object for .jedi episode from cache")

    store.withinReadTransaction({ transaction in
      let query = HeroAndFriendsNamesWithIDsQuery(episode: .jedi)
      let data = try transaction.read(query: query)

      XCTAssertEqual(data.hero?.__typename, "Human")
      XCTAssertEqual(data.hero?.name, "Luke Skywalker")

      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, [])

    }, completion: { jediResult in
      defer { readHeroJediCompletedExpectation.fulfill() }

      XCTAssertSuccessResult(jediResult)
    })

    let readHeroEmpireCompletedExpectation = expectation(description: "Read hero object for .empire episode from cache")

    store.withinReadTransaction({ transaction in
      let query = HeroAndFriendsNamesWithIDsQuery(episode: .empire)
      let data = try transaction.read(query: query)

      XCTAssertEqual(data.hero?.__typename, "Droid")
      XCTAssertEqual(data.hero?.name, "R2-D2")

      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Leia Organa"])

    }, completion: { empireResult in
      defer { readHeroEmpireCompletedExpectation.fulfill() }

      XCTAssertSuccessResult(empireResult)
    })

    waitForExpectations(timeout: Self.defaultWaitTimeout)

    //
    // 3. Remove all objects matching the pattern `100`
    // - This will remove `1002` (Han Solo, hero for the .newhope episode)
    // - This will remove `1003` (Leia Organa, friend of the hero in .empire episode)
    //

    let removeFromCacheCompletedExpectation = expectation(description: "Hero objects removed from cache by pattern")

    store.withinReadWriteTransaction({ transaction in
      try transaction.removeObjects(matching: "100")
    }, completion: { result in
      defer { removeFromCacheCompletedExpectation.fulfill() }

      XCTAssertSuccessResult(result)
    })

    waitForExpectations(timeout: Self.defaultWaitTimeout)

    //
    // 4. Attempt to read records after pattern removal
    // - .newhope episode query expected to FAIL on the `hero` path
    // - .jedi episdoe query expected to SUCCEED
    // - .empire episode query expected to FAIL on the `hero.friends` path
    //

    let readHeroNewHopeAfterRemoveCompletedExpectation = expectation(description: "Read removed hero object for .newhope episode from cache")

    store.withinReadTransaction({ transaction in
      let query = HeroAndFriendsNamesWithIDsQuery(episode: .newhope)
      _ = try transaction.read(query: query)

    }, completion: { newHopeResult in
      defer { readHeroNewHopeAfterRemoveCompletedExpectation.fulfill() }

      XCTAssertFailureResult(newHopeResult) { error in
        if let error = error as? GraphQLResultError {
          XCTAssertEqual(error.path, ["hero"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    })

    let readHeroJediAfterRemoveCompletedExpectation = expectation(description: "Read removed hero object for .jedi episode from cache")

    store.withinReadTransaction({ transaction in
      let query = HeroAndFriendsNamesWithIDsQuery(episode: .jedi)
      let data = try transaction.read(query: query)

      XCTAssertEqual(data.hero?.__typename, "Human")
      XCTAssertEqual(data.hero?.name, "Luke Skywalker")

    }, completion: { jediResult in
      defer { readHeroJediAfterRemoveCompletedExpectation.fulfill() }

      XCTAssertSuccessResult(jediResult)
    })

    let readHeroEmpireAfterRemoveCompletedExpectation = expectation(description: "Read removed hero object for .empire episode from cache")

    store.withinReadTransaction({ transaction in
      let query = HeroAndFriendsNamesWithIDsQuery(episode: .empire)
      _ = try transaction.read(query: query)

    }, completion: { empireResult in
      defer { readHeroEmpireAfterRemoveCompletedExpectation.fulfill() }

      XCTAssertFailureResult(empireResult) { error in
        if let error = error as? GraphQLResultError {
          XCTAssertEqual(error.path, ["hero.friends"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    })

    waitForExpectations(timeout: Self.defaultWaitTimeout)
  }
}

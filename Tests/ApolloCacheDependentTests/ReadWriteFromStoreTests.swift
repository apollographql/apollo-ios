import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class ReadWriteFromStoreTests: XCTestCase, CacheTesting {

  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  var defaultWaitTimeout: TimeInterval = 5
  
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
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery()
        
    let readExpectation = expectSuccessfulResult(description: "Read complete") { handler in
      store.withinReadTransaction({ transaction in
        let data = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.__typename, "Droid")
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }, completion: handler)
    }
    
    self.wait(for: [readExpectation], timeout: defaultWaitTimeout)
  }
  
  func testReadHeroNameQueryWithVariable() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero(episode:JEDI)": Reference(key: "hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery(episode: .jedi)
    
    let readExpectation = expectSuccessfulResult(description: "Read complete") { handler in
      store.withinReadTransaction({ transaction in
        let data = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.__typename, "Droid")
        XCTAssertEqual(data.hero?.name, "R2-D2")
      }, completion: handler)
    }
    
    self.wait(for: [readExpectation], timeout: defaultWaitTimeout)
  }
  
  func testReadHeroNameQueryWithMissingName() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid"]
    ])
    
    let query = HeroNameQuery()
    
    let readExpectation = expectSuccessfulResult(description: "Read complete") { handler in
      store.withinReadTransaction({ transaction in
        XCTAssertThrowsError(try transaction.read(query: query)) { error in
          if case let error as GraphQLResultError = error {
            XCTAssertEqual(error.path, ["hero", "name"])
            XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
          } else {
            XCTFail("Unexpected error: \(error)")
          }
        }
      }, completion: handler)
    }
    
    self.wait(for: [readExpectation], timeout: defaultWaitTimeout)
  }
  
  func testUpdateHeroNameQuery() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero": Reference(key: "QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": ["__typename": "Droid", "name": "R2-D2"]
    ])
    
    let query = HeroNameQuery()
    
    let updateExpectation = expectSuccessfulResult(description: "Update complete") { handler in
      store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: query) { data in
          data.hero?.name = "Artoo"
        }
      }, completion: handler)
    }
    
    self.wait(for: [updateExpectation], timeout: defaultWaitTimeout)
    
    loadFromStore(query: query) { result in
      let graphQLResult = try result.get()
      XCTAssertEqual(graphQLResult.source, .cache)
      XCTAssertNil(graphQLResult.errors)
      
      let data = try XCTUnwrap(graphQLResult.data)
      XCTAssertEqual(data.hero?.name, "Artoo")
    }
  }
  
  func testWriteHeroNameQueryWhenErrorIsThrown() throws {
    let writeExpectation = self.expectation(description: "Write complete")
    
    store.withinReadWriteTransaction({ transaction in
      let data = HeroNameQuery.Data(unsafeResultMap: [:])
      try transaction.write(data: data, forQuery: HeroNameQuery(episode: nil))
    }, completion: { result in
      defer {
        writeExpectation.fulfill()
      }
      
      XCTAssertFailureResult(result) { error in
        if let error = error as? GraphQLResultError {
          XCTAssertEqual(error.path, ["hero"])
          XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
        } else {
          XCTFail("Unexpected error: \(error)")
        }
      }
    })
    
    self.wait(for: [writeExpectation], timeout: defaultWaitTimeout)
  }
  
  func testReadHeroAndFriendsNamesQuery() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    let readExpectation = expectSuccessfulResult(description: "Read complete") { handler in
      store.withinReadTransaction({ transaction in
        let data = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }, completion: handler)
    }
    
    self.wait(for: [readExpectation], timeout: defaultWaitTimeout)
  }
  
  func testUpdateHeroAndFriendsNamesQuery() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let query = HeroAndFriendsNamesQuery()
    
    let updateExpectation = expectSuccessfulResult(description: "Transaction updated") { handler in
      store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: query) { data in
          data.hero?.friends?.append(.makeDroid(name: "C-3PO"))
        }
      }, completion: handler)
    }
    
    self.wait(for: [updateExpectation], timeout: defaultWaitTimeout)
    
    loadFromStore(query: query) { result in
      let graphQLResult = try result.get()
      XCTAssertEqual(graphQLResult.source, .cache)
      XCTAssertNil(graphQLResult.errors)
      
      let data = try XCTUnwrap(graphQLResult.data)
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
    }
  }
  
  func testUpdateHeroAndFriendsNamesQueryWithVariable() throws {
    mergeRecordsIntoCache([
      "QUERY_ROOT": ["hero(episode:NEWHOPE)": Reference(key: "2001")],
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
    ])
    
    let query = HeroAndFriendsNamesQuery(episode: Episode.newhope)
    
    let updateExpectation = expectSuccessfulResult(description: "Update complete") { handler in
      store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: query) { data in
          data.hero?.friends?.append(.makeDroid(name: "C-3PO"))
        }
      }, completion: handler)
    }
    
    self.wait(for: [updateExpectation], timeout: defaultWaitTimeout)
    
    loadFromStore(query: query) { result in
      let graphQLResult = try result.get()
      XCTAssertEqual(graphQLResult.source, .cache)
      XCTAssertNil(graphQLResult.errors)
      
      let data = try XCTUnwrap(graphQLResult.data)
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
    }
  }
  
  func testReadHeroDetailsFragmentWithTypeSpecificProperty() throws {
    mergeRecordsIntoCache([
      "2001": ["name": "R2-D2", "__typename": "Droid", "primaryFunction": "Protocol"]
    ])
    
    let readExpectation = expectSuccessfulResult(description: "Read complete") { handler in
      store.withinReadTransaction({ transaction in
        let r2d2 = try transaction.readObject(ofType: HeroDetails.self, withKey: "2001")
        
        XCTAssertEqual(r2d2.name, "R2-D2")
        XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
      }, completion: handler)
    }
    
    self.wait(for: [readExpectation], timeout: defaultWaitTimeout)
  }
  
  func testReadHeroDetailsFragmentWithMissingTypeSpecificProperty() throws {
    mergeRecordsIntoCache([
      "2001": ["name": "R2-D2", "__typename": "Droid"]
    ])
    
    let readExpectation = expectSuccessfulResult(description: "Read complete") { handler in
      store.withinReadTransaction({ transaction in
        XCTAssertThrowsError(try transaction.readObject(ofType: HeroDetails.self, withKey: "2001")) { error in
          if case let error as GraphQLResultError = error {
            XCTAssertEqual(error.path, ["primaryFunction"])
            XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
          } else {
            XCTFail("Unexpected error: \(error)")
          }
        }
      }, completion: handler)
    }
    
    self.wait(for: [readExpectation], timeout: defaultWaitTimeout)
  }
  
  func testReadFriendsNamesFragment() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let readExpectation = expectSuccessfulResult(description: "Read complete") { handler in
      store.withinReadTransaction({ transaction in
        let friendsNamesFragment = try transaction.readObject(ofType: FriendsNames.self, withKey: "2001")
        
        let friendsNames = friendsNamesFragment.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      }, completion: handler)
    }
    
    self.wait(for: [readExpectation], timeout: defaultWaitTimeout)
  }
  
  func testUpdateFriendsNamesFragment() throws {
    mergeRecordsIntoCache([
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
    ])
    
    let updateExpecation = expectSuccessfulResult(description: "Update complete") { handler in
      store.withinReadWriteTransaction({ transaction in
        try transaction.updateObject(ofType: FriendsNames.self, withKey: "2001") { friendsNames in
          friendsNames.friends?.append(.makeDroid(name: "C-3PO"))
        }
      }, completion: handler)
    }
    
    self.wait(for: [updateExpecation], timeout: defaultWaitTimeout)
    
    loadFromStore(query: HeroAndFriendsNamesQuery()) { result in
      let graphQLResult = try result.get()
      XCTAssertEqual(graphQLResult.source, .cache)
      XCTAssertNil(graphQLResult.errors)
      
      let data = try XCTUnwrap(graphQLResult.data)
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
    }
  }
  
  // MARK: - Helpers
  
  private func loadFromStore<Query: GraphQLQuery>(query: Query, file: StaticString = #filePath, line: UInt = #line, resultHandler: @escaping AsyncResultObserver<GraphQLResult<Query.Data>, Error>.ResultHandler) {
    let resultObserver = makeResultObserver(for: query, file: file, line: line)
        
    let expectation = resultObserver.expectation(description: "Loaded query from store", file: file, line: line, resultHandler: resultHandler)
    
    store.load(query: query, resultHandler: resultObserver.handler)
    
    wait(for: [expectation], timeout: defaultWaitTimeout)
  }
}

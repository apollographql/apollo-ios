import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class ReadWriteFromStoreTests: XCTestCase, CacheTesting {
  var cacheType: TestCacheProvider.Type {
    InMemoryTestCacheProvider.self
  }
  
  func testReadHeroNameQuery() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ]
    let expectation = self.expectation(description: "transaction'd")
    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroNameQuery()
      
      store.withinReadTransaction({ transaction in
        let data = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.__typename, "Droid")
        XCTAssertEqual(data.hero?.name, "R2-D2")
        expectation.fulfill()
      })
    }
    
    self.waitForExpectations(timeout: 1, handler: nil)
  }
  
  func testReadHeroNameQueryWithVariable() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero(episode:JEDI)": Reference(key: "hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ]
    
    let expectation = self.expectation(description: "transaction'd")
    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      
      let query = HeroNameQuery(episode: .jedi)
     
      store.withinReadTransaction({ transaction in
        let data = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.__typename, "Droid")
        XCTAssertEqual(data.hero?.name, "R2-D2")
        expectation.fulfill()
      })
    }
    
    self.waitForExpectations(timeout: 1, handler: nil)
  }

  func testReadHeroNameQueryWithMissingName() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid"]
    ]
    
    let expectation = self.expectation(description: "transaction'd")
    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      
      let query = HeroNameQuery()
      
      store.withinReadTransaction({ transaction in
        XCTAssertThrowsError(try transaction.read(query: query)) { error in
          if case let error as GraphQLResultError = error {
            XCTAssertEqual(error.path, ["hero", "name"])
            XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
          } else {
            XCTFail("Unexpected error: \(error)")
          }
          expectation.fulfill()
        }
      })
      
      self.waitForExpectations(timeout: 1, handler: nil)
    }
  }
  
  func testUpdateHeroNameQuery() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": ["__typename": "Droid", "name": "R2-D2"]
    ]

    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroNameQuery()
      let expectation = self.expectation(description: "transaction'd")

      store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: query) { (data: inout HeroNameQuery.Data) in
          data.hero?.name = "Artoo"
          expectation.fulfill()
        }
      })
      
      self.waitForExpectations(timeout: 1, handler: nil)

      let result = try await(store.load(query: query))

      let data = try XCTUnwrap(result.data)
      XCTAssertEqual(data.hero?.name, "Artoo")
    }
  }

  func testWriteHeroNameQueryWhenWriteErrorIsThrown() throws {
    let expectation = self.expectation(description: "transaction'd")
    do {
      withCache(initialRecords: nil) { (cache) in
        let store = ApolloStore(cache: cache)

        store.withinReadWriteTransaction({ transaction in
          let data = HeroNameQuery.Data(unsafeResultMap: [:])
          try transaction.write(data: data, forQuery: HeroNameQuery(episode: nil))
        }, completion: { result in
          defer {
            expectation.fulfill()
          }
          switch result {
          case .success:
            XCTFail("write should fail")
          case .failure(let error):
            guard
              let error = error as? GraphQLResultError,
              let jsonError = error.underlying as? JSONDecodingError else {
                XCTFail("unexpected error")
                return
            }
            
            switch jsonError {
            case .missingValue: break
            default: XCTFail("unexpected error")
            }
          }
        })
      }
    }
    
    self.waitForExpectations(timeout: 1, handler: nil)
  }
  
  func testReadHeroAndFriendsNamesQuery() throws {
    let initialRecords: RecordSet = [
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
    
    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
    
      let query = HeroAndFriendsNamesQuery()
      
      let expectation = self.expectation(description: "transaction'd")
      store.withinReadTransaction({ transaction in
        let data = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        expectation.fulfill()
      })
      
      self.waitForExpectations(timeout: 1, handler: nil)
    }
  }
  
  func testUpdateHeroAndFriendsNamesQuery() throws {
    let initialRecords: RecordSet = [
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

    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroAndFriendsNamesQuery()

      let expectation = self.expectation(description: "transaction'd")
      store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: query) { (data: inout HeroAndFriendsNamesQuery.Data) in
          data.hero?.friends?.append(.makeDroid(name: "C-3PO"))
          expectation.fulfill()
        }
      })
      self.waitForExpectations(timeout: 1, handler: nil)
      
      let result = try await(store.load(query: query))
      let data = try XCTUnwrap(result.data)
      
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
    }
  }
    
  func testUpdateHeroAndFriendsNamesQueryWithVariable() throws {
    let initialRecords: RecordSet = [
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
      ]

    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroAndFriendsNamesQuery(episode: Episode.newhope)

      let expectation = self.expectation(description: "transaction'd")
      store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: query) { (data: inout HeroAndFriendsNamesQuery.Data) in
          data.hero?.friends?.append(.makeDroid(name: "C-3PO"))
          expectation.fulfill()
        }
      })
      self.waitForExpectations(timeout: 1, handler: nil)

      let result = try await(store.load(query: query))
      let data = try XCTUnwrap(result.data)

      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
    }
  }

  func testReadHeroDetailsFragmentWithTypeSpecificProperty() throws {
    let initialRecords: RecordSet = [
      "2001": ["name": "R2-D2", "__typename": "Droid", "primaryFunction": "Protocol"]
    ]
    
    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      
      let expectation = self.expectation(description: "transaction'd")
      store.withinReadTransaction({ transaction in
        let r2d2 = try transaction.readObject(ofType: HeroDetails.self, withKey: "2001")
        
        XCTAssertEqual(r2d2.name, "R2-D2")
        XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
        expectation.fulfill()
      })
      
      self.waitForExpectations(timeout: 1, handler: nil)
    }
  }
  
  func testReadHeroDetailsFragmentWithMissingTypeSpecificProperty() throws {
    let initialRecords: RecordSet = [
      "2001": ["name": "R2-D2", "__typename": "Droid"]
    ]
    
    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      
      let expectation = self.expectation(description: "transaction'd")
      store.withinReadTransaction({ transaction in
        XCTAssertThrowsError(try transaction.readObject(ofType: HeroDetails.self, withKey: "2001")) { error in
          if case let error as GraphQLResultError = error {
            XCTAssertEqual(error.path, ["primaryFunction"])
            XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
          } else {
            XCTFail("Unexpected error: \(error)")
          }
          
          expectation.fulfill()
        }
      })
      self.waitForExpectations(timeout: 1, handler: nil)
    }
  }
  
  func testReadFriendsNamesFragment() throws {
    let initialRecords: RecordSet = [
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

    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let expectation = self.expectation(description: "transaction'd")
      store.withinReadTransaction({ transaction in
        let friendsNamesFragment = try transaction.readObject(ofType: FriendsNames.self, withKey: "2001")

        let friendsNames = friendsNamesFragment.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        expectation.fulfill()
      })
      
      self.waitForExpectations(timeout: 1, handler: nil)
    }
  }
  
  func testUpdateFriendsNamesFragment() throws {
    let initialRecords: RecordSet = [
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

    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let expectation = self.expectation(description: "transaction'd")
      store.withinReadWriteTransaction({ transaction in
        try transaction.updateObject(ofType: FriendsNames.self, withKey: "2001") { (friendsNames: inout FriendsNames) in
          friendsNames.friends?.append(.makeDroid(name: "C-3PO"))
          expectation.fulfill()
        }
      })
      self.waitForExpectations(timeout: 1, handler: nil)

      let result = try await(store.load(query: HeroAndFriendsNamesQuery()))
      let data = try XCTUnwrap(result.data)

      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
    }
  }
}

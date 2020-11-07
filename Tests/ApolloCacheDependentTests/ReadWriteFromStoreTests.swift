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
    let readExpectation = self.expectation(description: "Read complete")
    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroNameQuery()
      
      store.withinReadTransaction({ transaction in
        let (data, _) = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.__typename, "Droid")
        XCTAssertEqual(data.hero?.name, "R2-D2")
        readExpectation.fulfill()
      })
    }
    
    self.wait(for: [readExpectation], timeout: 1)
  }
  
  func testReadHeroNameQueryWithVariable() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero(episode:JEDI)": Reference(key: "hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ]
    
    let readExpectation = self.expectation(description: "Read complete")
    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      
      let query = HeroNameQuery(episode: .jedi)
     
      store.withinReadTransaction({ transaction in
        let (data, _) = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.__typename, "Droid")
        XCTAssertEqual(data.hero?.name, "R2-D2")
        readExpectation.fulfill()
      })
    }
    
    self.wait(for: [readExpectation], timeout: 1)
  }

  func testReadHeroNameQueryWithMissingName() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid"]
    ]
    
    let readExpectation = self.expectation(description: "Read complete")
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
          readExpectation.fulfill()
        }
      })
      
      self.wait(for: [readExpectation], timeout: 1)
    }
  }
  
  func testUpdateHeroNameQuery() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": ["__typename": "Droid", "name": "R2-D2"]
    ]

    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroNameQuery()
      let updateExpectation = self.expectation(description: "Update complete")

      store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: query) { (data: inout HeroNameQuery.Data) in
          data.hero?.name = "Artoo"
          updateExpectation.fulfill()
        }
      })
      self.wait(for: [updateExpectation], timeout: 1)

      let loadExpectation = self.expectation(description: "Data loaded")
      store.load(query: query) { result in
        defer {
          loadExpectation.fulfill()
        }
        
        switch result {
        case .success(let graphQLResult):
          XCTAssertEqual(graphQLResult.data?.hero?.name, "Artoo")
        case .failure(let error):
          XCTFail("Unexpected error loading: \(error)")
        }
      }
      self.wait(for: [loadExpectation], timeout: 1)
    }
  }

  func testWriteHeroNameQueryWhenWriteErrorIsThrown() throws {
    let writeExpectation = self.expectation(description: "Write complete")
    withCache(initialRecords: nil) { (cache) in
      let store = ApolloStore(cache: cache)
      
      store.withinReadWriteTransaction({ transaction in
        let data = HeroNameQuery.Data(unsafeResultMap: [:])
        try transaction.write(data: data, forQuery: HeroNameQuery(episode: nil))
      }, completion: { result in
        defer {
          writeExpectation.fulfill()
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
    
    self.wait(for: [writeExpectation], timeout: 1)
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
      
      let readExpectation = self.expectation(description: "Read complete")
      store.withinReadTransaction({ transaction in
        let (data, _) = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        readExpectation.fulfill()
      })
      
      self.wait(for: [readExpectation], timeout: 1)
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

    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroAndFriendsNamesQuery()

      let updateExpectation = self.expectation(description: "Transaction updated")
      store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: query) { (data: inout HeroAndFriendsNamesQuery.Data) in
          data.hero?.friends?.append(.makeDroid(name: "C-3PO"))
          updateExpectation.fulfill()
        }
      })
      self.wait(for: [updateExpectation], timeout: 1)
      
      let loadExpectation = self.expectation(description: "Query reloaded")
      store.load(query: query) { result in
        defer {
          loadExpectation.fulfill()
        }

        switch result {
        case .success(let graphQLResult):
          guard let data = graphQLResult.data else {
            XCTFail("No data!")
            return
          }
          
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
        case .failure(let error):
          XCTFail("Unexpected error loading: \(error)")
        }
      }
      
      self.wait(for: [loadExpectation], timeout: 1)
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

    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroAndFriendsNamesQuery(episode: Episode.newhope)

      let updateExpectation = self.expectation(description: "Update complete")
      store.withinReadWriteTransaction({ transaction in
        try transaction.update(query: query) { (data: inout HeroAndFriendsNamesQuery.Data) in
          data.hero?.friends?.append(.makeDroid(name: "C-3PO"))
          updateExpectation.fulfill()
        }
      })
      self.wait(for: [updateExpectation], timeout: 1)

      let loadExpectation = self.expectation(description: "Query loaded")
      store.load(query: query) { result in
        defer {
          loadExpectation.fulfill()
        }
        
        switch result {
        case .success(let graphQLResult):
          guard let data = graphQLResult.data else {
            XCTFail("No data!")
            return
          }

          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
        case .failure(let error):
          XCTFail("Unexpected error loading: \(error)")
        }
      }
      
      self.wait(for: [loadExpectation], timeout: 1)
    }
  }

  func testReadHeroDetailsFragmentWithTypeSpecificProperty() throws {
    let initialRecords: RecordSet = [
      "2001": ["name": "R2-D2", "__typename": "Droid", "primaryFunction": "Protocol"]
    ]
    
    withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      
      let readExpectation = self.expectation(description: "Read complete")
      store.withinReadTransaction({ transaction in
        let (r2d2, _) = try transaction.readObject(ofType: HeroDetails.self, withKey: "2001")
        
        XCTAssertEqual(r2d2.name, "R2-D2")
        XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
        readExpectation.fulfill()
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
      
      let readExpectation = self.expectation(description: "Read complete")
      store.withinReadTransaction({ transaction in
        XCTAssertThrowsError(try transaction.readObject(ofType: HeroDetails.self, withKey: "2001")) { error in
          if case let error as GraphQLResultError = error {
            XCTAssertEqual(error.path, ["primaryFunction"])
            XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
          } else {
            XCTFail("Unexpected error: \(error)")
          }
          
          readExpectation.fulfill()
        }
      })
      
      self.wait(for: [readExpectation], timeout: 1)
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

      let readExpectation = self.expectation(description: "Read complete")
      store.withinReadTransaction({ transaction in
        let (friendsNamesFragment, _) = try transaction.readObject(ofType: FriendsNames.self, withKey: "2001")

        let friendsNames = friendsNamesFragment.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
        readExpectation.fulfill()
      })
      
      self.wait(for: [readExpectation], timeout: 1)
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

    withCache(initialRecords: initialRecords) { cache in
      let store = ApolloStore(cache: cache)

      let updateExpecation = self.expectation(description: "Update complete")
      store.withinReadWriteTransaction({ transaction in
        try transaction.updateObject(ofType: FriendsNames.self, withKey: "2001") { (friendsNames: inout FriendsNames) in
          friendsNames.friends?.append(.makeDroid(name: "C-3PO"))
          updateExpecation.fulfill()
        }
      })
      self.wait(for: [updateExpecation], timeout: 1)
      
      let loadExpectation = self.expectation(description: "Load complete")
      store.load(query: HeroAndFriendsNamesQuery()) { result in
        defer {
          loadExpectation.fulfill()
        }
        switch result {
        case .success(let graphQLResult):
          guard let data = graphQLResult.data else {
            XCTFail("No data received!")
            return
          }
          XCTAssertEqual(data.hero?.name, "R2-D2")
          let friendsNames = data.hero?.friends?.compactMap { $0?.name }
          XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
        case .failure(let error):
          XCTFail("Unexpected error loading: \(error)")
        }
      }
      
      self.wait(for: [loadExpectation], timeout: 1)
    }
  }

  func testReceivedAtAfterUpdateQuery() throws {
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let initialRecords = RecordSet([
      "QUERY_ROOT": (["hero": Reference(key: "QUERY_ROOT.hero")], yesterday),
      "QUERY_ROOT.hero": (["__typename": "Droid", "name": "R2-D2"], yesterday)
    ])

    try self.withCache(initialRecords: initialRecords) {
      let store = ApolloStore(cache: $0)

      let query = HeroNameQuery()
      let expectation = self.expectation(description: "transaction'd")

      store.withinReadWriteTransaction { transaction in
        try transaction.update(query: query) { data in
          data.hero?.name = "Artoo"
          expectation.fulfill()
        }
      }

      self.waitForExpectations(timeout: 1)

      // the query age is that of the oldest row read, so still yesterday
      let result = try store.load(query: query).await()
      XCTAssertEqual(
        Calendar.current.compare(result.context.resultAge, to: yesterday, toGranularity: .minute),
        .orderedSame
      )

      // verify that the age of the modified row is from just now
      let cacheReadExpectation = self.expectation(description: "cacheReadExpectation")
      store.withinReadTransaction(
        {
          return try $0.readObject(ofType: HeroNameQuery.Data.Hero.self, withKey: "QUERY_ROOT.hero")
        },
        completion: {
          do {
            let (_, context) = try $0.get()
            XCTAssertEqual(
              Calendar.current.compare(Date(), to: context.resultAge, toGranularity: .minute),
              .orderedSame
            )
            cacheReadExpectation.fulfill()
          } catch {
            XCTAssertThrowsError(error)
          }
        }
      )

      self.waitForExpectations(timeout: 1)
    }
  }
}

import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class ReadWriteFromStoreTests: XCTestCase {
  func testReadHeroNameQuery() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ]

    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroNameQuery()

      try await(store.withinReadTransaction { transaction in
        let data = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.__typename, "Droid")
        XCTAssertEqual(data.hero?.name, "R2-D2")
      })
    }
  }
  
  func testReadHeroNameQueryWithVariable() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero(episode:JEDI)": Reference(key: "hero(episode:JEDI)")],
      "hero(episode:JEDI)": ["__typename": "Droid", "name": "R2-D2"]
    ]
    
    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      
      let query = HeroNameQuery(episode: .jedi)
      
      try await(store.withinReadTransaction { transaction in
        let data = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.__typename, "Droid")
        XCTAssertEqual(data.hero?.name, "R2-D2")
      })
    }
  }
  
  func testReadHeroNameQueryWithMissingName() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid"]
    ]
    
    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      
      let query = HeroNameQuery()
      
      try await(store.withinReadTransaction { transaction in
        XCTAssertThrowsError(try transaction.read(query: query)) { error in
          if case let error as GraphQLResultError = error {
            XCTAssertEqual(error.path, ["hero", "name"])
            XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
          } else {
            XCTFail("Unexpected error: \(error)")
          }
        }
      })
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

      try await(store.withinReadWriteTransaction { transaction in
        try transaction.update(query: query) { (data: inout HeroNameQuery.Data) in
          data.hero?.name = "Artoo"
        }
      })

      let result = try await(store.load(query: query))

      guard let data = result.data else { XCTFail(); return }
      XCTAssertEqual(data.hero?.name, "Artoo")
    }
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
    
    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
    
      let query = HeroAndFriendsNamesQuery()
      
      try await(store.withinReadTransaction { transaction in
        let data = try transaction.read(query: query)
        
        XCTAssertEqual(data.hero?.name, "R2-D2")
        let friendsNames = data.hero?.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      })
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

      try await(store.withinReadWriteTransaction { transaction in
        try transaction.update(query: query) { (data: inout HeroAndFriendsNamesQuery.Data) in
          data.hero?.friends?.append(.makeDroid(name: "C-3PO"))
        }
      })
      
      let result = try await(store.load(query: query))
      guard let data = result.data else { XCTFail(); return }
      
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
    }
  }
  
  func testReadHeroDetailsFragmentWithTypeSpecificProperty() throws {
    let initialRecords: RecordSet = [
      "2001": ["name": "R2-D2", "__typename": "Droid", "primaryFunction": "Protocol"]
    ]
    
    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      
      try await(store.withinReadTransaction { transaction in
        let r2d2 = try transaction.readObject(ofType: HeroDetails.self, withKey: "2001")
        
        XCTAssertEqual(r2d2.name, "R2-D2")
        XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
      })
    }
  }
  
  func testReadHeroDetailsFragmentWithMissingTypeSpecificProperty() throws {
    let initialRecords: RecordSet = [
      "2001": ["name": "R2-D2", "__typename": "Droid"]
    ]
    
    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      
      try await(store.withinReadTransaction { transaction in
        XCTAssertThrowsError(try transaction.readObject(ofType: HeroDetails.self, withKey: "2001")) { error in
          if case let error as GraphQLResultError = error {
            XCTAssertEqual(error.path, ["primaryFunction"])
            XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
          } else {
            XCTFail("Unexpected error: \(error)")
          }
        }
      })
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

    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      try await(store.withinReadTransaction { transaction in
        let friendsNamesFragment = try transaction.readObject(ofType: FriendsNames.self, withKey: "2001")

        let friendsNames = friendsNamesFragment.friends?.compactMap { $0?.name }
        XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
      })
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

      try await(store.withinReadWriteTransaction { transaction in
        try transaction.updateObject(ofType: FriendsNames.self, withKey: "2001") { (friendsNames: inout FriendsNames) in
          friendsNames.friends?.append(.makeDroid(name: "C-3PO"))
        }
      })

      let result = try await(store.load(query: HeroAndFriendsNamesQuery()))
      guard let data = result.data else { XCTFail(); return }

      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
    }
  }
  
  func testDeleteFriend() throws {
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
      
      try await(store.withinReadWriteTransaction { transaction in
        transaction.delete(withId: "1000")
      })
      
      let result = try await(store.load(query: HeroAndFriendsNamesQuery()))
      guard let data = result.data else { XCTFail(); return }
      
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.compactMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Han Solo", "Leia Organa"])
    }
  }
  
  func testDeleteFriendOfFriend() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "2001")],
      "2001": [
        "name": "R2-D2",
        "id": "2001",
        "__typename": "Droid",
        "friends": [
          Reference(key: "1000"),
          Reference(key: "1002"),
          Reference(key: "1003")
        ]
      ],
      "1000": ["__typename": "Human", "id": "1000", "name": "Luke Skywalker", "friends": [
        Reference(key: "1002"),
        Reference(key: "1003"),
        Reference(key: "2000"),
        Reference(key: "2001")
        ]
      ],
    "1002": ["__typename": "Human", "id": "1002", "name": "Han Solo", "friends": [
        Reference(key: "1000"),
        Reference(key: "1003"),
        Reference(key: "2001")
        ]
      ],
    "1003": ["__typename": "Human", "id": "1003", "name": "Leia Organa", "friends": [
        Reference(key: "1000"),
        Reference(key: "1002"),
        Reference(key: "2000"),
        Reference(key: "2001")
        ]
      ],
    "2000": ["__typename": "Droid", "name": "C-3PO", "id": "2000"]
      ]
    
    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)
      
      var result = try await(store.load(query: HeroFriendsOfFriendsNamesQuery()))
      guard let beforeData = result.data else { XCTFail(); return }
      
      try await(store.withinReadWriteTransaction { transaction in
        transaction.delete(withId: "1000")
      })
      
      result = try await(store.load(query: HeroFriendsOfFriendsNamesQuery()))
      guard let data = result.data else { XCTFail(); return }
      
      let friendsFriendsNames = data.hero?.friends?.reduce(Set<String>(), { set, friend in
        guard let names = friend?.friends?.compactMap({ $0?.name }) else { return set }
        return set.union(names)
      })
      XCTAssertFalse(friendsFriendsNames!.contains("Luke Skywalker"))
    }
  }
}

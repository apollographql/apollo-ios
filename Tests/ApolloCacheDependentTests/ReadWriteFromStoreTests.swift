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
  
  func testUpdateHeroNameQuery() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": ["__typename": "Droid", "name": "R2-D2"]
    ]

    try withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroNameQuery()

      try await(store.withinReadWriteTransaction { transaction in
        var data = try transaction.read(query: query)
        data.hero?.name = "Artoo"
        try transaction.write(data: data, forQuery: query)
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
        let friendsNames = data.hero?.friends?.flatMap { $0?.name }
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
        var data = try transaction.read(query: query)
        data.hero?.friends?.append(.init(__typename: "Droid", name: "C-3PO"))
        try transaction.write(data: data, forQuery: query)
      })
      
      let result = try await(store.load(query: query))
      guard let data = result.data else { XCTFail(); return }
      
      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
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
        let friendsNamesFragment = try transaction.readFragment(ofType: FriendsNames.self, withKey: "2001")

        let friendsNames = friendsNamesFragment.friends?.flatMap { $0?.name }
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
        var friendsNamesFragment = try transaction.readFragment(ofType: FriendsNames.self, withKey: "2001")
        friendsNamesFragment.friends?.append(.init(__typename: "Droid", name: "C-3PO"))
        try transaction.write(fragment: friendsNamesFragment, withKey: "2001")
      })

      let result = try await(store.load(query: HeroAndFriendsNamesQuery()))
      guard let data = result.data else { XCTFail(); return }

      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
    }
  }
}

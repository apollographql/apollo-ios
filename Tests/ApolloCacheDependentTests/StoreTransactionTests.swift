import XCTest
@testable import Apollo
import StarWarsAPI

class StoreTransactionTests: XCTestCase {

  func testReadHeroNameQuery() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "hero")],
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ]

    TestCacheProvider.withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroNameQuery()

      try! await(store.withinReadTransaction { transaction in
        let data = try transaction.readObject(forQuery: query)

        XCTAssertEqual(data, ["hero": ["__typename": "Droid", "name": "R2-D2"]])
      })
    }
  }
  
  func testUpdateHeroNameQuery() throws {
    let initialRecords: RecordSet = [
      "QUERY_ROOT": ["hero": Reference(key: "QUERY_ROOT.hero")],
      "QUERY_ROOT.hero": ["__typename": "Droid", "name": "R2-D2"]
    ]

    TestCacheProvider.withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroNameQuery()

      try! await(store.withinReadWriteTransaction { transaction in
        var data = try! transaction.readObject(forQuery: query)
        data[keyPath: "hero.name"] = "Artoo"
        try transaction.write(object: data, forQuery: query)
      })

      let result = try! await(store.load(query: query))

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

    TestCacheProvider.withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroAndFriendsNamesQuery()

      try! await(store.withinReadTransaction { transaction in
        let object = try! transaction.readObject(forQuery: query)

        XCTAssertEqual(object, [
          "hero": [
            "name": "R2-D2",
            "__typename": "Droid",
            "friends": [
              ["__typename": "Human", "name": "Luke Skywalker"],
              ["__typename": "Human", "name": "Han Solo"],
              ["__typename": "Human", "name": "Leia Organa"]
            ]
          ]
          ])
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

    TestCacheProvider.withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      let query = HeroAndFriendsNamesQuery()

      try! await(store.withinReadWriteTransaction { transaction in
        var data = try! transaction.readObject(forQuery: query)
        data[arrayAt: "hero.friends"]?.append(["__typename": "Droid", "name": "C-3PO"])
        try! transaction.write(object: data, forQuery: query)
      })

      let result = try! await(store.load(query: query))
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

    TestCacheProvider.withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      try! await(store.withinReadTransaction { transaction in
        let friendsNames = try! transaction.readObject(forFragment: FriendsNames.self, withKey: "2001")

        XCTAssertEqual(friendsNames, [
          "__typename": "Droid",
          "friends": [
            ["__typename": "Human", "name": "Luke Skywalker"],
            ["__typename": "Human", "name": "Han Solo"],
            ["__typename": "Human", "name": "Leia Organa"]
          ]
          ])
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

    TestCacheProvider.withCache(initialRecords: initialRecords) { (cache) in
      let store = ApolloStore(cache: cache)

      try! await(store.withinReadWriteTransaction { transaction in
        var friendsNames = try! transaction.readObject(forFragment: FriendsNames.self, withKey: "2001")
        friendsNames[arrayAt: "friends"]?.append(["__typename": "Droid", "name": "C-3PO"])
        try! transaction.write(object: friendsNames, forFragment: FriendsNames.self, withKey: "2001")
      })

      let result = try! await(store.load(query: HeroAndFriendsNamesQuery()))
      guard let data = result.data else { XCTFail(); return }

      XCTAssertEqual(data.hero?.name, "R2-D2")
      let friendsNames = data.hero?.friends?.flatMap { $0?.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa", "C-3PO"])
    }
  }
}

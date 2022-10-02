//
//  MyCustomProjectTests.swift
//  MyCustomProjectTests
//
//  Created by Calvin Cestari on 2022-06-13.
//

import XCTest
import Apollo
@testable import MyCustomProject

class MyCustomProjectTests: XCTestCase {

  func testCacheKeyResolution() throws {
    let store = ApolloStore()

    let response = GraphQLResponse(
      operation: DogQuery(),
      body: ["data": [
        "allAnimals": [
          [
            "__typename": "Dog",
            "id": "1",
            "species": "Canine",
          ]
        ]
      ]])

    let (_, records) = try response.parseResult()

    let expectation = expectation(description: "Publish Record then Fetch")

    store.publish(records: records!) { _ in
      store.withinReadTransaction { transaction in
        let dog = try! transaction.readObject(
          ofType: DogQuery.Data.AllAnimal.self,
          withKey: "Dog:1")
        
        XCTAssertEqual(dog.id, "1")
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 1.0)
  }

  func test_mockObject() throws {
    let mock = Mock<Dog>()

    XCTAssertEqual(mock.__typename, "Dog")
  }

  func test_mockUnion() throws {
    let mock = Mock<Query>()
    mock.classroomPets = [Mock<Cat>()]

    XCTAssertEqual(mock.classroomPets!.count, 1)
  }

}

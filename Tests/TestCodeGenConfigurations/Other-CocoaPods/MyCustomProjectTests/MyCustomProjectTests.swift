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

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
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

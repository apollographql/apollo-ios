// Copyright (c) 2016 Meteor Development Group, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest
@testable import Apollo
import StarWars

class StarWarsServerTests: XCTestCase {
  var client: ApolloClient!
  
  override func setUp() {
    super.setUp()
    
    client = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)
  }
  
  func testHeroNameQuery() {
    fetch(query: HeroNameQuery()) { (data) in
      XCTAssertEqual(data.hero.name, "R2-D2")
    }
  }
  
  func testHeroAndFriendsNamesQuery() {
    fetch(query: HeroAndFriendsNamesQuery()) { (data) in
      XCTAssertEqual(data.hero.name, "R2-D2")
      let friendsNames = data.hero.friends.map { $0.name }
      XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
    }
  }
  
  func testHeroAppearsInQuery() {
    fetch(query: HeroAppearsInQuery()) { (data) in
      XCTAssertEqual(data.hero.name, "R2-D2")
      XCTAssertEqual(data.hero.appearsIn, [.newhope, .empire, .jedi])
    }
  }
  
  func testHeroDetailsQueryDroid() {
    fetch(query: HeroDetailsQuery()) { (data) in
      XCTAssertEqual(data.hero.name, "R2-D2")
      
      guard let droid = data.hero as? HeroDetailsQuery.Data.Droid else {
        XCTFail("Wrong type")
        return
      }
      XCTAssertEqual(droid.primaryFunction, "Astromech")
    }
  }
  
  func testHeroDetailsQueryHuman() {
    fetch(query: HeroDetailsQuery(episode: .empire)) { (data) in
      XCTAssertEqual(data.hero.name, "Luke Skywalker")
      
      guard let human = data.hero as? HeroDetailsQuery.Data.Human else {
        XCTFail("Wrong type")
        return
      }
      XCTAssertEqual(human.homePlanet, "Tatooine")
    }
  }
  
  func testHeroDetailsFragmentQueryHuman() {
    fetch(query: HeroDetailsFragmentQuery(episode: .empire)) { (data) in
      XCTAssertEqual(data.hero.name, "Luke Skywalker")
      
      guard let human = data.hero as? HeroDetails_Human else {
        XCTFail("Wrong type")
        return
      }
      XCTAssertEqual(human.homePlanet, "Tatooine")
    }
  }
  
  private func fetch<Query: GraphQLQuery>(query: Query, completionHandler: @escaping (_ data: Query.Data) -> Void) {
    let expectation = self.expectation(description: "Fetching query")
    
    client.fetch(query: query) { (result, error) in
      defer { expectation.fulfill() }
      
      if let error = error { XCTFail("Error while fetching query: \(error)");  return }
      guard let result = result else { XCTFail("No query result");  return }
      
      if let errors = result.errors {
        XCTFail("Errors in query result: \(errors)")
      }
      
      guard let data = result.data else { XCTFail("No query result data");  return }
      
      completionHandler(data)
    }
    
    waitForExpectations(timeout: 1, handler: nil)
  }
}

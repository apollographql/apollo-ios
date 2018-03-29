//
//  ApolloWebsocketTests.swift
//  ApolloWebsocketTests
//
//  Created by Knut Johannessen on 23/03/2018.
//  Copyright © 2018 Johannessen. All rights reserved.
//

import XCTest
import Apollo
@testable import ApolloWebsocket
import StarWarsAPI

extension WebSocketTransport {
    func write(message: GraphQLMap) {
        let serialized = try! JSONSerializationFormat.serialize(value: message)
        if let str = String(data: serialized, encoding: .utf8) {
            self.websocket?.write(string: str)
        }
    }
}

class MockWebsocketTests: XCTestCase {

    var networkTransport : WebSocketTransport?
    var store : ApolloStore?
    var client : ApolloClient?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
      
        WebSocketTransport.provider = MockWebSocket.self
        networkTransport = WebSocketTransport(url: URL(string: "http://localhost/dummy_url")!)
      
        store = ApolloStore(cache: InMemoryNormalizedCache())
        client = ApolloClient(networkTransport: networkTransport!)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLocalSingleSubscription() throws {
      
      let expectation = self.expectation(description: "Single subscription")
    
      let subscription = ReviewAddedSubscription()
      client?.subscribe(subscription: subscription) { (result, error) in
            defer { expectation.fulfill() }
          
            if error != nil { XCTFail("Error response");  return }
            
            guard let result = result else { XCTFail("No subscription result");  return }
            
            XCTAssertEqual(result.data?.reviewAdded?.stars, 5)
        }
        
        let message : GraphQLMap = [
            "type": "data",
            "id": "1",
            "payload": [
                "data": [
                    "reviewAdded": [
                        "__typename": "ReviewAdded",
                        "episode": "JEDI",
                        "stars": 5,
                        "commentary": "A great movie"
                    ]
                ]
            ]
        ]
        
        networkTransport?.write(message: message)
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }
  
  func testLocalMissingSubscription() throws {
    
    let expectation = self.expectation(description: "Missing subscription")
    expectation.isInverted=true

    let subscription = ReviewAddedSubscription()
    client?.subscribe(subscription: subscription) { (result, error) in
      defer { expectation.fulfill() }
      
      if error != nil { XCTFail("Error response");  return }
      
      guard let result = result else { XCTFail("No subscription result");  return }
      
      XCTAssertEqual(result.data?.reviewAdded?.stars, 5)
    }
    
//    let message : GraphQLMap = [
//      "type": "data",
//      "id": "1",
//      "payload": [
//        "data": [
//          "reviewAdded": [
//            "__typename": "ReviewAdded",
//            "episode": "JEDI",
//            "stars": 5,
//            "commentary": "A great movie"
//          ]
//        ]
//      ]
//    ]
    
    // do not write - expecting timeout as success
    // networkTransport?.write(message: message)
    
    waitForExpectations(timeout: 2, handler: nil)
    
  }
  
  func testLocalErrorUnknownId() throws {
    
    let expectation = self.expectation(description: "Unknown id for subscription")
    
    let subscription = ReviewAddedSubscription()
    client?.subscribe(subscription: subscription) { (result, error) in
      defer { expectation.fulfill() }
      
      // Expecting error and no result
      if result != nil { XCTAssert(false) }
      if error != nil { XCTAssert(true) }
      
    }
    
    let message : GraphQLMap = [
      "type": "data",
      "id": "2",            // subscribing on id = 1, i.e. expecting error when receiving id = 2
      "payload": [
        "data": [
          "reviewAdded": [
            "__typename": "ReviewAdded",
            "episode": "JEDI",
            "stars": 5,
            "commentary": "A great movie"
          ]
        ]
      ]
    ]
    
    networkTransport?.write(message: message)
    
    waitForExpectations(timeout: 2, handler: nil)
    
  }
}

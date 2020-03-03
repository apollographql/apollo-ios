//
//  VariableToSwiftTypeTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 2/29/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import ApolloCodegenLib

class VariableToSwiftTypeTests: XCTestCase {
  
  func testNullableEnum() throws {
    let json: [String: Any?] = [
      "kind": "ENUM",
      "name": "Episode",
      "ofType": nil
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .ENUM)
    XCTAssertEqual(variable.name, "Episode")
    XCTAssertNil(variable.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "Episode?")
  }
  
  func testNonNullEnum() throws {
    let json: [String: Any?] = [
      "kind": "NON_NULL",
      "name": nil,
      "ofType": [
        "kind": "ENUM",
        "name": "Episode",
        "ofType": nil
      ]
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .NON_NULL)
    XCTAssertNil(variable.name)
    
    let ofType = try XCTUnwrap(variable.ofType)
    XCTAssertEqual(ofType.kind, .ENUM)
    XCTAssertEqual(ofType.name, "Episode")
    XCTAssertNil(ofType.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "Episode")
  }
  
  func testNullableInputObject() throws {
    let json: [String: Any?] = [
      "kind": "INPUT_OBJECT",
      "name": "ReviewInput",
      "ofType": nil
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .INPUT_OBJECT)
    XCTAssertEqual(variable.name, "ReviewInput")
    XCTAssertNil(variable.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "ReviewInput?")
  }
  
  func testNonNullInputObject() throws {
    let json: [String: Any?] = [
      "kind": "NON_NULL",
      "name": nil,
      "ofType": [
        "kind": "INPUT_OBJECT",
        "name": "ReviewInput",
        "ofType": nil
      ]
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)

    XCTAssertEqual(variable.kind, .NON_NULL)
    XCTAssertNil(variable.name)
    
    let ofType = try XCTUnwrap(variable.ofType)
    XCTAssertEqual(ofType.kind, .INPUT_OBJECT)
    XCTAssertEqual(ofType.name, "ReviewInput")
    XCTAssertNil(ofType.ofType)

    XCTAssertEqual(try variable.toSwiftType(), "ReviewInput")
  }
  
  func testNullableInterface() throws {
    let json: [String: Any?] = [
      "kind": "INTERFACE",
      "name": "Character",
      "ofType": nil
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .INTERFACE)
    XCTAssertEqual(variable.name, "Character")
    XCTAssertNil(variable.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "Character?")
  }
  
  func testNonNullInterface() throws {
    let json: [String: Any?] = [
      "kind": "NON_NULL",
      "name": nil,
      "ofType": [
        "kind": "INTERFACE",
        "name": "Character",
        "ofType": nil
      ]
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .NON_NULL)
    XCTAssertNil(variable.name)
    
    let ofType = try XCTUnwrap(variable.ofType)
    XCTAssertEqual(ofType.kind, .INTERFACE)
    XCTAssertEqual(ofType.name, "Character")
    XCTAssertNil(ofType.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "Character")
  }
  
  func testNullableObject() throws {
    let json: [String: Any?] = [
      "kind": "OBJECT",
      "name": "FriendsConnection",
      "ofType": nil
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    
    XCTAssertEqual(variable.kind, .OBJECT)
    XCTAssertEqual(variable.name, "FriendsConnection")
    XCTAssertNil(variable.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "FriendsConnection?")
  }
  
  func testNonNullObject() throws {
    let json: [String: Any?] = [
      "kind": "NON_NULL",
      "name": nil,
      "ofType": [
        "kind": "OBJECT",
        "name": "FriendsConnection",
        "ofType": nil
      ]
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)

    XCTAssertEqual(variable.kind, .NON_NULL)
    XCTAssertNil(variable.name)
    
    let ofType = try XCTUnwrap(variable.ofType)
    XCTAssertEqual(ofType.kind, .OBJECT)
    XCTAssertEqual(ofType.name, "FriendsConnection")
    XCTAssertNil(ofType.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "FriendsConnection")
  }
  
  func testNullableScalar() throws {
    let json: [String: Any?] = [
      "kind": "SCALAR",
      "name": "ID",
      "ofType": nil
    ]

    let variable = try ASTForthcomingVariableType(dictionary: json)

    XCTAssertEqual(variable.kind, .SCALAR)
    XCTAssertEqual(variable.name, "ID")
    XCTAssertNil(variable.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "ID?")
  }
  
  func testNonNullScalar() throws {
    let json: [String: Any?] = [
      "kind": "NON_NULL",
      "name": nil,
      "ofType": [
        "kind": "SCALAR",
        "name": "ID",
        "ofType": nil
      ]
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    
    XCTAssertEqual(variable.kind, .NON_NULL)
    XCTAssertNil(variable.name)
    
    let ofType = try XCTUnwrap(variable.ofType)
    XCTAssertEqual(ofType.kind, .SCALAR)
    XCTAssertEqual(ofType.name, "ID")
    XCTAssertNil(ofType.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "ID")
  }
  
  func testNullableUnion() throws {
    let json: [String: Any?] = [
      "kind": "UNION",
      "name": "SearchResult",
      "ofType": nil
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .UNION)
    XCTAssertEqual(variable.name, "SearchResult")
    XCTAssertNil(variable.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "SearchResult?")
  }
  
  func testNonNullUnion() throws {
    let json: [String: Any?] = [
      "kind": "NON_NULL",
      "name": nil,
      "ofType": [
        "kind": "UNION",
        "name": "SearchResult",
        "ofType": nil
      ]
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    
    XCTAssertEqual(variable.kind, .NON_NULL)
    XCTAssertNil(variable.name)

    let ofType = try XCTUnwrap(variable.ofType)
    XCTAssertEqual(ofType.kind, .UNION)
    XCTAssertEqual(ofType.name, "SearchResult")
    XCTAssertNil(ofType.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "SearchResult")
  }
  
  func testNullableListOfNullableItems() throws {
    let json: [String: Any?] = [
      "kind": "LIST",
      "name": nil,
      "ofType": [
        "kind": "INTERFACE",
        "name": "Character",
        "ofType": nil
      ]
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .LIST)
    XCTAssertNil(variable.name)
    
    let ofType = try XCTUnwrap(variable.ofType)
    XCTAssertEqual(ofType.kind, .INTERFACE)
    XCTAssertEqual(ofType.name, "Character")
    XCTAssertNil(ofType.ofType)

    XCTAssertEqual(try variable.toSwiftType(), "[Character?]?")
  }
  
  func testNullableListOfNonNullItems() throws {
    let json: [String: Any?] = [
      "kind": "LIST",
      "name": nil,
      "ofType": [
        "kind": "NON_NULL",
        "name": nil,
        "ofType": [
          "kind": "INTERFACE",
          "name": "Character",
          "ofType": nil
        ]
      ]
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .LIST)
    XCTAssertNil(variable.name)
    
    let ofFirstType = try XCTUnwrap(variable.ofType)
    XCTAssertEqual(ofFirstType.kind, .NON_NULL)
    XCTAssertNil(ofFirstType.name)
    
    let ofSecondType = try XCTUnwrap(ofFirstType.ofType)
    XCTAssertEqual(ofSecondType.kind, .INTERFACE)
    XCTAssertEqual(ofSecondType.name, "Character")
    XCTAssertNil(ofSecondType.ofType)
      
    XCTAssertEqual(try variable.toSwiftType(), "[Character]?")
  }
  
  func testNonNullListOfNullableItems() throws {
    let json: [String: Any?] = [
      "kind": "NON_NULL",
      "name": nil,
      "ofType": [
        "kind": "LIST",
        "name": nil,
        "ofType": [
          "kind": "INTERFACE",
          "name": "Character",
          "ofType": nil
        ]
      ]
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .NON_NULL)
    XCTAssertNil(variable.name)
    
    let ofFirstType = try XCTUnwrap(variable.ofType)
    XCTAssertEqual(ofFirstType.kind, .LIST)
    XCTAssertNil(ofFirstType.name)
    
    let ofSecondType = try XCTUnwrap(ofFirstType.ofType)
    XCTAssertEqual(ofSecondType.kind, .INTERFACE)
    XCTAssertEqual(ofSecondType.name, "Character")
    XCTAssertNil(ofSecondType.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "[Character?]")
  }
  
  func testNonNullListOfNonNullItems() throws {
    let json: [String: Any?] = [
      "kind": "NON_NULL",
      "name": nil,
      "ofType": [
        "kind": "LIST",
        "name": nil,
        "ofType": [
          "kind": "NON_NULL",
          "name": nil,
          "ofType": [
            "kind": "INTERFACE",
            "name": "Character",
            "ofType": nil
          ]
        ]
      ]
    ]
    
    let variable = try ASTForthcomingVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .NON_NULL)
    XCTAssertNil(variable.name)
    
    let ofFirstType = try XCTUnwrap(variable.ofType)
    XCTAssertEqual(ofFirstType.kind, .LIST)
    XCTAssertNil(ofFirstType.name)
    
    let ofSecondType = try XCTUnwrap(ofFirstType.ofType)
    XCTAssertEqual(ofSecondType.kind, .NON_NULL)
    XCTAssertNil(ofSecondType.name)
    
    let ofThirdType = try XCTUnwrap(ofSecondType.ofType)
    XCTAssertEqual(ofThirdType.kind, .INTERFACE)
    XCTAssertEqual(ofThirdType.name, "Character")
    XCTAssertNil(ofThirdType.ofType)
    
    XCTAssertEqual(try variable.toSwiftType(), "[Character]")
  }
}

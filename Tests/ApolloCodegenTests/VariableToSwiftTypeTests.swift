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
  
  func testNullableType() throws {
    let json: [String: Any?] = [
      "kind": "NamedType",
      "name": [
        "kind": "Name",
        "value": "Episode"
      ],
    ]
    
    let variable = try ASTVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .NamedType)
    XCTAssertNil(variable.type)
    XCTAssertNil(variable.value)
    
    let innerVariable = try XCTUnwrap(variable.name)
    XCTAssertNil(innerVariable.type)
    XCTAssertNil(innerVariable.name)
    XCTAssertEqual(innerVariable.value, "Episode")
    
    XCTAssertEqual(try variable.toSwiftType(), "Episode?")
  }
  
  func testNonNullType() throws {
    let json: [String: Any?] = [
      "kind": "NonNullType",
      "type": [
        "kind": "NamedType",
        "name": [
          "kind": "Name",
          "value": "Episode"
        ],
      ]
    ]
    
    let variable = try ASTVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .NonNullType)
    XCTAssertNil(variable.value)
    XCTAssertNil(variable.name)
    
    let innerVariable = try XCTUnwrap(variable.type)
    XCTAssertEqual(innerVariable.kind, .NamedType)
    XCTAssertNil(innerVariable.type)
    XCTAssertNil(innerVariable.value)
    
    let secondInnerVariable = try XCTUnwrap(innerVariable.name)
    XCTAssertNil(secondInnerVariable.type)
    XCTAssertNil(secondInnerVariable.name)
    XCTAssertEqual(secondInnerVariable.value, "Episode")
    
    XCTAssertEqual(try variable.toSwiftType(), "Episode")
  }
  
  func testNullableListOfNullableItems() throws {
    let json: [String: Any?] = [
      "kind": "ListType",
      "type": [
        "kind": "NamedType",
        "name": [
          "kind": "Name",
          "value": "Character",
        ]
      ]
    ]
    
    let variable = try ASTVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .ListType)
    XCTAssertNil(variable.name)
    XCTAssertNil(variable.value)
    
    let innerVariable = try XCTUnwrap(variable.type)
    XCTAssertEqual(innerVariable.kind, .NamedType)
    XCTAssertNil(innerVariable.value)
    XCTAssertNil(innerVariable.type)
    
    let secondInnerVariable = try XCTUnwrap(innerVariable.name)
    XCTAssertEqual(secondInnerVariable.kind, .Name)
    XCTAssertEqual(secondInnerVariable.value, "Character")
    XCTAssertNil(secondInnerVariable.type)
    XCTAssertNil(secondInnerVariable.name)

    XCTAssertEqual(try variable.toSwiftType(), "[Character?]?")
  }
  
  func testNullableListOfNonNullItems() throws {
    let json: [String: Any?] = [
      "kind": "ListType",
      "type": [
        "kind": "NonNullType",
        "type": [
          "kind": "NamedType",
          "name": [
            "kind": "Name",
            "value": "Character",
          ]
        ]
      ]
    ]
    
    let variable = try ASTVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .ListType)
    XCTAssertNil(variable.name)
    XCTAssertNil(variable.value)
    
    let innerVariable = try XCTUnwrap(variable.type)
    XCTAssertEqual(innerVariable.kind, .NonNullType)
    XCTAssertNil(innerVariable.value)
    XCTAssertNil(innerVariable.name)
    
    let secondInnerVariable = try XCTUnwrap(innerVariable.type)
    XCTAssertEqual(secondInnerVariable.kind, .NamedType)
    XCTAssertNil(secondInnerVariable.value)
    XCTAssertNil(secondInnerVariable.type)
    
    let thirdInnerVariable = try XCTUnwrap(secondInnerVariable.name)
    XCTAssertEqual(thirdInnerVariable.kind, .Name)
    XCTAssertEqual(thirdInnerVariable.value, "Character")
    XCTAssertNil(thirdInnerVariable.name)
    XCTAssertNil(thirdInnerVariable.type)
    
    XCTAssertEqual(try variable.toSwiftType(), "[Character]?")
  }
  
  func testNonNullListOfNullableItems() throws {
    let json: [String: Any?] = [
      "kind": "NonNullType",
      "type": [
        "kind": "ListType",
        "type": [
          "kind": "NamedType",
          "name": [
            "kind": "Name",
            "value": "Character",
          ]
        ]
      ]
    ]
    
    let variable = try ASTVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .NonNullType)
    XCTAssertNil(variable.name)
    XCTAssertNil(variable.value)
    
    let innerVariable = try XCTUnwrap(variable.type)
    XCTAssertEqual(innerVariable.kind, .ListType)
    XCTAssertNil(innerVariable.name)
    XCTAssertNil(innerVariable.value)

    let secondInnerVariable = try XCTUnwrap(innerVariable.type)
    XCTAssertEqual(secondInnerVariable.kind, .NamedType)
    XCTAssertNil(secondInnerVariable.type)
    XCTAssertNil(secondInnerVariable.value)
    
    let thirdInnerVariable = try XCTUnwrap(secondInnerVariable.name)
    XCTAssertEqual(thirdInnerVariable.kind, .Name)
    XCTAssertEqual(thirdInnerVariable.value, "Character")
    XCTAssertNil(thirdInnerVariable.name)
    XCTAssertNil(thirdInnerVariable.type)
    
    XCTAssertEqual(try variable.toSwiftType(), "[Character?]")
  }
  
  func testNonNullListOfNonNullItems() throws {
    let json: [String: Any?] = [
      "kind": "NonNullType",
      "type": [
        "kind": "ListType",
        "type": [
          "kind": "NonNullType",
          "type": [
            "kind": "NamedType",
            "name": [
              "kind": "Name",
              "value": "Character",
            ]
          ]
        ]
      ]
    ]
    
    let variable = try ASTVariableType(dictionary: json)
    XCTAssertEqual(variable.kind, .NonNullType)
    XCTAssertNil(variable.name)
    XCTAssertNil(variable.value)
    
    let innerVariable = try XCTUnwrap(variable.type)
    XCTAssertEqual(innerVariable.kind, .ListType)
    XCTAssertNil(innerVariable.name)
    XCTAssertNil(innerVariable.value)
    
    let secondInnerVariable = try XCTUnwrap(innerVariable.type)
    XCTAssertEqual(secondInnerVariable.kind, .NonNullType)
    XCTAssertNil(secondInnerVariable.name)
    XCTAssertNil(secondInnerVariable.value)
    
    let thirdInnerVariable = try XCTUnwrap(secondInnerVariable.type)
    XCTAssertEqual(thirdInnerVariable.kind, .NamedType)
    XCTAssertNil(thirdInnerVariable.type)
    XCTAssertNil(thirdInnerVariable.value)
    
    let fourthInnerVariable = try XCTUnwrap(thirdInnerVariable.name)
    XCTAssertEqual(fourthInnerVariable.kind, .Name)
    XCTAssertEqual(fourthInnerVariable.value, "Character")
    XCTAssertNil(fourthInnerVariable.name)
    XCTAssertNil(fourthInnerVariable.type)
    
    XCTAssertEqual(try variable.toSwiftType(), "[Character]")
  }
}

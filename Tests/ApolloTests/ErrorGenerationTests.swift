//
//  ErrorGenerationTests.swift
//  Apollo
//
//  Created by Ellen Shapiro on 9/9/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Apollo
@testable import ApolloAPI
import ApolloInternalTestHelpers
import Nimble
import XCTest

class ErrorGenerationTests: XCTestCase {
  
  private func checkExtensions(on error: GraphQLError,
                               expectedDict: [String: Any?],
                               file: StaticString = #filePath,
                               line: UInt = #line) {
    XCTAssertEqual(error.extensions?.count,
                   expectedDict.count,
                   file: file,
                   line: line)
    
    for (key, expectedValue) in expectedDict {
      let actualValue = error.extensions?[key] as? String
      let stringExpectedValue = expectedValue as? String
      XCTAssertEqual(actualValue,
                     stringExpectedValue,
                     "Value for key \(key) did not match expected value \(String(describing: stringExpectedValue)), it was \(String(describing: actualValue))",
                     file: file,
                     line: line)
    }
  }
  
  func testSingleErrorParsing() throws {
    let json = """
{
  "data": {
    "hero": null
  },
  "errors": [
    {
      "message": "Invalid client auth token.",
      "extensions": {
        "code": "INTERNAL_SERVER_ERROR"
      }
    }
  ]
}
"""
 
    let data = try XCTUnwrap(json.data(using: .utf8),
                             "Couldn't create json data")
    let deserialized = try JSONSerializationFormat.deserialize(data: data)
    let jsonObject = try XCTUnwrap(deserialized as? JSONObject)
    let response = GraphQLResponse(operation: MockOperation.mock(), body: jsonObject)
    let result = try response.parseResultFast()
    XCTAssertNotNil(result.data)
    expect(result.data?.data.data["hero"]).to(beNil())
    
    XCTAssertEqual(result.errors?.count, 1)
    let error = try XCTUnwrap(result.errors?.first)
    XCTAssertEqual(error.message, "Invalid client auth token.")
    
    self.checkExtensions(on: error, expectedDict:  [
      "code": "INTERNAL_SERVER_ERROR"
    ])
  }
  
  func testLocalizedStringFromErrorResponseWithMultipleErrors() throws {
    let json = """
{
  "data": {
    "hero": null
  },
  "errors": [
    {
      "message": "Invalid client auth token.",
      "extensions": {
        "code": "INTERNAL_SERVER_ERROR"
      }
    },
    {
      "message": "Server is having a sad.",
      "extensions": {
        "code": "INTERNAL_SERVER_ERROR"
      }
    }
  ]
}
"""
    
    let data = try XCTUnwrap(json.data(using: .utf8),
                             "Couldn't create json data")
    let deserialized = try JSONSerializationFormat.deserialize(data: data)
    let jsonObject = try XCTUnwrap(deserialized as? JSONObject)
    let response = GraphQLResponse(operation: MockOperation.mock(), body: jsonObject)
    let result = try response.parseResultFast()
    XCTAssertNotNil(result.data)
    expect(result.data?.data.data["hero"]).to(beNil())
    
    let errors = try XCTUnwrap(result.errors)
    
    XCTAssertEqual(errors.count, 2)
    XCTAssertEqual(errors.map { $0.message }, [
      "Invalid client auth token.",
      "Server is having a sad.",
    ])
    
    for error in errors {
      self.checkExtensions(on: error, expectedDict: [
        "code": "INTERNAL_SERVER_ERROR"
      ])
    }
  }
}

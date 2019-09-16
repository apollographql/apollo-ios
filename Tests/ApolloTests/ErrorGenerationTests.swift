//
//  ErrorGenerationTests.swift
//  Apollo
//
//  Created by Ellen Shapiro on 9/9/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Apollo
import XCTest

class ErrorGenerationTests: XCTestCase {
  
  func testLocalizedStringFromErrorResponse() {
    let json = """
{
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
 
    let response = HTTPURLResponse(url: URL(string: "https://www.fake.com")!,
                                   statusCode: 403,
                                   httpVersion: nil,
                                   headerFields: nil)!
    
    guard let data = json.data(using: .utf8) else {
      XCTFail("Couldn't create json data")
      return
    }
    
    let httpResponseError = GraphQLHTTPResponseError(body: data,
                                                     response: response,
                                                     kind: .errorResponse)
    XCTAssertEqual(httpResponseError.graphQLErrors?.count, 1)
    XCTAssertEqual(httpResponseError.localizedDescription, "Received error response: Invalid client auth token.")
  }
  
  func testLocalizedStringFromErrorResponseWithMultipleErrors() {
    let json = """
{
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
    
    let response = HTTPURLResponse(url: URL(string: "https://www.fake.com")!,
                                   statusCode: 403,
                                   httpVersion: nil,
                                   headerFields: nil)!
    
    guard let data = json.data(using: .utf8) else {
      XCTFail("Couldn't create json data")
      return
    }
    
    let httpResponseError = GraphQLHTTPResponseError(body: data,
                                                     response: response,
                                                     kind: .errorResponse)
    XCTAssertEqual(httpResponseError.graphQLErrors?.count, 2)
    XCTAssertEqual(httpResponseError.localizedDescription, "Received error response: Invalid client auth token.\nServer is having a sad.")
  }
  
  func testLocalizedStringFromPlaintextResponse() {
    let text = "The server is having a sad."
    
    let response = HTTPURLResponse(url: URL(string: "https://www.fake.com")!,
                                   statusCode: 500,
                                   httpVersion: nil,
                                   headerFields: nil)!
    
    guard let data = text.data(using: .utf8) else {
      XCTFail("Couldn't create text data")
      return
    }
    
    let httpResponseError = GraphQLHTTPResponseError(body: data,
                                                     response: response,
                                                     kind: .errorResponse)
    
    XCTAssertNil(httpResponseError.graphQLErrors)
    XCTAssertEqual(httpResponseError.localizedDescription, "Received error response (500 internal server error): The server is having a sad.")
  }
  
  func testLocalizedStringFromNullDataResponse() {
    let response = HTTPURLResponse(url: URL(string: "https://www.fake.com")!,
                                   statusCode: 500,
                                   httpVersion: nil,
                                   headerFields: nil)!
    
    let httpResponseError = GraphQLHTTPResponseError(body: nil,
                                                     response: response,
                                                     kind: .errorResponse)
    
    XCTAssertNil(httpResponseError.graphQLErrors)
    XCTAssertEqual(httpResponseError.localizedDescription, "Received error response (500 internal server error): [Empty response body]")
  }
}

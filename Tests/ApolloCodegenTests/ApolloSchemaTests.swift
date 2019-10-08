//
//  ApolloSchemaTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 10/7/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import ApolloCodegenLib

class ApolloSchemaTests: XCTestCase {
  
  private lazy var endpointURL = URL(string: "http://localhost:8080")!
  
  func testCreatingOptionsWithDefaultParameters() throws {
    let sourceRoot = try CodegenTestHelper.sourceRootURL()
    let options = ApolloSchemaOptions(endpointURL: self.endpointURL,
                                      outputURL: sourceRoot)
    XCTAssertEqual(options.endpointURL, self.endpointURL)
    XCTAssertEqual(options.outputURL, sourceRoot)
    XCTAssertNil(options.apiKey)
    XCTAssertNil(options.header)
    
    XCTAssertEqual(options.arguments, [
        "client:download-schema",
        "--endpoint=\(self.endpointURL.path)",
        sourceRoot.path
    ])
  }
  
  func testCreatingOptionsWithAllParameters() throws {
    let sourceRoot = try CodegenTestHelper.sourceRootURL()
    let apiKey = "Fake_API_Key"
    let header = "Authorization: Bearer tokenGoesHere"
    let options = ApolloSchemaOptions(apiKey: apiKey,
                                      endpointURL: self.endpointURL,
                                      header: header,
                                      outputURL: sourceRoot)
    XCTAssertEqual(options.apiKey, apiKey)
    XCTAssertEqual(options.endpointURL, self.endpointURL)
    XCTAssertEqual(options.header, header)
    XCTAssertEqual(options.outputURL, sourceRoot)

    XCTAssertEqual(options.arguments, [
        "client:download-schema",
        "--endpoint=\(self.endpointURL.path)",
        "--header=\(header)",
        "--key=\(apiKey)",
        sourceRoot.path
    ])
  }
}

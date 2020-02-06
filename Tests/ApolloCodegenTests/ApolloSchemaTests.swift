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
  
  private lazy var endpointURL = URL(string: "http://localhost:8080/graphql")!
  
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
        "--endpoint=http://localhost:8080/graphql",
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
        "--endpoint=http://localhost:8080/graphql",
        "--header=\(header)",
        "--key=\(apiKey)",
        sourceRoot.path
    ])
  }
  
  func testDownloadingSchemaAsJSON() throws {
    let sourceRoot = try CodegenTestHelper.sourceRootURL()
    let testOutputURL = sourceRoot
      .appendingPathComponent("Tests")
      .appendingPathComponent("ApolloCodegenTests")
      .appendingPathComponent("schema.json")
    
    // Delete anything existing at the output URL
    try FileManager.default.apollo_deleteFile(at: testOutputURL)
    XCTAssertFalse(FileManager.default.apollo_fileExists(at: testOutputURL))
    
    let options = ApolloSchemaOptions(endpointURL: self.endpointURL,
                                      outputURL: testOutputURL)
    let cliFolderURL = try CodegenTestHelper.cliFolderURL()

    _ = try ApolloSchemaDownloader.run(with: cliFolderURL,
                                       options: options)
    
    // Does the file now exist?
    XCTAssertTrue(FileManager.default.apollo_fileExists(at: testOutputURL))
    
    // Is it non-empty?
    let data = try Data(contentsOf: testOutputURL)
    XCTAssertFalse(data.isEmpty)
    
    // Is it JSON?
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable:Any])
    
    // Is it schema json?
    _ = try XCTUnwrap(json["__schema"])
    
    // OK delete it now
    try FileManager.default.apollo_deleteFile(at: testOutputURL)
    XCTAssertFalse(FileManager.default.apollo_fileExists(at: testOutputURL))
  }
  
}

//
//  ApolloSchemaTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 10/7/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
import ApolloTestSupport
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib

class ApolloSchemaTests: XCTestCase {
  
  override func tearDownWithError() throws {
    try FileManager.default.apollo.deleteFile(at: self.defaultOutputURL)
    try FileManager.default.apollo.deleteFile(at: self.intermediateOutputURL)
    try super.tearDownWithError()
  }
  
  private var defaultOutputURL: URL {
    return CodegenTestHelper.schemaFolderURL()
      .appendingPathComponent("schema.graphqls")
  }
  
  private var intermediateOutputURL: URL {
    return CodegenTestHelper.schemaFolderURL().appendingPathComponent("registry_response.json")
  }
    
  func testCreatingIntrospectionOptionsWithDefaultParameters() throws {
    let options = ApolloSchemaOptions(downloadMethod: .introspection(endpointURL: TestURL.mockPort8080.url),
                                      outputFolderURL: CodegenTestHelper.schemaFolderURL())
    XCTAssertEqual(options.downloadMethod, .introspection(endpointURL: TestURL.mockPort8080.url))
    XCTAssertEqual(options.outputURL, self.defaultOutputURL)
    XCTAssertTrue(options.headers.isEmpty)
    
    XCTAssertEqual(options.arguments, [
        "client:download-schema",
        "--endpoint=http://localhost:8080/graphql",
      "'\(self.defaultOutputURL.path)'"
    ])
  }

  func testCreatingRegistryOptionsWithDefaultParameters() throws {
    let sourceRoot = CodegenTestHelper.sourceRootURL()
    let apiKey = "Fake_API_Key"
    let graphID = "Fake_Graph_ID"
    
    let settings = ApolloSchemaOptions.DownloadMethod.RegistrySettings(apiKey: apiKey, graphID: graphID)
    
    let options = ApolloSchemaOptions(downloadMethod: .registry(settings),
                                      outputFolderURL: sourceRoot)
    
    let expectedOutputURL = sourceRoot.appendingPathComponent("schema.json")
    
    XCTAssertEqual(options.downloadMethod, .registry(settings))
    XCTAssertEqual(options.outputURL, expectedOutputURL)
    XCTAssertTrue(options.headers.isEmpty)
    
    XCTAssertEqual(options.arguments, [
        "client:download-schema",
        "--key=\(apiKey)",
        "--graph=\(graphID)",
        "'\(expectedOutputURL.path)'"
    ])
  }

  func testCreatingRegistryOptionsWithAllParameters() throws {
    let sourceRoot = CodegenTestHelper.sourceRootURL()
    let apiKey = "Fake_API_Key"
    let graphID = "Fake_Graph_ID"
    let variant = "Fake_Variant"
    let firstHeader = ApolloSchemaOptions.HTTPHeader(key: "Authorization", value: "Bearer tokenGoesHere")
    let secondHeader = ApolloSchemaOptions.HTTPHeader(key: "Custom-Header",  value: "Custom_Customer")
    let headers = [firstHeader, secondHeader]
    
    let settings = ApolloSchemaOptions.DownloadMethod.RegistrySettings(apiKey: apiKey,
                                                                       graphID: graphID, variant: variant)
    
    let options = ApolloSchemaOptions(schemaFileName: "different_name",
                                      downloadMethod: .registry(settings),
                                      headers: headers,
                                      outputFolderURL: sourceRoot)
    XCTAssertEqual(options.downloadMethod, .registry(settings))
    XCTAssertEqual(options.headers, headers)
    
    let expectedOutputURL = sourceRoot.appendingPathComponent("different_name.graphql")
    XCTAssertEqual(options.outputURL, expectedOutputURL)

    XCTAssertEqual(options.arguments, [
        "client:download-schema",
        "--key=\(apiKey)",
        "--graph=\(graphID)",
        "--variant=\(variant)",
        "'\(expectedOutputURL.path)'",
        "--header='Authorization: Bearer tokenGoesHere'",
        "--header='Custom-Header: Custom_Customer'"
    ])
  }
  
  func testDownloadingViaIntrospection() throws {
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: self.defaultOutputURL))
    let options = ApolloSchemaOptions(downloadMethod: .introspection(endpointURL: TestURL.mockPort8080.url),
                                      
                                      outputFolderURL: CodegenTestHelper.schemaFolderURL(),
                                      downloadTimeout: 60)
    try ApolloSchemaDownloader.run(options: options)
    
    // Has the file been downloaded?
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: self.defaultOutputURL))
    
    // Can that file be decoded as JSON?
    let contents = try Data(contentsOf: self.defaultOutputURL)
    let json = try JSONSerialization.jsonObject(with: contents)
    let jsonDict = try XCTUnwrap(json as? [String: Any])
    
    // Is there actually anything _in_ the JSON?
    XCTAssertTrue(jsonDict.apollo.isNotEmpty)
  }
  
  func testDownloadingFromSchemaRegistry() throws {
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: self.defaultOutputURL))

    guard let apiKey = ProcessInfo.processInfo.environment["REGISTRY_API_KEY"] else {
      _ = XCTSkip("No API key could be fetched from the environment to test downloading from the schema registry")
      return
    }
    
      let settings = ApolloSchemaOptions.DownloadMethod.RegistrySettings(apiKey: apiKey, graphID: "Apollo-Fullstack-8zo5jl")
      
    let options = ApolloSchemaOptions(downloadMethod: .registry(settings),
                                      outputFolderURL: CodegenTestHelper.schemaFolderURL(),
                                      downloadTimeout: 60)
    
    try ApolloSchemaDownloader.run(options: options)

    XCTAssertTrue(FileManager.default.apollo.fileExists(at: self.defaultOutputURL))

    
  }
}


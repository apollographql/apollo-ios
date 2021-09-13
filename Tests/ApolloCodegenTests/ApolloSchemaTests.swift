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
    
  func testCreatingSchemaOptions_forIntrospectionDownload_usingDefaultParameters() throws {
    let options = ApolloSchemaOptions(downloadMethod: .introspection(endpointURL: TestURL.mockPort8080.url),
                                      outputFolderURL: CodegenTestHelper.schemaFolderURL())

    XCTAssertEqual(options.downloadMethod, .introspection(endpointURL: TestURL.mockPort8080.url))
    XCTAssertEqual(options.outputURL, self.defaultOutputURL)
    XCTAssertTrue(options.headers.isEmpty)
  }

  func testCreatingSchemaOptions_forRegistryDownload_usingDefaultParameters() throws {
    let settings = ApolloSchemaOptions.DownloadMethod.RegistrySettings(apiKey: "Fake_API_Key", graphID: "Fake_Graph_ID")
    let options = ApolloSchemaOptions(downloadMethod: .registry(settings),
                                      outputFolderURL: CodegenTestHelper.schemaFolderURL())

    XCTAssertEqual(options.downloadMethod, .registry(settings))
    XCTAssertEqual(options.outputURL, self.defaultOutputURL)
    XCTAssertTrue(options.headers.isEmpty)
  }

  func testCreatingSchemaOptions_forRegistryDownload_usingAllParameters() throws {
    let sourceRoot = CodegenTestHelper.sourceRootURL()
    let settings = ApolloSchemaOptions.DownloadMethod.RegistrySettings(apiKey: "Fake_API_Key",
                                                                       graphID: "Fake_Graph_ID",
                                                                       variant: "Fake_Variant")
    let headers = [
      ApolloSchemaOptions.HTTPHeader(key: "Authorization", value: "Bearer tokenGoesHere"),
      ApolloSchemaOptions.HTTPHeader(key: "Custom-Header",  value: "Custom_Customer")
    ]

    let schemaFileName = "different_name"
    let options = ApolloSchemaOptions(schemaFileName: schemaFileName,
                                      downloadMethod: .registry(settings),
                                      headers: headers,
                                      outputFolderURL: sourceRoot)

    XCTAssertEqual(options.downloadMethod, .registry(settings))
    XCTAssertEqual(options.headers, headers)

    let expectedOutputURL = sourceRoot.appendingPathComponent("\(schemaFileName).graphqls")
    XCTAssertEqual(options.outputURL, expectedOutputURL)
  }
  
  func testDownloading_usingIntrospection_shouldOutputSchema() throws {
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: self.defaultOutputURL))

    let options = ApolloSchemaOptions(downloadMethod: .introspection(endpointURL: TestURL.mockPort8080.url),
                                      outputFolderURL: CodegenTestHelper.schemaFolderURL(),
                                      downloadTimeout: 60)
    try ApolloSchemaDownloader.run(options: options)
    
    // Has the file been downloaded?
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: self.defaultOutputURL))
    
    // Can it be turned into the expected schema?
    let frontend = try ApolloCodegenFrontend()
    let stringOutput = try String(contentsOf: self.defaultOutputURL, encoding: .utf8)
    let schema = try frontend.loadSchemaFromIntrospectionResult(stringOutput)
    let episodeType = try schema.getType(named: "Episode")

    XCTAssertEqual(episodeType?.name, "Episode")
  }
  
  func testDownloading_fromSchemaRegistry_shouldOutputSchema() throws {
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: self.defaultOutputURL))

    guard let apiKey = ProcessInfo.processInfo.environment["REGISTRY_API_KEY"] else {
     throw XCTSkip("No API key could be fetched from the environment to test downloading from the schema registry")
    }
    
    let settings = ApolloSchemaOptions.DownloadMethod.RegistrySettings(apiKey: apiKey, graphID: "Apollo-Fullstack-8zo5jl")
    let options = ApolloSchemaOptions(downloadMethod: .registry(settings),
                                      outputFolderURL: CodegenTestHelper.schemaFolderURL(),
                                      downloadTimeout: 60)

    try ApolloSchemaDownloader.run(options: options)
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: self.defaultOutputURL))

    // Can it be turned into the expected schema?
    let frontend = try ApolloCodegenFrontend()
    let source = try frontend.makeSource(from: self.defaultOutputURL)
    let schema = try frontend.loadSchemaFromSDL(source)
    let rocketType = try schema.getType(named: "Rocket")
    XCTAssertEqual(rocketType?.name, "Rocket")
  }
}


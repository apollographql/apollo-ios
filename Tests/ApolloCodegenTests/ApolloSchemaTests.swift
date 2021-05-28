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
    
  func testCreatingIntrospectionOptionsWithDefaultParameters() throws {
    let sourceRoot = CodegenTestHelper.sourceRootURL()
    
    let options = ApolloSchemaOptions(downloadMethod: .introspection(endpointURL: TestURL.mockPort8080.url),
                                      outputFolderURL: sourceRoot)
    
    let expectedOutputURL = sourceRoot.appendingPathComponent("schema.json")
    
    XCTAssertEqual(options.downloadMethod, .introspection(endpointURL: TestURL.mockPort8080.url))
    XCTAssertEqual(options.outputURL, expectedOutputURL)
    XCTAssertTrue(options.headers.isEmpty)
    
    XCTAssertEqual(options.arguments, [
        "client:download-schema",
        "--endpoint=http://localhost:8080/graphql",
        "'\(expectedOutputURL.path)'"
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
                                      schemaFileType: .schemaDefinitionLanguage,
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
}

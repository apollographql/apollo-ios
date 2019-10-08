//
//  ApolloCodegenTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 10/7/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import ApolloCodegenLib

class ApolloCodegenTests: XCTestCase {
  
  func testCreatingOptionsWithDefaultParameters() throws {
    let sourceRoot = try CodegenTestHelper.sourceRootURL()
    let output = sourceRoot.appendingPathComponent("API.swift")
    let schema = sourceRoot.appendingPathComponent("schema.json")
    
    let options = ApolloCodegenOptions(outputFormat: .singleFile(atFileURL: output),
                                       urlToSchemaFile: schema)

    
    XCTAssertEqual(options.includes, "./**/*.graphql")
    XCTAssertTrue(options.mergeInFieldsFromFragmentSpreads)
    XCTAssertNil(options.namespace)
    XCTAssertNil(options.only)
    XCTAssertNil(options.operationIDsURL)
    switch options.outputFormat {
    case .singleFile(let fileURL):
      XCTAssertEqual(fileURL, output)
    case .multipleFiles:
      XCTFail("Nope, this should be a single file!")
    }
    XCTAssertFalse(options.passthroughCustomScalars)
    XCTAssertEqual(options.urlToSchemaFile, schema)
    
    XCTAssertEqual(options.arguments, [
      "codegen:generate",
      "--target=swift",
      "--addTypename",
      "--includes=./**/*.graphql",
      "--localSchemaFile=\(schema.path)",
      "--mergeInFieldsFromFragmentSpreads",
      output.path,
    ])
  }
  
  func testCreatingOptionsWithAllParameters() throws {
    let sourceRoot = try CodegenTestHelper.sourceRootURL()
    let output = sourceRoot.appendingPathComponent("API")
    let schema = sourceRoot.appendingPathComponent("schema.json")
    let only = sourceRoot.appendingPathComponent("only.graphql")
    let operationIDsURL = sourceRoot.appendingPathComponent("operationIDs.json")
    let namespace = "ANameSpace"
    
    let options = ApolloCodegenOptions(includes: "*.graphql",
                                       mergeInFieldsFromFragmentSpreads: false,
                                       namespace: namespace,
                                       only: only,
                                       operationIDsURL: operationIDsURL,
                                       outputFormat: .multipleFiles(inFolderAtURL: output),
                                       passthroughCustomScalars: true,
                                       urlToSchemaFile: schema)
    XCTAssertEqual(options.includes, "*.graphql")
    XCTAssertFalse(options.mergeInFieldsFromFragmentSpreads)
    XCTAssertEqual(options.namespace, namespace)
    XCTAssertEqual(options.only, only)
    XCTAssertEqual(options.operationIDsURL, operationIDsURL)
    switch options.outputFormat {
    case .singleFile:
      XCTFail("This should be multiple files!")
    case .multipleFiles(let folderURL):
      XCTAssertEqual(folderURL, output)
    }
    XCTAssertTrue(options.passthroughCustomScalars)
    XCTAssertEqual(options.urlToSchemaFile, schema)
    
    
    XCTAssertEqual(options.arguments, [
      "codegen:generate",
      "--target=swift",
      "--addTypename",
      "--includes=*.graphql",
      "--localSchemaFile=\(schema.path)",
      "--namespace=\(namespace)",
      "--only=\(only.path)",
      "--operationIdsPath=\(operationIDsURL.path)",
      "--passthroughCustomScalars",
      output.path,
    ])
  }
}

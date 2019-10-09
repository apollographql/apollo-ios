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
  
  override func setUp() {
    super.setUp()
    CodegenTestHelper.deleteExistingOutputFolder()
  }
  
  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()
    super.tearDown()
  }
  
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
  
  func testCodegenWithSingleFileOutputsSingleFile() throws {
    let scriptFolderURL = try CodegenTestHelper.scriptsFolderURL()
    let starWarsFolderURL = try CodegenTestHelper.starWarsFolderURL()
    let starWarsSchemaFileURL = try CodegenTestHelper.starWarsSchemaFileURL()
    let outputFolder = try CodegenTestHelper.outputFolderURL()
    let outputFile = outputFolder.appendingPathComponent("API.swift")
    
    let options = ApolloCodegenOptions(outputFormat: .singleFile(atFileURL: outputFile),
                                       urlToSchemaFile: starWarsSchemaFileURL)
    do {
      _ = try ApolloCodegen.run(from: starWarsFolderURL,
                                scriptFolderURL: scriptFolderURL,
                                options: options)
    } catch {
      XCTFail("Error running codegen: \(error.localizedDescription)")
    }
    
    XCTAssertTrue(FileManager.default.apollo_folderExists(at: outputFolder))
    XCTAssertTrue(FileManager.default.apollo_fileExists(at: outputFile))
    
    let contents = try FileManager.default.contentsOfDirectory(atPath: outputFolder.path)    
    XCTAssertEqual(contents.count, 1)
  }
  
  func testCodegenWithMultipleFilesOutputsMultipleFiles() throws {
    let scriptFolderURL = try CodegenTestHelper.scriptsFolderURL()
    let starWarsFolderURL = try CodegenTestHelper.starWarsFolderURL()
    let starWarsSchemaFileURL = try CodegenTestHelper.starWarsSchemaFileURL()
    let outputFolder = try CodegenTestHelper.outputFolderURL()
    
    let options = ApolloCodegenOptions(outputFormat: .multipleFiles(inFolderAtURL: outputFolder),
                                       urlToSchemaFile: starWarsSchemaFileURL)
    
    _ = try ApolloCodegen.run(from: starWarsFolderURL,
                              scriptFolderURL: scriptFolderURL,
                              options: options)
    
    XCTAssertTrue(FileManager.default.apollo_folderExists(at: outputFolder))
    
    let contents = try FileManager.default.contentsOfDirectory(atPath: outputFolder.path)
    XCTAssertEqual(contents.count, 17)
  }
}

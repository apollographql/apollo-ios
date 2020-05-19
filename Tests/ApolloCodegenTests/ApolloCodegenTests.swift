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
    let sourceRoot = CodegenTestHelper.sourceRootURL()
    let output = sourceRoot.appendingPathComponent("API.swift")
    let schema = sourceRoot.appendingPathComponent("schema.json")
    
    let options = ApolloCodegenOptions(outputFormat: .singleFile(atFileURL: output),
                                       urlToSchemaFile: schema)

    
    XCTAssertEqual(options.includes, "./**/*.graphql")
    XCTAssertTrue(options.mergeInFieldsFromFragmentSpreads)
    XCTAssertNil(options.customScalarsPrefix)
    XCTAssertNil(options.namespace)
    XCTAssertNil(options.only)
    XCTAssertNil(options.operationIDsURL)
    switch options.outputFormat {
    case .singleFile(let fileURL):
      XCTAssertEqual(fileURL, output)
    case .multipleFiles:
      XCTFail("Nope, this should be a single file!")
    }
    XCTAssertFalse(options.omitDeprecatedEnumCases)
    XCTAssertFalse(options.passthroughCustomScalars)
    XCTAssertEqual(options.urlToSchemaFile, schema)
    XCTAssertEqual(options.modifier, .public)
    
    XCTAssertEqual(options.arguments, [
      "codegen:generate",
      "--target=swift",
      "--addTypename",
      "--includes='./**/*.graphql'",
      "--localSchemaFile='\(schema.path)'",
      "--mergeInFieldsFromFragmentSpreads",
      "'\(output.path)'",
    ])
  }
  
  func testCreatingOptionsWithAllParameters() throws {
    let customScalarsPrefix = "Scalar"
    let sourceRoot = CodegenTestHelper.sourceRootURL()
    let output = sourceRoot.appendingPathComponent("API")
    let schema = sourceRoot.appendingPathComponent("schema.json")
    let only = sourceRoot.appendingPathComponent("only.graphql")
    let operationIDsURL = sourceRoot.appendingPathComponent("operationIDs.json")
    let namespace = "ANameSpace"
    
    let options = ApolloCodegenOptions(codegenEngine: .swiftExperimental,
                                       customScalarsPrefix: customScalarsPrefix,
                                       includes: "*.graphql",
                                       mergeInFieldsFromFragmentSpreads: false,
                                       modifier: .internal,
                                       namespace: namespace,
                                       omitDeprecatedEnumCases: true,
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
    XCTAssertTrue(options.omitDeprecatedEnumCases)
    XCTAssertEqual(options.modifier, .internal)
    XCTAssertEqual(options.customScalarsPrefix, customScalarsPrefix)
    
    
    XCTAssertEqual(options.arguments, [
      "codegen:generate",
      "--target=json-modern",
      "--addTypename",
      "--includes='*.graphql'",
      "--localSchemaFile='\(schema.path)'",
      "--customScalarsPrefix=Scalar",
      "--namespace=ANameSpace",
      "--only='\(only.path)'",
      "--operationIdsPath='\(operationIDsURL.path)'",
      "--omitDeprecatedEnumCases",
      "--passthroughCustomScalars",
      "'\(output.path)'",
    ])
  }
  
  func testCodegenWithSingleFileOutputsSingleFile() throws {
    let scriptFolderURL = CodegenTestHelper.cliFolderURL()
    let starWarsFolderURL = CodegenTestHelper.starWarsFolderURL()
    let starWarsSchemaFileURL = CodegenTestHelper.starWarsSchemaFileURL()
    let outputFolder = CodegenTestHelper.outputFolderURL()
    let outputFile = outputFolder.appendingPathComponent("API.swift")
    
    let options = ApolloCodegenOptions(outputFormat: .singleFile(atFileURL: outputFile),
                                       urlToSchemaFile: starWarsSchemaFileURL,
                                       downloadTimeout: CodegenTestHelper.timeout)
    do {
      _ = try ApolloCodegen.run(from: starWarsFolderURL,
                                with: scriptFolderURL,
                                options: options)
    } catch {
      XCTFail("Error running codegen: \(error.localizedDescription)")
      return
    }
    
    XCTAssertTrue(FileManager.default.apollo.folderExists(at: outputFolder))
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: outputFile))
    
    let contents = try FileManager.default.contentsOfDirectory(atPath: outputFolder.path)    
    XCTAssertEqual(contents.count, 1)
  }
  
  func testCodegenWithMultipleFilesOutputsMultipleFiles() throws {
    let scriptFolderURL = CodegenTestHelper.cliFolderURL()
    let starWarsFolderURL = CodegenTestHelper.starWarsFolderURL()
    let starWarsSchemaFileURL = CodegenTestHelper.starWarsSchemaFileURL()
    let outputFolder = CodegenTestHelper.outputFolderURL()
    
    let options = ApolloCodegenOptions(outputFormat: .multipleFiles(inFolderAtURL: outputFolder),
                                       urlToSchemaFile: starWarsSchemaFileURL,
                                       downloadTimeout: CodegenTestHelper.timeout)
    
    _ = try ApolloCodegen.run(from: starWarsFolderURL,
                              with: scriptFolderURL,
                              options: options)
    
    XCTAssertTrue(FileManager.default.apollo.folderExists(at: outputFolder))
    
    let contents = try FileManager.default.contentsOfDirectory(atPath: outputFolder.path)
    XCTAssertEqual(contents.count, 17)
  }
}

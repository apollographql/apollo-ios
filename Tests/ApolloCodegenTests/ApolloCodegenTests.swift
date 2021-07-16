//
//  ApolloCodegenTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 10/7/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
import ApolloCodegenTestSupport
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
    XCTAssertEqual(options.customScalarFormat, .none)
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
  
  func testTryingToUseAFileURLToOutputMultipleFilesFails() {
    let scriptFolderURL = CodegenTestHelper.cliFolderURL()
    let starWarsFolderURL = CodegenTestHelper.starWarsFolderURL()
    let starWarsSchemaFileURL = CodegenTestHelper.starWarsSchemaFileURL()
    let outputFolder = CodegenTestHelper.outputFolderURL()
    let outputFile = outputFolder.appendingPathComponent("API.swift")
    
    let options = ApolloCodegenOptions(outputFormat: .multipleFiles(inFolderAtURL: outputFile),
                                       urlToSchemaFile: starWarsSchemaFileURL,
                                       downloadTimeout: CodegenTestHelper.timeout)
    do {
      _ = try ApolloCodegen.run(from: starWarsFolderURL,
                                with: scriptFolderURL,
                                options: options)
    } catch {
      switch error {
      case ApolloCodegen.CodegenError.multipleFilesButNotDirectoryURL(let url):
        XCTAssertEqual(url, outputFile)
      default:
        XCTFail("Unexpected error running codegen: \(error.localizedDescription)")

      }
    }
  }
  
  func testTryingToUseAFolderURLToOutputASingleFileFails() {
    let scriptFolderURL = CodegenTestHelper.cliFolderURL()
    let starWarsFolderURL = CodegenTestHelper.starWarsFolderURL()
    let starWarsSchemaFileURL = CodegenTestHelper.starWarsSchemaFileURL()
    let outputFolder = CodegenTestHelper.outputFolderURL()
    
    let options = ApolloCodegenOptions(outputFormat: .singleFile(atFileURL: outputFolder),
                                       urlToSchemaFile: starWarsSchemaFileURL,
                                       downloadTimeout: CodegenTestHelper.timeout)
    do {
      _ = try ApolloCodegen.run(from: starWarsFolderURL,
                                with: scriptFolderURL,
                                options: options)
    } catch {
      switch error {
      case ApolloCodegen.CodegenError.singleFileButNotSwiftFileURL(let url):
        XCTAssertEqual(url, outputFolder)
      default:
        XCTFail("Unexpected error running codegen: \(error.localizedDescription)")
      }
    }
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
    XCTAssertEqual(contents.count, 18)
  }
}

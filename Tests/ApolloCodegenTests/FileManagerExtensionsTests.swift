//
//  FileManagerExtensionsTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 10/7/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation
import XCTest
@testable import ApolloCodegenLib

class FileManagerExtensionsTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    CodegenTestHelper.downloadCLIIfNeeded()
    CodegenTestHelper.deleteExistingApolloFolder()
  }
  
  func testsFileExistsForZipFileURL() throws {
    let scriptsFolderURL = try CodegenTestHelper.scriptsFolderURL()
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromScripts: scriptsFolderURL)
    XCTAssertTrue(FileManager.default.apollo_fileExists(at: zipFileURL))
  }
  
  func testFolderDoesNotExistForZipFileURL() throws {
    let scriptsFolderURL = try CodegenTestHelper.scriptsFolderURL()
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromScripts: scriptsFolderURL)
    XCTAssertFalse(FileManager.default.apollo_folderExists(at: zipFileURL))
  }
  
  func testFolderExistsForScriptsFolderURL() throws {
    let scriptsFolderURL = try CodegenTestHelper.scriptsFolderURL()
    XCTAssertTrue(FileManager.default.apollo_folderExists(at: scriptsFolderURL))
  }
  
  func testFileDoesNotExistForScriptsFolderURL() throws {
    let scriptsFolderURL = try CodegenTestHelper.scriptsFolderURL()
    XCTAssertFalse(FileManager.default.apollo_fileExists(at: scriptsFolderURL))
  }
  
  func testSHASUMOfIncludedBinaryMatchesExpected() throws {
    let scriptsFolderURL = try CodegenTestHelper.scriptsFolderURL()
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromScripts: scriptsFolderURL)
    let shasum = try FileManager.default.apollo_shasum(at: zipFileURL)
    XCTAssertEqual(shasum, CLIExtractor.expectedSHASUM)
  }
}


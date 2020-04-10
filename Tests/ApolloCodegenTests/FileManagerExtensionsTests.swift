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
    let cliFolderURL = CodegenTestHelper.cliFolderURL()
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: cliFolderURL)
    XCTAssertTrue(FileManager.default.apollo_fileExists(at: zipFileURL))
  }
  
  func testFolderDoesNotExistForZipFileURL() throws {
    let cliFolderURL = CodegenTestHelper.cliFolderURL()
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: cliFolderURL)
    XCTAssertFalse(FileManager.default.apollo_folderExists(at: zipFileURL))
  }
  
  func testFolderExistsForCLIFolderURL() throws {
    let cliFolderURL = CodegenTestHelper.cliFolderURL()
    XCTAssertTrue(FileManager.default.apollo_folderExists(at: cliFolderURL))
  }
  
  func testFileDoesNotExistForCLIFolderURL() throws {
    let cliFolderURL = CodegenTestHelper.cliFolderURL()
    XCTAssertFalse(FileManager.default.apollo_fileExists(at: cliFolderURL))
  }
  
  func testSHASUMOfIncludedBinaryMatchesExpected() throws {
    let clifolderURL = CodegenTestHelper.cliFolderURL()
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: clifolderURL)
    let shasum = try FileManager.default.apollo_shasum(at: zipFileURL)
    XCTAssertEqual(shasum, CLIExtractor.expectedSHASUM)
  }
}


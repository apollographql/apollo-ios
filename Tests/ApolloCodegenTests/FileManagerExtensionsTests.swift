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
  
  func testsFileExistsForZipFileURL() throws {
    let scriptsFolderURL = try CodegenTestHelper.scriptsFolderURL()
    let zipFileURL = CLIExtractor.zipFileURL(fromScripts: scriptsFolderURL)
    XCTAssertTrue(FileManager.default.apollo_fileExists(at: zipFileURL))
  }
  
  func testFolderDoesNotExistForZipFileURL() throws {
    let scriptsFolderURL = try CodegenTestHelper.scriptsFolderURL()
    let zipFileURL = CLIExtractor.zipFileURL(fromScripts: scriptsFolderURL)
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
    let zipFileURL = CLIExtractor.zipFileURL(fromScripts: scriptsFolderURL)
    let shasum = try FileManager.default.apollo_shasum(at: zipFileURL)
    XCTAssertEqual(shasum, CLIExtractor.expectedSHASUM)
  }
  
  func testValidatingSHASUMWithMatchingWorks() throws {
    let scriptsFolderURL = try CodegenTestHelper.scriptsFolderURL()
    let zipFileURL = CLIExtractor.zipFileURL(fromScripts: scriptsFolderURL)
    try CLIExtractor.validateZipFileSHASUM(at: zipFileURL, expected: CLIExtractor.expectedSHASUM)
  }
  
  func testValidatingSHASUMFailsWithoutMatch() throws {
    let scriptsFolderURL = try CodegenTestHelper.scriptsFolderURL()
    let zipFileURL = CLIExtractor.zipFileURL(fromScripts: scriptsFolderURL)
    let bogusSHASUM = CLIExtractor.expectedSHASUM + "NOPE"
    do {
      try CLIExtractor.validateZipFileSHASUM(at: zipFileURL, expected: bogusSHASUM)
      XCTFail("This should not have validated!")
    } catch {
      switch error {
      case CLIExtractor.CLIExtractorError.zipFileHasInvalidSHASUM(let expectedSHASUM, let gotSHASUM):
        XCTAssertEqual(expectedSHASUM, bogusSHASUM)
        XCTAssertEqual(gotSHASUM, CLIExtractor.expectedSHASUM)
      default:
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
}


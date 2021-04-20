//
//  CLIExtractorTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 10/7/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib

class CLIExtractorTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    CodegenTestHelper.downloadCLIIfNeeded()
    CodegenTestHelper.deleteExistingApolloFolder()
  }
  
  private func checkSHASUMFileContentsDirectly(at url: URL,
                                               match expected: String,
                                               file: StaticString = #filePath,
                                               line: UInt = #line) {
    guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
      XCTFail("Could not load file at \(url.path)",
        file: file,
        line: line)
      return
    }
    
    XCTAssertEqual(contents,
                   expected,
                   "Direct check of SHASUM failed. Got \(contents), expected \(expected)",
                   file: #file,
                   line: #line)
  }
  
  private func validateSHASUMFile(shouldBeValid: Bool,
                                  apolloFolderURL: URL,
                                  match expected: String,
                                  file: StaticString = #filePath,
                                  line: UInt = #line) {
    do {
      let isValid = try CLIExtractor.validateSHASUMInExtractedFile(apolloFolderURL: apolloFolderURL, expected: expected)
      XCTAssertEqual(isValid,
                     shouldBeValid,
                     file: file,
                     line: line)
    } catch {
      XCTFail("Error validating shasum in extracted file: \(error)",
        file: file,
        line: line)
    }
  }
  
  func validateCLIIsExtractedWithRealSHASUM(file: StaticString = #filePath,
                                            line: UInt = #line) {
    let binaryFolderURL = CodegenTestHelper.binaryFolderURL()
    XCTAssertTrue(FileManager.default.apollo.folderExists(at: binaryFolderURL),
                  "Binary folder doesn't exist at \(binaryFolderURL)",
                  file: file,
                  line: line)
    let binaryURL = ApolloFilePathHelper.binaryURL(fromBinaryFolder: binaryFolderURL)
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: binaryURL),
                  "Binary doesn't exist at \(binaryURL)",
                  file: file,
                  line: line)
    let shasumFileURL = CodegenTestHelper.shasumFileURL()
    self.checkSHASUMFileContentsDirectly(at: shasumFileURL,
                                         match: CLIExtractor.expectedSHASUM,
                                         file: file,
                                         line: line)
  }
  
  func testValidatingSHASUMWithMatchingWorks() throws {
    let cliFolderURL = CodegenTestHelper.cliFolderURL()
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: cliFolderURL)
    try CLIExtractor.validateZipFileSHASUM(at: zipFileURL, expected: CLIExtractor.expectedSHASUM)
  }
  
  func testValidatingSHASUMFailsWithoutMatch() throws {
    let cliFolderURL = CodegenTestHelper.cliFolderURL()
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: cliFolderURL)
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
  
  func testExtractingZip() throws {
    // Check that the binary hasn't already been extracted
    // (it should be getting deleted in `setUp`)
    let binaryFolderURL = CodegenTestHelper.binaryFolderURL()
    XCTAssertFalse(FileManager.default.apollo.folderExists(at: binaryFolderURL))
    
    // Actually extract the CLI
    let cliFolderURL = CodegenTestHelper.cliFolderURL()
    let extractedURL = try CLIExtractor.extractCLIIfNeeded(from: cliFolderURL)
    
    // Make sure we're getting the binary folder path back and that something's now there.
    XCTAssertEqual(extractedURL.path, binaryFolderURL.path)
    self.validateCLIIsExtractedWithRealSHASUM()
    
    // Make sure the validator is working
    let apolloFolderURL = CodegenTestHelper.apolloFolderURL()
    self.validateSHASUMFile(shouldBeValid: true,
                            apolloFolderURL: apolloFolderURL,
                            match: CLIExtractor.expectedSHASUM)
    self.validateSHASUMFile(shouldBeValid: false,
                            apolloFolderURL: apolloFolderURL,
                            match: "NOPE")
  }
  
  func testReExtractingZipWithDifferentSHA() throws {
    // Extract the existing CLI
    let cliFolderURL = CodegenTestHelper.cliFolderURL()
    _ = try CLIExtractor.extractCLIIfNeeded(from: cliFolderURL)
    
    // Validate that it extracted and has the correct shasum
    self.validateCLIIsExtractedWithRealSHASUM()
    
    // Replace the SHASUM file URL with a fake that doesn't match
    let shasumFileURL = CodegenTestHelper.shasumFileURL()
    let fakeSHASUM = "Old Shasum"
    try fakeSHASUM.write(to: shasumFileURL, atomically: true, encoding: .utf8)
    
    // Validation should now fail since the SHASUMs don't match
    let apolloFolderURL = CodegenTestHelper.apolloFolderURL()
    XCTAssertFalse(try CLIExtractor.validateSHASUMInExtractedFile(apolloFolderURL: apolloFolderURL))
    
    // Now try extracting again, and check SHASUM is now real again
    _ = try CLIExtractor.extractCLIIfNeeded(from: cliFolderURL)
    self.validateCLIIsExtractedWithRealSHASUM()
  }
  
  func testFolderExistsButMissingSHASUMFileReExtractionWorks() throws {
    // Make sure there is an apollo folder but no `.shasum` file
    let apolloFolder = CodegenTestHelper.apolloFolderURL()
    try FileManager.default.apollo.createFolderIfNeeded(at: apolloFolder)
    
    let cliFolderURL = CodegenTestHelper.cliFolderURL()
    
    // Now try extracting again, and check SHASUM is now real again
    _ = try CLIExtractor.extractCLIIfNeeded(from: cliFolderURL)
    self.validateCLIIsExtractedWithRealSHASUM()
  }
  
  func testCorrectSHASUMButMissingBinaryReExtractionWorks() throws {
    // Write just the SHASUM file, but nothing else
    try CodegenTestHelper.writeSHASUMOnly(CLIExtractor.expectedSHASUM)
    
    // Make sure the binary folder's not there
    let binaryFolderURL = CodegenTestHelper.binaryFolderURL()
    XCTAssertFalse(FileManager.default.apollo.folderExists(at: binaryFolderURL))
    
    // Re-extract and now everything should be there
    let cliFolderURL = CodegenTestHelper.cliFolderURL()
    _ = try CLIExtractor.extractCLIIfNeeded(from: cliFolderURL)
    self.validateCLIIsExtractedWithRealSHASUM()
  }
  
  func testMissingSHASUMFileButCorrectZipFileCreatesSHASUMFile() throws {
    let shasumFileURL = CodegenTestHelper.shasumFileURL()
    try FileManager.default.apollo.deleteFile(at: shasumFileURL)
    
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: shasumFileURL))
    
    let cliFolderURL = CodegenTestHelper.cliFolderURL()
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: cliFolderURL)
    
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: zipFileURL))
    
    let binaryURL = try CLIExtractor.extractCLIIfNeeded(from: cliFolderURL)
    
    /// Was the binary extracted?
    XCTAssertTrue(FileManager.default.apollo.folderExists(at: binaryURL))
    
    /// Did the SHASUM file get created?
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: shasumFileURL))
    self.validateCLIIsExtractedWithRealSHASUM()
  }
}

//
//  URLExtensionsTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 6/7/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
import XCTest
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib
import ApolloUtils

class URLExtensionsTests: XCTestCase {
 
  func testGettingParentFolderURL() {
    let apolloCodegenTests = FileFinder.findParentFolder()
    
    let expectedParent = CodegenTestHelper.sourceRootURL()
      .appendingPathComponent("Tests")
    
    let parent = apolloCodegenTests.apollo.parentFolderURL()
    XCTAssertEqual(parent, expectedParent)
  }
  
  func testGettingChildFolderURL() {
    let testsFolderURL = CodegenTestHelper.sourceRootURL()
      .appendingPathComponent("Tests")
    
    let expectedChild = FileFinder.findParentFolder()
    
    let child = testsFolderURL.apollo.childFolderURL(folderName: "ApolloCodegenTests")
    XCTAssertEqual(child, expectedChild)
  }
  
  func testGettingChildFileURL() throws {
    let apolloCodegenTests = FileFinder.findParentFolder()

    let expectedFileURL = URL(fileURLWithPath: #file)

    let fileURL = try apolloCodegenTests.apollo.childFileURL(fileName: "URLExtensionsTests.swift")
    
    XCTAssertEqual(fileURL, expectedFileURL)
  }
  
  func testGettingChildFileURLWithEmptyFilenameThrows() {
    let starWars = CodegenTestHelper.starWarsFolderURL()
    
    do {
      _ = try starWars.apollo.childFileURL(fileName: "")
      XCTFail("That should have thrown")
    } catch {
      switch error {
      case ApolloURLError.fileNameIsEmpty:
        // This is what we want
        break
      default:
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testGettingHiddenChildFileURL() throws {
    let url = CodegenTestHelper.apolloFolderURL()
    
    let expectedFile = CodegenTestHelper.shasumFileURL()
    let child = try url.apollo.childFileURL(fileName: ".shasum")
    
    XCTAssertEqual(child, expectedFile)
  }
  
  func testIsDirectoryForExistingDirectory() {
    let parentDirectory = FileFinder.findParentFolder()
    XCTAssertTrue(FileManager.default.apollo.folderExists(at: parentDirectory))
    XCTAssertTrue(parentDirectory.apollo.isDirectoryURL)
  }
  
  func testIsDirectoryForExistingFile() {
    let currentFileURL = FileFinder.fileURL()
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: currentFileURL))
    XCTAssertFalse(currentFileURL.apollo.isDirectoryURL)
  }
  
  func testIsSwiftFileForExistingFile() {
    let currentFileURL = FileFinder.fileURL()
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: currentFileURL))
    XCTAssertTrue(currentFileURL.apollo.isSwiftFileURL)
  }
  
  func testIsSwiftFileForNonExistentFileWithSingleExtension() {
    let currentDirectory = FileFinder.findParentFolder()
    let doesntExist = currentDirectory.appendingPathComponent("test.swift")
    
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: doesntExist))
    XCTAssertTrue(doesntExist.apollo.isSwiftFileURL)
  }
  
  func testIsSwiftFileForNonExistentFileWithMultipleExtensions() {
    let currentDirectory = FileFinder.findParentFolder()
    let doesntExist = currentDirectory.appendingPathComponent("test.graphql.swift")
    
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: doesntExist))
    XCTAssertTrue(doesntExist.apollo.isSwiftFileURL)
  }
  
}

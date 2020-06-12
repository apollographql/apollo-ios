//
//  URLExtensionsTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 6/7/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
import XCTest
import ApolloCodegenLib
import ApolloCore

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
}

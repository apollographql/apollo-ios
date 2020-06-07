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
    let url = CodegenTestHelper.apolloFolderURL()
    let expectedParent = CodegenTestHelper.cliFolderURL()
    
    let parent = url.apollo.parentFolderURL()
    XCTAssertEqual(parent, expectedParent)
  }
  
  func testGettingChildFolderURL() {
    let url = CodegenTestHelper.cliFolderURL()
    let expectedChild = CodegenTestHelper.apolloFolderURL()
    
    let child = url.apollo.childFolderURL(folderName: "apollo")
    XCTAssertEqual(child, expectedChild)
  }
  
  func testGettingChildFileURL() throws {
    let starWars = CodegenTestHelper.starWarsFolderURL()
    let expectedSchema = CodegenTestHelper.starWarsSchemaFileURL()

    let schema = try starWars.apollo.childFileURL(fileName: "schema.json")
    
    XCTAssertEqual(schema, expectedSchema)
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

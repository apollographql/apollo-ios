import Foundation
import XCTest
import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib

class URLExtensionsTests: XCTestCase {
 
  func testGettingParentFolderURL() {
    let apolloCodegenTests = FileFinder.findParentFolder()
    
    let expectedParent = CodegenTestHelper.sourceRootURL()
      .appendingPathComponent("Tests")
    
    let parent = apolloCodegenTests.parentFolderURL()
    XCTAssertEqual(parent, expectedParent)
  }
  
  func testGettingChildFolderURL() {
    let testsFolderURL = CodegenTestHelper.sourceRootURL()
      .appendingPathComponent("Tests")
    
    let expectedChild = FileFinder.findParentFolder()
    
    let child = testsFolderURL.childFolderURL(folderName: "ApolloCodegenTests")
    XCTAssertEqual(child, expectedChild)
  }
  
  func testGettingChildFileURL() throws {
    let apolloCodegenTests = FileFinder.findParentFolder()

    let expectedFileURL = URL(fileURLWithPath: #file)

    let fileURL = try apolloCodegenTests.childFileURL(fileName: "URLExtensionsTests.swift")
    
    XCTAssertEqual(fileURL, expectedFileURL)
  }
  
  func testGettingChildFileURLWithEmptyFilenameThrows() {
    let starWars = CodegenTestHelper.starWarsFolderURL()
    
    do {
      _ = try starWars.childFileURL(fileName: "")
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
    let parentURL = FileFinder.findParentFolder()
    let filename = ".hiddenFile"

    let expectedURL = parentURL.appendingPathComponent(filename, isDirectory: false)
    let childURL = try parentURL.childFileURL(fileName: filename)

    XCTAssertEqual(childURL, expectedURL)
  }
  
  func testIsDirectoryForExistingDirectory() {
    let parentDirectory = FileFinder.findParentFolder()
    XCTAssertTrue(ApolloFileManager.default.doesDirectoryExist(atPath: parentDirectory.path))
    XCTAssertTrue(parentDirectory.isDirectoryURL)
  }
  
  func testIsDirectoryForExistingFile() {
    let currentFileURL = FileFinder.fileURL()
    XCTAssertTrue(ApolloFileManager.default.doesFileExist(atPath: currentFileURL.path))
    XCTAssertFalse(currentFileURL.isDirectoryURL)
  }
  
  func testIsSwiftFileForExistingFile() {
    let currentFileURL = FileFinder.fileURL()
    XCTAssertTrue(ApolloFileManager.default.doesFileExist(atPath: currentFileURL.path))
    XCTAssertTrue(currentFileURL.isSwiftFileURL)
  }
  
  func testIsSwiftFileForNonExistentFileWithSingleExtension() {
    let currentDirectory = FileFinder.findParentFolder()
    let doesntExist = currentDirectory.appendingPathComponent("test.swift")
    
    XCTAssertFalse(ApolloFileManager.default.doesFileExist(atPath: doesntExist.path))
    XCTAssertTrue(doesntExist.isSwiftFileURL)
  }
  
  func testIsSwiftFileForNonExistentFileWithMultipleExtensions() {
    let currentDirectory = FileFinder.findParentFolder()
    let doesntExist = currentDirectory.appendingPathComponent("test.graphql.swift")
    
    XCTAssertFalse(ApolloFileManager.default.doesFileExist(atPath: doesntExist.path))
    XCTAssertTrue(doesntExist.isSwiftFileURL)
  }
  
}

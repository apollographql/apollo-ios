//
//  CLIDownloaderTests.swift
//  Apollo
//
//  Created by Ellen Shapiro on 10/22/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

@testable import ApolloCodegenLib
import ApolloCodegenTestSupport
import XCTest

class CLIDownloaderTests: XCTestCase {
  
  func testRedownloading() throws {
    let scriptsURL = CodegenTestHelper.cliFolderURL()
    
    try CLIDownloader.forceRedownload(cliFolderURL: scriptsURL, timeout: CodegenTestHelper.timeout)
    
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: scriptsURL)
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: zipFileURL))
    XCTAssertEqual(try FileManager.default.apollo.shasum(at: zipFileURL), CLIExtractor.expectedSHASUM)
  }
  
  func testDownloadingToFolderThatDoesntAlreadyExistWorks() throws {
    let scriptsURL = CodegenTestHelper.cliFolderURL()
    try FileManager.default.apollo.deleteFolder(at: scriptsURL)
    
    XCTAssertFalse(FileManager.default.apollo.folderExists(at: scriptsURL))
    
    try CLIDownloader.downloadIfNeeded(cliFolderURL: scriptsURL, timeout: 90.0)
    
    XCTAssertTrue(FileManager.default.apollo.folderExists(at: scriptsURL))
  }
  
  func testTimeoutThrowsCorrectError() throws {
    let scriptsURL = CodegenTestHelper.cliFolderURL()
    
    // This file is big enough that unless both you and the server have a terabyte connection, 2 seconds won't be enough time to download it.
    do {
      try CLIDownloader.forceRedownload(cliFolderURL: scriptsURL, timeout: 2.0)
    } catch {
      guard let downloaderError = error as? URLDownloader.DownloaderError else {
        XCTFail("Wrong type of error")
        return
      }
      
      switch downloaderError {
      case .downloadTimedOut(let seconds):
        XCTAssertEqual(seconds, 2.0, accuracy: 0.0001)
      default:
        XCTFail("Wrong type of error")
      }
    }
  }
}


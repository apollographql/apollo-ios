//
//  CLIDownloaderTests.swift
//  Apollo
//
//  Created by Ellen Shapiro on 10/22/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

@testable import ApolloCodegenLib
import XCTest

class CLIDownloaderTests: XCTestCase {
  
  func testRedownloading() throws {
    let scriptsURL = try CodegenTestHelper.scriptsFolderURL()
    try CLIDownloader.forceRedownload(scriptsFolderURL: scriptsURL)
    
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromScripts: scriptsURL)
    XCTAssertTrue(FileManager.default.apollo_fileExists(at: zipFileURL))
    XCTAssertEqual(try FileManager.default.apollo_shasum(at: zipFileURL), CLIExtractor.expectedSHASUM)    
  }
}


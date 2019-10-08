//
//  CodegenTestHelper.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 10/7/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import ApolloCodegenLib

struct CodegenTestHelper {
  
  enum CodegenTestError: Error {
    case couldNotGetSourceRoot
  }
  
  static func sourceRootURL() throws -> URL {
    guard let sourceRootPath = ProcessInfo.processInfo.environment["SRCROOT"] else {
      throw CodegenTestError.couldNotGetSourceRoot
    }
    
    return URL(fileURLWithPath: sourceRootPath)
  }
  
  static func scriptsFolderURL() throws -> URL {
    let sourceRoot = try self.sourceRootURL()
    return sourceRoot.appendingPathComponent("scripts")
  }
  
  static func apolloFolderURL() throws -> URL {
    let scripts = try self.scriptsFolderURL()
    return CLIExtractor.apolloFolderURL(fromScripts: scripts)
  }
  
  static func binaryFolderURL() throws -> URL {
    let apollo = try self.apolloFolderURL()
    return CLIExtractor.binaryFolderURL(fromApollo: apollo)
  }
  
  static func shasumFileURL() throws -> URL {
    let apollo = try self.apolloFolderURL()
    return CLIExtractor.shasumFileURL(fromApollo: apollo)
  }
  
  static func deleteExistingApolloFolder(file: StaticString = #file,
                                         line: UInt = #line) {
    do {
      let apolloFolderURL = try self.apolloFolderURL()
      try FileManager.default.apollo_deleteFolder(at: apolloFolderURL)
    } catch {
      XCTFail("Error deleting Apollo folder!",
              file: file,
              line: line)
    }
  }
  
  static func writeSHASUMOnly(_ shasum: String) throws {
    let shasumFileURL = try self.shasumFileURL()
    let shasumParent = shasumFileURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: shasumParent,
                                            withIntermediateDirectories: true)    
    FileManager.default.createFile(atPath: shasumFileURL.path,
                                   contents: shasum.data(using: .utf8))
  }
}

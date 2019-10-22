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
  
  enum CodegenTestError: Error, LocalizedError {
    case couldNotGetSourceRoot
    
    var errorDescription: String? {
      switch self {
      case .couldNotGetSourceRoot:
        return "Couldn't get SRCROOT for the test environment. Make sure it's being set in the scheme!"
      }
    }
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
    return ApolloFilePathHelper.apolloFolderURL(fromScripts: scripts)
  }
  
  static func binaryFolderURL() throws -> URL {
    let apollo = try self.apolloFolderURL()
    return ApolloFilePathHelper.binaryFolderURL(fromApollo: apollo)
  }
  
  static func shasumFileURL() throws -> URL {
    let apollo = try self.apolloFolderURL()
    return ApolloFilePathHelper.shasumFileURL(fromApollo: apollo)
  }
  
  static func starWarsFolderURL() throws -> URL {
    let source = try self.sourceRootURL()
    return source
      .appendingPathComponent("Tests")
      .appendingPathComponent("StarWarsAPI")
  }
  
  static func starWarsSchemaFileURL() throws -> URL {
    let starWars = try self.starWarsFolderURL()
    return starWars.appendingPathComponent("schema.json")
  }
  
  static func outputFolderURL() throws -> URL {
    let sourceRoot = try self.sourceRootURL()
    return sourceRoot
      .appendingPathComponent("Tests")
      .appendingPathComponent("ApolloCodegenTests")
      .appendingPathComponent("Output")
  }
  
  static func deleteExistingOutputFolder(file: StaticString = #file,
                                         line: UInt = #line) {
    do {
      let outputFolderURL = try self.outputFolderURL()
      try FileManager.default.apollo_deleteFolder(at: outputFolderURL)
    } catch {
      XCTFail("Error deleting output folder!",
              file: file,
              line: line)
    }
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

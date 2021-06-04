//
//  CodegenTestHelper.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 10/7/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import ApolloCodegenLib

public struct CodegenTestHelper {
  
  public static func dummyOptions() -> ApolloCodegenOptions {
    let unusedURL = CodegenTestHelper.apolloFolderURL()
    return ApolloCodegenOptions(outputFormat: .singleFile(atFileURL: unusedURL),
                                urlToSchemaFile: unusedURL)
  }
  
  public static func dummyOptionsNoModifier() -> ApolloCodegenOptions {
    let unusedURL = CodegenTestHelper.apolloFolderURL()
    return ApolloCodegenOptions(modifier: .none,
                                outputFormat: .singleFile(atFileURL: unusedURL),
                                urlToSchemaFile: unusedURL)
  }
  
  public static func handleFileLoadError(_ error: Error,
                                  file: StaticString = #filePath,
                                  line: UInt = #line) {
    let nsError = error as NSError
    if let underlying = nsError.userInfo["NSUnderlyingError"] as? NSError,
      underlying.domain == NSPOSIXErrorDomain,
      underlying.code == 4 { // The filesystem can't open the file, which for some reason is only happening on my laptop.
        // Ellen's computer has lost its mind and intermittently won't load files
        // from the file system with inexplicable process interrupted errors
        // This is not technically a failure but we shouldn't fail the test on it.
        // TODO: Mark test as skipped in Xcode 11.4
        print("🐶☕️🔥 This is fine")
    } else {
      // There was an actual problem.
      XCTFail("Unexpected error loading file: \(error)",
        file: file,
        line: line)
    }
  }
  
  // Centralized timeout for adjustment when working on terrible wifi
  public static var timeout: Double = 90.0
  
  public static func sourceRootURL() -> URL {
    FileFinder.findParentFolder()
        .deletingLastPathComponent() // Tests
        .deletingLastPathComponent() // apollo-ios
  }
  
  public static func cliFolderURL() -> URL {
    self.sourceRootURL()
      .appendingPathComponent("Tests")
      .appendingPathComponent("ApolloCodegenTests")
      .appendingPathComponent("scripts directory")
  }
  
  public static func apolloFolderURL() -> URL {
    let scripts = self.cliFolderURL()
    return ApolloFilePathHelper.apolloFolderURL(fromCLIFolder: scripts)
  }
  
  public static func binaryFolderURL() -> URL {
    let apollo = self.apolloFolderURL()
    return ApolloFilePathHelper.binaryFolderURL(fromApollo: apollo)
  }
  
  public static func shasumFileURL() -> URL {
    let apollo = self.apolloFolderURL()
    return ApolloFilePathHelper.shasumFileURL(fromApollo: apollo)
  }
  
  public static func starWarsFolderURL() -> URL {
    let source = self.sourceRootURL()
    return source
      .appendingPathComponent("Sources")
      .appendingPathComponent("StarWarsAPI")
  }
  
  public static func starWarsSchemaFileURL() -> URL {
    let starWars = self.starWarsFolderURL()
    return starWars
      .appendingPathComponent("graphql")
      .appendingPathComponent("schema.json")
  }
  
  public static func outputFolderURL() -> URL {
    let sourceRoot = self.sourceRootURL()
    return sourceRoot
      .appendingPathComponent("Tests")
      .appendingPathComponent("ApolloCodegenTests")
      .appendingPathComponent("Output")
  }
  
  public static func schemaFolderURL() -> URL {
    let sourceRoot = self.sourceRootURL()
    return sourceRoot
      .appendingPathComponent("Tests")
      .appendingPathComponent("ApolloCodegenTests")
      .appendingPathComponent("Schema")
  }
  
  public static func deleteExistingOutputFolder(file: StaticString = #filePath,
                                         line: UInt = #line) {
    do {
      let outputFolderURL = self.outputFolderURL()
      try FileManager.default.apollo.deleteFolder(at: outputFolderURL)
    } catch {
      XCTFail("Error deleting output folder!",
              file: file,
              line: line)
    }
  }
  
  public static func downloadCLIIfNeeded(file: StaticString = #filePath,
                                  line: UInt = #line) {
    do {
      let cliFolderURL = self.cliFolderURL()
      try CLIDownloader.downloadIfNeeded(cliFolderURL: cliFolderURL, timeout: CodegenTestHelper.timeout)
    } catch {
      XCTFail("Error downloading CLI if needed: \(error)",
              file: file,
              line: line)
    }
  }
  
  public static func deleteExistingApolloFolder(file: StaticString = #filePath,
                                         line: UInt = #line) {
    do {
      let apolloFolderURL = self.apolloFolderURL()
      try FileManager.default.apollo.deleteFolder(at: apolloFolderURL)
    } catch {
      XCTFail("Error deleting Apollo folder: \(error)",
              file: file,
              line: line)
    }
  }
  
  public static func writeSHASUMOnly(_ shasum: String) throws {
    let shasumFileURL = self.shasumFileURL()
    let shasumParent = shasumFileURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: shasumParent,
                                            withIntermediateDirectories: true)    
    FileManager.default.createFile(atPath: shasumFileURL.path,
                                   contents: shasum.data(using: .utf8))
  }
}

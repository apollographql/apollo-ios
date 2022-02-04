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
    
  // Centralized timeout for adjustment when working on terrible wifi
  public static var timeout: Double = 90.0
  
  public static func sourceRootURL() -> URL {
    FileFinder.findParentFolder()
        .deletingLastPathComponent() // Tests
        .deletingLastPathComponent() // apollo-ios
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

  public static func schemaOutputURL() -> URL {
    outputFolderURL().appendingPathComponent("schema.graphqls")
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
      try FileManager.default.apollo.deleteDirectory(atPath: outputFolderURL.path)
    } catch {
      XCTFail("Error deleting output folder!",
              file: file,
              line: line)
    }
  }
}

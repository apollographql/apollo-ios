//
//  CodegenTestHelper.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 10/7/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

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
}

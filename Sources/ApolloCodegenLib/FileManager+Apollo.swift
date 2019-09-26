//
//  FileManager+Apollo.swift
//  ApolloCodegenLib
//
//  Created by Ellen Shapiro on 9/25/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

public extension FileManager {

  /// Checks if a file exists (and is not a folder) at the given path
  /// - Parameter path: The path to check
  /// - Returns: `true` if there is something at the path and it is a file, not a folder.
  func apollo_fileExists(at path: String) -> Bool {
    var isFolder = ObjCBool(false)
    let exists = self.fileExists(atPath: path, isDirectory: &isFolder)
    
    return exists && !isFolder.boolValue
  }

  /// Checks if a file exists (and is not a folder) at the given URL
  /// - Parameter url: The URL to check
  /// - Returns: `true` if there is something at the URL and it is a file, not a folder.
  func apollo_fileExists(at url: URL) -> Bool {
    return self.apollo_fileExists(at: url.path)
  }

  /// Checks if a folder exists (and is not a file) at the given path.
  /// - Parameter path: The path to check
  /// - Returns: `true` if there is something at the path and it is a folder, not a file.
  func apollo_folderExists(at path: String) -> Bool {
    var isFolder = ObjCBool(false)
    let exists = self.fileExists(atPath: path, isDirectory: &isFolder)
    
    return exists && isFolder.boolValue
  }
  
  /// Checks if a folder exists (and is not a file) at the given URL.
  /// - Parameter url: The URL to check
  /// - Returns: `true` if there is something at the URL and it is a folder, not a file.
  func apollo_folderExists(at url: URL) -> Bool {
    return self.apollo_folderExists(at: url.path)
  }
}

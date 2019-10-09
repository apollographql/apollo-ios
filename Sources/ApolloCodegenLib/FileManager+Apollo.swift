//
//  FileManager+Apollo.swift
//  ApolloCodegenLib
//
//  Created by Ellen Shapiro on 9/25/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation
import CommonCrypto

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
  
  /// Checks if a folder exists then attempts to delete it if it's there.
  /// 
  /// - Parameter url: The URL to delete the folder for
  func apollo_deleteFolder(at url: URL) throws {
    guard apollo_folderExists(at: url) else {
      // Nothing to delete!
      return
    }
    
    try self.removeItem(at: url)
  }
  
  func apollo_createContainingFolderIfNeeded(for fileURL: URL) throws {
    let parent = fileURL.deletingLastPathComponent()
    try self.apollo_createFolderIfNeeded(at: parent)
  }
  
  func apollo_createFolderIfNeeded(at url: URL) throws {
    guard !self.apollo_folderExists(at: url) else {
      // Folder already exists, nothing more to do here.
      return
    }
    
    try self.createDirectory(atPath: url.path,
                             withIntermediateDirectories: true)
  }
  
  func apollo_shasum(at fileURL: URL) throws -> String {
    let file = try FileHandle(forReadingFrom: fileURL)
    defer {
        file.closeFile()
    }
    
    let buffer = 1024 * 1024 // 1GB
    
    var context = CC_SHA256_CTX()
    CC_SHA256_Init(&context)
    
    while autoreleasepool(invoking: {
      let data = file.readData(ofLength: buffer)
      guard !data.isEmpty else {
        // Nothing more to read!
        return false
      }
      
      _ = data.withUnsafeBytes { bytesFromBuffer -> Int32 in
        guard let rawBytes = bytesFromBuffer.bindMemory(to: UInt8.self).baseAddress else {
          return Int32(kCCMemoryFailure)
        }
        return CC_SHA256_Update(&context, rawBytes, numericCast(data.count))
      }
      
      return true
    }) {}
    
    var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
    _ = digestData.withUnsafeMutableBytes { bytesFromDigest -> Int32 in
      guard let rawBytes = bytesFromDigest.bindMemory(to: UInt8.self).baseAddress else {
        return Int32(kCCMemoryFailure)
      }
      
      return CC_SHA256_Final(rawBytes, &context)
    }

    return digestData
      .map { String(format: "%02hhx", $0) }
      .joined()
  }
}

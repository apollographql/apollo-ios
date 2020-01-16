//
//  ScriptDirectoryFinder.swift
//  ApolloCodegenLib
//
//  Created by Ellen Shapiro on 12/11/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

struct ScriptDirectoryFinder {
  
  enum FindError: Error, LocalizedError {
    /// SPM-related
    case noBuildRootEnvironmentVariable
    case couldNotFindSourcePackagesDirectory(buildRoot: String)
    
    /// CocoaPods-related
    case noPodsRootEnvironmentVariable
    
    /// Carthage-related
    case noSourceRootEnvironmentVariable
    
    var errorDescription: String? {
      switch self {
      case .noBuildRootEnvironmentVariable:
        return "Could not find the `BUILD_ROOT` environment variable. Please ensure this is provided and that you are using Swift Package Manager to install Apollo."
      case .couldNotFindSourcePackagesDirectory(let buildRoot):
        return "Unable to locate SourcePackages directory from `BUILD_ROOT`: '\(buildRoot)', ensure that the apollo-ios SDK has finished installing with Swift Package Manager."
      case .noPodsRootEnvironmentVariable:
        return "Could not find the `PODS_ROOT` environment variable. Please ensure this is provided and that you are using CocoaPods to install Apollo."
      case .noSourceRootEnvironmentVariable:
        return "Could not find the `SOURCE_ROOT` environment variable. Please ensure this is provided and "
      }
    }
  }
  
  static func findScriptsFolder(for packageManager: PackageManager,
                                in environment: [String: String]) throws -> URL {
    switch packageManager {
    case .swiftPackageManager:
      return try self.findScriptsFolderForSPM(in: environment)
    case .cocoaPods:
      return try self.findScriptsFolderForCocoaPods(in: environment)
    case .carthage:
      return try self.findScriptsFolderForCarthage(in: environment)
    case .custom(let urlToScriptsFolder):
      return urlToScriptsFolder
    }
  }
  
  private static func findScriptsFolderForSPM(in environment: [String: String]) throws -> URL {
    guard let buildRootPath = environment["BUILD_ROOT"] else {
      throw FindError.noBuildRootEnvironmentVariable
    }
    
    let buildRootURL = URL(fileURLWithPath: buildRootPath)
    var currentDirectoryURL = buildRootURL
    
    // Go to the build root and search up the chain to find the Derived Data Path where the source packages are checked out.
    while !FileManager.default.apollo_folderExists(at: currentDirectoryURL.appendingPathComponent("SourcePackages")) {
      guard currentDirectoryURL.path != "/" else {
        throw FindError.couldNotFindSourcePackagesDirectory(buildRoot: buildRootURL.path)
      }
      
      currentDirectoryURL = currentDirectoryURL.deletingLastPathComponent()
      CodegenLogger.log("Now looking in \(currentDirectoryURL)")
    }
    
    return currentDirectoryURL
      .appendingPathComponent("SourcePackages")
      .appendingPathComponent("checkouts")
      .appendingPathComponent("apollo-ios")
      .appendingPathComponent("scripts")
  }
  
  private static func findScriptsFolderForCocoaPods(in environment: [String: String]) throws -> URL {
    guard let podsRootPath = environment["PODS_ROOT"] else {
      throw FindError.noPodsRootEnvironmentVariable
    }
    
    let podsRootURL = URL(fileURLWithPath: podsRootPath)
    
    return podsRootURL
      .appendingPathComponent("Apollo")
      .appendingPathComponent("scripts")
    
  }
  
  private static func findScriptsFolderForCarthage(in environment: [String: String]) throws -> URL {
    guard let sourceRootPath = environment["SRCROOT"] else {
      throw FindError.noSourceRootEnvironmentVariable
    }
    
    let sourceRootURL = URL(fileURLWithPath: sourceRootPath)
    return sourceRootURL
      .appendingPathComponent("Carthage")
      .appendingPathComponent("Checkouts")
      .appendingPathComponent("apollo-ios")
      .appendingPathComponent("scripts")
  }
}

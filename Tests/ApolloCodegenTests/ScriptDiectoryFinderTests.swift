//
//  ScriptDirectoryFinderTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 12/11/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import ApolloCodegenLib

class ScriptDirectoryFinderTests: XCTestCase {
  
  func testMissingPathForSPMBuildRootThrowsCorrectError() {
    XCTAssertThrowsError(try ScriptDirectoryFinder.findScriptsFolder(for: .swiftPackageManager, in: [:])) { error in
      switch error {
      case ScriptDirectoryFinder.FindError.noBuildRootEnvironmentVariable:
        // This is what we want
        break
      default:
        XCTFail("Incorrect error: \(error)")
      }
    }
  }
  
  func testBogusPathForSPMBuildRootThrowsCorrectError() {
    let fakeEnvironment = [
      "BUILD_ROOT": "/Applications"
    ]

    XCTAssertThrowsError(try ScriptDirectoryFinder.findScriptsFolder(for: .swiftPackageManager, in: fakeEnvironment)) { error in
      switch error {
      case ScriptDirectoryFinder.FindError.couldNotFindSourcePackagesDirectory(let buildRoot):
        XCTAssertEqual(buildRoot, "/Applications")
      default:
        XCTFail("Incorrect error: \(error)")
      }
    }
  }
  
  func testBuildRootWithSourcePackagesFolderGivesCorrectPath() throws {
    let actualSourceRootPath = try XCTUnwrap(ProcessInfo.processInfo.environment["SRCROOT"])
    
    let fakeEnvironment = [
      "BUILD_ROOT": "\(actualSourceRootPath)/Tests/ApolloCodegenTests"
    ]
    
    let spmScriptFolderURL = try ScriptDirectoryFinder.findScriptsFolder(for: .swiftPackageManager, in: fakeEnvironment)
    
    XCTAssertEqual(spmScriptFolderURL.path, "\(actualSourceRootPath)/Tests/ApolloCodegenTests/SourcePackages/checkouts/apollo-ios/scripts")
  }
  
  
  func testMissingPodsRootPathThrowsCorrectError() {
    XCTAssertThrowsError(try ScriptDirectoryFinder.findScriptsFolder(for: .cocoaPods, in: [:])) { error in
      switch error {
      case ScriptDirectoryFinder.FindError.noPodsRootEnvironmentVariable:
        // This is what we want.
        break
      default:
        XCTFail("Incorrect error: \(error)")
      }
    }
  }
  
  func testPresentPodsRootPathReturnsCorrectURL() throws {
    let fakeEnvironment = [
      "PODS_ROOT" : "/Path/to/Pods"
    ]
    
    let podsScriptFolderURL = try ScriptDirectoryFinder.findScriptsFolder(for: .cocoaPods, in: fakeEnvironment)

    XCTAssertEqual(podsScriptFolderURL.path, "/Path/to/Pods/Apollo/scripts")
    
  }
  
  func testMissingSourceRootPathForCarthageThrowsCorrectError() {
    XCTAssertThrowsError(try ScriptDirectoryFinder.findScriptsFolder(for: .carthage, in: [:])) { error in
      switch error {
      case ScriptDirectoryFinder.FindError.noSourceRootEnvironmentVariable:
        // This is what we want.
        break
      default:
        XCTFail("Incorrect error: \(error)")
      }
    }
  }
  
  func testPresentSourceRootPathReturnsCorrectURL() throws {
    let fakeEnvironment = [
      "SRCROOT": "/Path/to/source/root"
    ]
    
    let carthageScriptFolderURL = try ScriptDirectoryFinder.findScriptsFolder(for: .carthage, in: fakeEnvironment)

    XCTAssertEqual(carthageScriptFolderURL.path, "/Path/to/source/root/Carthage/Checkouts/apollo-ios/scripts")    
  }
  
  func testCustomPackageManagerGivesYouBackWhateverYouHandIt() throws {
    let url = URL(string: "https://apollographql.com")!
    
    let returnedURL = try ScriptDirectoryFinder.findScriptsFolder(for: .custom(scriptsFolderURL: url), in: [:])
    
    XCTAssertEqual(returnedURL, url)
    
    let fileURL = URL(fileURLWithPath: "/Applications")
    
    let returnedFileURL = try ScriptDirectoryFinder.findScriptsFolder(for: .custom(scriptsFolderURL: fileURL), in: [:])
    
    XCTAssertEqual(returnedFileURL, fileURL)
  }
}

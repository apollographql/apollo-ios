import XCTest
import Nimble
import ApolloInternalTestHelpers
@testable import CodegenCLI
import ArgumentParser
import Apollo

class VerifyCLIVersionUpdateTest: XCTestCase {
  /// This test verifies that the `Constants/CLIVersion` is updated when the version of Apollo
  /// changes. It matches the CLI version against the `Apollo Info.plist` version number.
  /// This version number uses the project configurations `CURRENT_PROJECT_VERSION`.
  func test__cliVersion__matchesApolloProjectVersion() {
    // given
    let codegenLibVersion = ApolloLibraryVersion

    // when
    let cliVersion = CodegenCLI.Constants.CLIVersion

    // then
    expect(cliVersion).to(equal(codegenLibVersion))
  }
}

class VersionCheckerTests: XCTestCase {

  var fileManager: TestIsolatedFileManager!

  override func setUpWithError() throws {
    try super.setUpWithError()
    fileManager = try self.testIsolatedFileManager()
  }

  override func tearDown() {
    super.tearDown()
    fileManager = nil
  }

  private func version1PackageResolvedFileBody(apolloVersion version: String) -> String {
    return """
    {
      "object": {
        "pins": [
          {
            "package": "Apollo",
            "repositoryURL": "https://github.com/apollographql/apollo-ios.git",
            "state": {
              "branch": null,
              "revision": "5349afb4e9d098776cc44280258edd5f2ae571ed",
              "version": "\(version)"
            }
          }
        ]
      },
      "version": 1
    }
    """
  }

  private func version2PackageResolvedFileBody(apolloVersion version: String) -> String {
    return """
    {
      "pins": [
        {
          "identity": "apollo-ios",
          "kind" : "remoteSourceControl",
          "location": "https://github.com/apollographql/apollo-ios.git",
          "state": {
            "revision": "5349afb4e9d098776cc44280258edd5f2ae571ed",
            "version": "\(version)"
          }
        }
      ],
      "version": 2
    }
    """
  }

  // MARK: - Tests

  func test__matchCLIVersionToApolloVersion__givenNoPackageResolvedFileInProject_returnsNoApolloVersionFound() throws {
    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: fileManager.directoryURL
    )

    // then
    expect(result).to(equal(.noApolloVersionFound))
  }

  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInProjectRoot_withVersion1FileFormat_hasMatchingVersion_returns_versionMatch() throws {
    // given
    try fileManager.createFile(
      body: version1PackageResolvedFileBody(apolloVersion: Constants.CLIVersion),
      named: "Package.resolved"
    )

    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: fileManager.directoryURL
    )

    // then
    expect(result).to(equal(.versionMatch))
  }

  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInProjectRoot_withVersion1FileFormat_hasNonMatchingVersion_returns_versionMismatch() throws {
    // given
    let apolloVersion = "1.0.0.test-1"
    try fileManager.createFile(
      body: version1PackageResolvedFileBody(apolloVersion: apolloVersion),
      named: "Package.resolved"
    )

    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: fileManager.directoryURL
    )

    // then
    expect(result).to(equal(.versionMismatch(cliVersion: Constants.CLIVersion, apolloVersion: apolloVersion)))
  }

  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInProjectRoot_withVersion2FileFormat_hasMatchingVersion_returns_versionMatch() throws {
    // given
    try fileManager.createFile(
      body: version2PackageResolvedFileBody(apolloVersion: Constants.CLIVersion),
      named: "Package.resolved"
    )

    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: fileManager.directoryURL
    )

    // then
    expect(result).to(equal(.versionMatch))
  }

  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInProjectRoot_withVersion2FileFormat_hasNonMatchingVersion_returns_versionMismatch() throws {
    // given
    let apolloVersion = "1.0.0.test-1"
    try fileManager.createFile(
      body: version2PackageResolvedFileBody(apolloVersion: apolloVersion),
      named: "Package.resolved"
    )

    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: fileManager.directoryURL
    )

    // then
    expect(result).to(equal(.versionMismatch(cliVersion: Constants.CLIVersion, apolloVersion: apolloVersion)))
  }

  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInProjectRoot_noProjectRootURL_hasMatchingVersion_returns_versionMatch() throws {
    // given
    try fileManager.createFile(
      body: version2PackageResolvedFileBody(apolloVersion: Constants.CLIVersion),
      named: "Package.resolved"
    )

    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: nil
    )

    // then
    expect(result).to(equal(.versionMatch))
  }

  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInProjectRoot_noProjectRootURL_hasNonMatchingVersion_returns_versionMismatch() throws {
    // given
    let apolloVersion = "1.0.0.test-1"
    try fileManager.createFile(
      body: version2PackageResolvedFileBody(apolloVersion: apolloVersion),
      named: "Package.resolved"
    )

    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: nil
    )

    // then
    expect(result).to(equal(.versionMismatch(cliVersion: Constants.CLIVersion, apolloVersion: apolloVersion)))
  }

  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInXcodeWorkspace_withVersion2FileFormat_hasMatchingVersion_returns_versionMatch() throws {
    // given
    try fileManager.createFile(
      body: version2PackageResolvedFileBody(apolloVersion: Constants.CLIVersion),
      named: "Package.resolved",
      inDirectory: "MyProject.xcworkspace/xcshareddata/swiftpm"
    )

    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: fileManager.directoryURL
    )

    // then
    expect(result).to(equal(.versionMatch))
  }

  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInXcodeWorkspace_withVersion2FileFormat_hasNonMatchingVersion_returns_versionMismatch() throws {
    // given
    let apolloVersion = "1.0.0.test-1"
    try fileManager.createFile(
      body: version2PackageResolvedFileBody(apolloVersion: apolloVersion),
      named: "Package.resolved",
      inDirectory: "MyProject.xcworkspace/xcshareddata/swiftpm"
    )

    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: fileManager.directoryURL
    )

    // then
    expect(result).to(equal(.versionMismatch(cliVersion: Constants.CLIVersion, apolloVersion: apolloVersion)))
  }

  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInXcodeProject_withVersion2FileFormat_hasMatchingVersion_returns_versionMatch() throws {
    // given
    try fileManager.createFile(
      body: version2PackageResolvedFileBody(apolloVersion: Constants.CLIVersion),
      named: "Package.resolved",
      inDirectory: "MyProject.xcodeproj/project.xcworkspace/xcshareddata/swiftpm"
    )

    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: fileManager.directoryURL
    )

    // then
    expect(result).to(equal(.versionMatch))
  }

  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInXcodeProject_withVersion2FileFormat_hasNonMatchingVersion_returns_versionMismatch() throws {
    // given
    let apolloVersion = "1.0.0.test-1"
    try fileManager.createFile(
      body: version2PackageResolvedFileBody(apolloVersion: apolloVersion),
      named: "Package.resolved",
      inDirectory: "MyProject.xcodeproj/project.xcworkspace/xcshareddata/swiftpm"
    )

    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: fileManager.directoryURL
    )

    // then
    expect(result).to(equal(.versionMismatch(cliVersion: Constants.CLIVersion, apolloVersion: apolloVersion)))
  }
  
  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInXcodeWorkspaceAndProject_withVersion2FileFormat_hasMatchingVersion_returns_versionMatch_fromWorkspace() throws {
    // given
    try fileManager.createFile(
      body: version2PackageResolvedFileBody(apolloVersion: Constants.CLIVersion),
      named: "Package.resolved",
      inDirectory: "MyProject.xcworkspace/xcshareddata/swiftpm"
    )
    
    let apolloProjectVersion = "1.0.0.test-1"
    try fileManager.createFile(
      body: version2PackageResolvedFileBody(apolloVersion: apolloProjectVersion),
      named: "Package.resolved",
      inDirectory: "MyProject.xcodeproj/project.xcworkspace/xcshareddata/swiftpm"
    )

    // when
    let result = try VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: fileManager.directoryURL
    )

    // then
    expect(result).to(equal(.versionMatch))
  }

}

// MARK: - Helpers

fileprivate let ApolloLibraryVersion: String = {
  let codegenInfoDict = Bundle(for: ApolloClient.self).infoDictionary
  return codegenInfoDict?["CFBundleVersion"] as! String
}()

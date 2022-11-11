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

  private func packageResolvedFileBody(withApolloVersion version: String) -> String {
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

  // MARK: - Tests

  func test__matchCLIVersionToApolloVersion__givenNoPackageResolvedFileInProject_returnsNoApolloVersionFound() {
    // when
    let result = VersionChecker.matchCLIVersionToApolloVersion(
      projectRootURL: fileManager.directoryURL
    )

    // then
    expect(result).to(equal(.noApolloVersionFound))
  }

  func test__matchCLIVersionToApolloVersion__givenPackageResolvedFileInProjectRoot_hasMatchingVersion_returns_versionMatch() throws {
    // given
    try fileManager.createFile(
      body: packageResolvedFileBody(withApolloVersion: ApolloLibraryVersion),
      named: "Package.resolved"
    )

    // when
    let result = VersionChecker.matchCLIVersionToApolloVersion(
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

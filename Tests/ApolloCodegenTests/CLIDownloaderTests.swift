@testable import ApolloCodegenLib
import ApolloCodegenTestSupport
import XCTest

class CLIDownloaderTests: XCTestCase {
  func testForceRedownloading_withExistingFile_shouldOverwriteWithExpectedChecksum() throws {
    let scriptsURL = CodegenTestHelper.cliFolderURL()
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: scriptsURL)

    try "Dummy file".data(using: .utf8)?.write(to: zipFileURL)
    XCTAssertTrue(FileManager.default.apollo.doesFileExist(atPath: zipFileURL.path), "Created dummy file to be overwritten")

    try CLIDownloader.forceRedownload(to: scriptsURL, timeout: CodegenTestHelper.timeout)
    XCTAssertTrue(FileManager.default.apollo.doesFileExist(atPath: zipFileURL.path), "Downloaded Apollo CLI")
    XCTAssertEqual(try FileManager.default.apollo.shasum(at: zipFileURL), CLIExtractor.expectedSHASUM)
  }
  
  func testDownloading_toFolderThatDoesNotExist_shouldCreateFolder() throws {
    let scriptsURL = CodegenTestHelper.cliFolderURL()
    try FileManager.default.apollo.delete(atPath: scriptsURL.path)
    XCTAssertFalse(FileManager.default.apollo.doesDirectoryExist(atPath: scriptsURL.path))

    try CLIDownloader.downloadIfNeeded(to: scriptsURL, timeout: 90.0)
    XCTAssertTrue(FileManager.default.apollo.doesDirectoryExist(atPath: scriptsURL.path))
  }
  
  func testTimeout_shouldThrowCorrectError() throws {
    let scriptsURL = CodegenTestHelper.cliFolderURL()
    
    do {
      try CLIDownloader.forceRedownload(to: scriptsURL, timeout: 0.5)
    } catch {
      guard
        let DownloadError = error as? URLDownloader.DownloadError,
        case .downloadTimedOut(let seconds) = DownloadError
      else {
        XCTFail("Wrong type of error")
        return
      }

      XCTAssertEqual(seconds, 0.5, accuracy: 0.0001)
    }
  }
}


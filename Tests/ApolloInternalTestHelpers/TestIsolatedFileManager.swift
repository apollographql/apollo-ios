import Foundation
import XCTest

/// A test helper object that manages creation and deletion of files in a temporary directory
/// that ensures test isolation.
///
/// All files and directories created by this class will be automatically deleted upon test
/// completion prior to the test case's `tearDown()` function being called.
///
/// You can create a file manager from within a specific unit test with the
/// `testIsolatedFileManager()` function on `XCTestCase`.
public class TestIsolatedFileManager {

  public let directoryURL: URL
  public let fileManager: FileManager

  /// The paths for the files written to by the ``ApolloFileManager``.
  public private(set) var writtenFiles: Set<String> = []

  fileprivate init(directoryURL: URL, fileManager: FileManager) throws {
    self.directoryURL = directoryURL
    self.fileManager = fileManager

    try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
  }

  func cleanUp() throws {
    try fileManager.removeItem(at: directoryURL)
  }

  /// Creates a file in the test directory.
  ///
  /// - Parameters:
  ///   - data: File content
  ///   - filename: Target name of the file. This should not include any path information
  ///
  /// - Returns:
  ///    - The full path of the created file.
  @discardableResult
  public func createFile(
    containing data: Data,
    named fileName: String,
    inDirectory subDirectory: String? = nil
  ) throws -> String {
    let fileDirectoryURL: URL
    if let subDirectory {
      fileDirectoryURL = directoryURL.appendingPathComponent(subDirectory, isDirectory: true)
      try fileManager.createDirectory(at: fileDirectoryURL, withIntermediateDirectories: true)
    } else {
      fileDirectoryURL = directoryURL
    }

    let filePath: String = fileDirectoryURL
      .appendingPathComponent(fileName, isDirectory: false).path

    guard fileManager.createFile(atPath: filePath, contents: data) else {
      throw Error.cannotCreateFile(at: filePath)
    }

    writtenFiles.insert(filePath)
    return filePath
  }

  @discardableResult
  public func createFile(
    body: @autoclosure () -> String,
    named fileName: String,
    inDirectory directory: String? = nil
  ) throws -> String {
    let bodyString = body()
    guard let data = bodyString.data(using: .utf8) else {
      throw Error.cannotEncodeFileData(from: bodyString)
    }

    return try createFile(
      containing: data,
      named: fileName,
      inDirectory: directory
    )
  }

  public enum Error: Swift.Error {
    case cannotCreateFile(at: String)
    case cannotEncodeFileData(from: String)

    public var errorDescription: String {
      switch self {
      case .cannotCreateFile(let path):
        return "Cannot create file at \(path)"
      case .cannotEncodeFileData(let body):
        return "Cannot encode provided body string into UTF-8 data. Body:\n\(body)"
      }
    }
  }

}

public extension XCTestCase {

  func testIsolatedFileManager(
    with fileManager: FileManager = .default
  ) throws -> TestIsolatedFileManager {
    let manager = try TestIsolatedFileManager(
      directoryURL: computeTestTempDirectoryURL(),
      fileManager: fileManager
    )

    addTeardownBlock {
      try manager.cleanUp()
    }

    return manager
  }

  private func computeTestTempDirectoryURL() -> URL {
    let directoryURL: URL
    if #available(macOS 13.0, *) {
      directoryURL = URL(filePath: NSTemporaryDirectory(), directoryHint: .isDirectory)
    } else {
      directoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }

    return directoryURL
      .appendingPathComponent("ApolloTests")
      .appendingPathComponent(name
        .trimmingCharacters(in: CharacterSet(charactersIn: "-[]"))
        .replacingOccurrences(of: " ", with: "_")        
      )
  }
}

import Foundation
import CommonCrypto
#if !COCOAPODS
import ApolloUtils
#endif

public typealias FileAttributes = [FileAttributeKey : Any]

/// Enables the `.apollo` extension namespace.
extension FileManager: ApolloCompatible {}

extension ApolloExtension where Base: FileManager {

  public enum PathError: Swift.Error, LocalizedError, Equatable {
    case notAFile(path: String)
    case notADirectory(path: String)
    case cannotCreateFile(at: String)

    public var errorDescription: String {
      switch self {
      case .notAFile(let path):
        return "\(path) is not a file!"
      case .notADirectory(let path):
        return "\(path) is not a directory!"
      case .cannotCreateFile(let path):
        return "Cannot create file at \(path)"
      }
    }
  }

  // MARK: Presence

  /// Checks if the path exists and is a file, not a directory.
  ///
  /// - Parameter path: The path to check.
  /// - Returns: `true` if there is something at the path and it is a file, not a directory.
  public func doesFileExist(atPath path: String) -> Bool {
    var isDirectory = ObjCBool(false)
    let exists = base.fileExists(atPath: path, isDirectory: &isDirectory)

    return exists && !isDirectory.boolValue
  }

  /// Checks if the path exists and is a directory, not a file.
  ///
  /// - Parameter path: The path to check.
  /// - Returns: `true` if there is something at the path and it is a directory, not a file.
  public func doesDirectoryExist(atPath path: String) -> Bool {
    var isDirectory = ObjCBool(false)
    let exists = base.fileExists(atPath: path, isDirectory: &isDirectory)

    return exists && isDirectory.boolValue
  }
  
  // MARK: Manipulation

  /// Verifies that a file exists at the path and then attempts to delete it. An error is thrown if the path is for a directory.
  ///
  /// - Parameter path: The path of the file to delete.
  public func deleteFile(atPath path: String) throws {
    var isDirectory = ObjCBool(false)
    let exists = base.fileExists(atPath: path, isDirectory: &isDirectory)

    if exists && isDirectory.boolValue {
      throw PathError.notAFile(path: path)
    }

    guard exists else { return }
    try base.removeItem(atPath: path)
  }

  /// Verifies that a directory exists at the path and then attempts to delete it. An error is thrown if the path is for a file.
  ///
  /// - Parameter path: The path of the directory to delete.
  public func deleteDirectory(atPath path: String) throws {
    var isDirectory = ObjCBool(false)
    let exists = base.fileExists(atPath: path, isDirectory: &isDirectory)

    if exists && !isDirectory.boolValue {
      throw PathError.notADirectory(path: path)
    }

    guard exists else { return }
    try base.removeItem(atPath: path)
  }

  /// Creates a file at the specified path and writes any given data to it. If a file already exists at `path`, this method overwrites the
  /// contents of that file if the current process has the appropriate privileges to do so.
  ///
  /// - Parameters:
  ///   - path: Path to the file.
  ///   - data: [optional] Data to write to the file path.
  ///   - overwrite: `true` will overwrite the contents of the file at `path`. `false` will not.
  public func createFile(atPath path: String, data: Data? = nil, overwrite: Bool? = nil) throws {
    try createContainingDirectoryIfNeeded(forPath: path)

    if let overwrite = overwrite, !overwrite && doesFileExist(atPath: path) { return }

    guard base.createFile(atPath: path, contents: data, attributes: nil) else {
      throw PathError.cannotCreateFile(at: path)
    }
  }

  /// Creates the containing directory (including all intermediate directories) for the given file URL if necessary. This method will not
  /// overwrite any existing directory.
  ///
  /// - Parameter fileURL: The URL of the file to create a containing directory for if necessary.
  public func createContainingDirectoryIfNeeded(forPath path: String) throws {
    let parent = URL(fileURLWithPath: path).deletingLastPathComponent()
    try createDirectoryIfNeeded(atPath: parent.path)
  }

  /// Creates the directory (including all intermediate directories) for the given URL if necessary. This method will not overwrite any
  /// existing directory.
  ///
  /// - Parameter path: The path of the directory to create if necessary.
  public func createDirectoryIfNeeded(atPath path: String) throws {
    if doesDirectoryExist(atPath: path) { return }
    try base.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
  }
}

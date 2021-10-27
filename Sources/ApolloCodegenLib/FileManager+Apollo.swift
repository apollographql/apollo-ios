import Foundation
import CommonCrypto
#if !COCOAPODS
import ApolloUtils
#endif

/// A protocol to decouple `ApolloExtension` from `FileManager`. Use it to build objects that can support
/// `ApolloExtension` behavior.
public protocol FileManagerProvider {
  func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool
  func removeItem(atPath path: String) throws
  @discardableResult func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool
  func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
}

/// Enables the `.apollo` etension namespace.
extension FileManager: ApolloCompatible {}

/// `FileManager` conforms to the `FileManagerProvider` protocol. If it's method signatures change both the protocol and
/// extension will need to be updated.
extension FileManager: FileManagerProvider {}

extension ApolloExtension where Base: FileManagerProvider {

  public enum PathError: Swift.Error, LocalizedError, Equatable {
    case notAFile(path: String)
    case notADirectory(path: String)

    public var errorDescription: String {
      switch self {
      case .notAFile(let path):
        return "\(path) is not a file!"
      case .notADirectory(let path):
        return "\(path) is not a directory!"
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

  /// Verifies that a file exists at the pathRemoves the file at the specified path.
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

  /// Removes the directory at the specified path.
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
  public func createFile(atPath path: String, data: Data? = nil) throws -> Bool {
    try createContainingDirectory(forPath: path)
    return base.createFile(atPath: path, contents: data, attributes: nil)
  }

  /// Creates the containing directory (including all intermediate directories) for the given file URL if necessary.
  ///
  /// - Parameter fileURL: The URL of the file to create a containing directory for if necessary.
  public func createContainingDirectory(forPath path: String) throws {
    let parent = URL(fileURLWithPath: path).deletingLastPathComponent()
    try base.createDirectory(atPath: parent.path, withIntermediateDirectories: true, attributes: nil)
  }

  /// Creates the directory (including all intermediate directories) for the given URL if necessary.
  ///
  /// - Parameter path: The path of the directory to create if necessary.
  public func createDirectory(atPath path: String) throws {
    try base.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
  }

  // MARK: Content

  /// Calculates the SHASUM (ie, SHA256 hash) of the given file
  ///
  /// - Parameter fileURL: The file to calculate the SHASUM for.
  public func shasum(at fileURL: URL) throws -> String {
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

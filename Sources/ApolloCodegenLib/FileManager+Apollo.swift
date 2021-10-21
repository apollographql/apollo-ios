import Foundation
import CommonCrypto
#if !COCOAPODS
import ApolloUtils
#endif

extension FileManager: ApolloCompatible {}

extension ApolloExtension where Base == FileManager {

  // MARK: Presence

  /// Checks if a file exists (and is not a directory) at the given path
  ///
  /// - Parameter path: The path to check
  /// - Returns: `true` if there is something at the path and it is a file, not a directory.
  public func fileExists(at path: String) -> Bool {
    var isDirectory = ObjCBool(false)
    let exists = base.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && !isDirectory.boolValue
  }
  
  /// Checks if a file exists (and is not a directory) at the given URL
  ///
  /// - Parameter url: The URL to check
  /// - Returns: `true` if there is something at the URL and it is a file, not a directory.
  public func fileExists(at url: URL) -> Bool {
    return fileExists(at: url.path)
  }
  
  /// Checks if a directory exists (and is not a file) at the given path.
  ///
  /// - Parameter path: The path to check
  /// - Returns: `true` if there is something at the path and it is a directory, not a file.
  public func directoryExists(at path: String) -> Bool {
    var isDirectory = ObjCBool(false)
    let exists = base.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && isDirectory.boolValue
  }
  
  /// Checks if a directory exists (and is not a file) at the given URL.
  ///
  /// - Parameter url: The URL to check
  /// - Returns: `true` if there is something at the URL and it is a directory, not a file.
  public func directoryExists(at url: URL) -> Bool {
    return directoryExists(at: url.path)
  }

  // MARK: Manipulation

  /// Removes the file or directory at the specified path.
  ///
  /// - Parameter path: The path of the file or directory to delete.
  public func delete(at path: String) throws {
    try base.removeItem(atPath: path)
  }

  /// Removes the file or directory at the specified URL.
  ///
  /// - Parameter path: The URL of the file or directory to delete.
  public func delete(at url: URL) throws {
    try base.removeItem(at: url)
  }

  /// Creates a file at the specified path and writes any given data to it. If a file already exists at `path`, this method overwrites the
  /// contents of that file if the current process has the appropriate privileges to do so.
  ///
  /// - Parameters:
  ///   - path: Path to the new file.
  ///   - data: [optional] Data to write to the new file.
  public func createFile(at path: String, data: Data? = nil) throws {
    try createContainingDirectoryIfNeeded(for: .init(fileURLWithPath: path))

    base.createFile(atPath: path, contents: data, attributes: nil)
  }

  /// Creates a file at the specified URL and writes any given data to it. If a file already exists at `url`, this method overwrites the
  /// contents of that file if the current process has the appropriate privileges to do so.
  ///
  /// - Parameters:
  ///   - url: URL to the ne file.
  ///   - data: [optional] Data to write to the new file.
  public func createFile(at url: URL, data: Data? = nil) throws {
    try createFile(at: url.path, data: data)
  }
  
  /// Creates the containing directory (including all intermediate directories) for the given file URL if necessary.
  ///
  /// - Parameter fileURL: The URL of the file to create a containing directory for if necessary.
  public func createContainingDirectoryIfNeeded(for fileURL: URL) throws {
    let parent = fileURL.deletingLastPathComponent()
    try createDirectoryIfNeeded(at: parent)
  }
  
  /// Creates the directory (including all intermediate directories) for the given URL if necessary.
  ///
  /// - Parameter url: The URL of the directory to create if necessary.
  public func createDirectoryIfNeeded(at url: URL) throws {
    try createDirectoryIfNeeded(at: url.path)
  }

  /// Creates the directory (including all intermediate directories) for the given URL if necessary.
  ///
  /// - Parameter path: The path of the directory to create if necessary.
  public func createDirectoryIfNeeded(at path: String) throws {
    guard !directoryExists(at: path) else {
      // Directory already exists, nothing more to do here.
      return
    }
    try base.createDirectory(atPath: path, withIntermediateDirectories: true)
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

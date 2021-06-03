import Foundation
import CommonCrypto
#if !COCOAPODS
import ApolloUtils
#endif

extension FileManager: ApolloCompatible {}

extension ApolloExtension where Base == FileManager {
  
  /// Checks if a file exists (and is not a folder) at the given path
  ///
  /// - Parameter path: The path to check
  /// - Returns: `true` if there is something at the path and it is a file, not a folder.
  public func fileExists(at path: String) -> Bool {
    var isFolder = ObjCBool(false)
    let exists = base.fileExists(atPath: path, isDirectory: &isFolder)
    return exists && !isFolder.boolValue
  }
  
  /// Checks if a file exists (and is not a folder) at the given URL
  ///
  /// - Parameter url: The URL to check
  /// - Returns: `true` if there is something at the URL and it is a file, not a folder.
  public func fileExists(at url: URL) -> Bool {
    return fileExists(at: url.path)
  }
  
  /// Checks if a folder exists (and is not a file) at the given path.
  ///
  /// - Parameter path: The path to check
  /// - Returns: `true` if there is something at the path and it is a folder, not a file.
  public func folderExists(at path: String) -> Bool {
    var isFolder = ObjCBool(false)
    let exists = base.fileExists(atPath: path, isDirectory: &isFolder)
    return exists && isFolder.boolValue
  }
  
  /// Checks if a folder exists (and is not a file) at the given URL.
  ///
  /// - Parameter url: The URL to check
  /// - Returns: `true` if there is something at the URL and it is a folder, not a file.
  public func folderExists(at url: URL) -> Bool {
    return folderExists(at: url.path)
  }
  
  /// Checks if a folder exists then attempts to delete it if it's there.
  ///
  /// - Parameter url: The URL to delete the folder for
  public func deleteFolder(at url: URL) throws {
    guard folderExists(at: url) else {
      // Nothing to delete!
      return
    }
    try base.removeItem(at: url)
  }
  
  /// Checks if a file exists then attempts to delete it if it's there.
  ///
  /// - Parameter url: The URL to delete the file for
  public func deleteFile(at url: URL) throws {
    guard fileExists(at: url) else {
      // Nothing to delete!
      return
    }
    try base.removeItem(at: url)
  }
  
  /// Creates the containing folder (including all intermediate directories) for the given file URL if necessary.
  ///
  /// - Parameter fileURL: The URL of the file to create a containing folder for if necessary.
  public func createContainingFolderIfNeeded(for fileURL: URL) throws {
    let parent = fileURL.deletingLastPathComponent()
    try createFolderIfNeeded(at: parent)
  }
  
  /// Creates the folder (including all intermediate directories) for the given URL if necessary.
  ///
  /// - Parameter url: The URL of the folder to create if necessary.
  public func createFolderIfNeeded(at url: URL) throws {
    guard !folderExists(at: url) else {
      // Folder already exists, nothing more to do here.
      return
    }
    try base.createDirectory(atPath: url.path, withIntermediateDirectories: true)
  }
  
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

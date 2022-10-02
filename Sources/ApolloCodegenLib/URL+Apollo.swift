import Foundation

public enum ApolloURLError: Error, LocalizedError {
  case fileNameIsEmpty
  
  public var errorDescription: String? {
    switch self {
    case .fileNameIsEmpty:
      return "The file name for this file URL was empty. Please pass a non-empty string."
    }
  }
}

extension URL {
  
  /// Determines if the URL passed in is a directory URL.
  ///
  /// NOTE: Only works if something at the URL already exists.
  ///
  /// - Returns: True if the URL is a directory URL, false if it isn't.
  var isDirectoryURL: Bool {
    guard
      let resourceValues = try? resourceValues(forKeys: [.isDirectoryKey]),
      let isDirectory = resourceValues.isDirectory else {
        return false
    }
    
    return isDirectory
  }
  
  var isSwiftFileURL: Bool {
    pathExtension == "swift"
  }
  
  /// - Returns: the URL to the parent folder of the current URL.
  public func parentFolderURL() -> URL {
    deletingLastPathComponent()
  }
  
  /// - Parameter folderName: The name of the child folder to append to the current URL
  /// - Returns: The full URL including the appended child folder.
  public func childFolderURL(folderName: String) -> URL {
    appendingPathComponent(folderName, isDirectory: true)
  }

  /// Adds the filename to the caller to get the full URL of a file
  ///
  /// - Parameters:
  ///   - fileName: The name of the child file, with an extension, for example `"API.swift"`. Note: For hidden files just pass `".filename"`.
  /// - Returns: The full URL including the full file.
  public func childFileURL(fileName: String) throws -> URL {
    guard !fileName.isEmpty else {
      throw ApolloURLError.fileNameIsEmpty
    }
    
    return appendingPathComponent(fileName, isDirectory: false)
  }
}

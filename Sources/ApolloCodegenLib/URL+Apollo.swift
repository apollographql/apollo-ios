import Foundation
import ApolloCore

extension URL: ApolloCompatible {}

public enum ApolloURLError: Error, LocalizedError {
  case fileNameIsEmpty
  
  public var errorDescription: String? {
    switch self {
    case .fileNameIsEmpty:
      return "The file name for this file URL was empty. Please pass a non-empty string."
    }
  }
}

extension ApolloExtension where Base == URL {
  
  /// - Returns: the URL to the parent folder of the current URL.
  public func parentFolderURL() -> URL {
    base.deletingLastPathComponent()
  }
  
  /// - Parameter folderName: The name of the child folder to append to the current URL
  /// - Returns: The full URL including the appended child folder.
  public func childFolderURL(folderName: String) -> URL {
    base.appendingPathComponent(folderName, isDirectory: true)
  }

  /// Adds the filename to the caller to get the full URL of a file
  ///
  /// - Parameters:
  ///   - fileName: The name of the child file, with an extension, for example `"API.swift"`. Note: For hidden files just pass `".filename"`.
  /// - Returns: The full URL including the full file.
  public func childFileURL(fileName: String) throws -> URL {
    guard fileName.apollo.isNotEmpty else {
      throw ApolloURLError.fileNameIsEmpty
    }
    
    return base
      .appendingPathComponent(fileName, isDirectory: false)
  }
}

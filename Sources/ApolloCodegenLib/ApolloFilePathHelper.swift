import Foundation

/// Readability helpers for accessing frequent folders.
struct ApolloFilePathHelper {
  
  /// The URL to the `apollo` folder within the CLI
  ///
  /// - Parameter cliFolderURL: The URL to the CLI folder.
  static func apolloFolderURL(fromCLIFolder cliFolderURL: URL) -> URL {
    return cliFolderURL.appendingPathComponent("apollo")
  }
  
  /// The URL to the zip folder within the CLI folder
  ///
  /// - Parameter cliFolderURL: The URL to the CLI folder
  static func zipFileURL(fromCLIFolder cliFolderURL: URL) -> URL {
    return cliFolderURL.appendingPathComponent("apollo.tar.gz")
  }
  
  /// The URL to the binary folder within the CLI
  ///
  /// - Parameter apolloFolderURL: The URL to the `apollo` folder within the CLI
  static func binaryFolderURL(fromApollo apolloFolderURL: URL) -> URL {
    return apolloFolderURL.appendingPathComponent("bin")
  }
  
  /// The URL to the binary executable within the CLI
  ///
  /// - Parameter binaryFolderURL: The url to the binary folder within the CLI
  static func binaryURL(fromBinaryFolder binaryFolderURL: URL) -> URL {
    return binaryFolderURL.appendingPathComponent("run")
  }
  
  /// The URL to the cached SHASUM file for the current zip file of the CLI
  ///
  /// - Parameter apolloFolderURL: The URL to the Apollo folder within the CLI
  static func shasumFileURL(fromApollo apolloFolderURL: URL) -> URL {
    return apolloFolderURL.appendingPathComponent(".shasum")
  }
}

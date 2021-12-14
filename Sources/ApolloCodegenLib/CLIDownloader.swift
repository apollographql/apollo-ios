import Foundation

// Only available on macOS
#if os(macOS)

/// Helper for downloading the CLI Zip file so we don't have to include it in the repo.
struct CLIDownloader {
  /// The URL string for getting the current version of the CLI
  static let downloadURLString = "https://install.apollographql.com/legacy-cli/darwin/2.33.9"
  
  /// Downloads the appropriate Apollo CLI in a zip file.
  ///
  /// - Parameters:
  ///   - cliFolderURL: The folder URL to download the zip file to.
  ///   - timeout: The maximum time to wait before indicating that the download timed out, in seconds.
  static func downloadIfNeeded(to cliFolderURL: URL, timeout: Double) throws {
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: cliFolderURL)

    guard !FileManager.default.apollo.fileExists(at: zipFileURL) else {
      CodegenLogger.log("Zip file with the CLI is already downloaded!")
      return
    }
    
    try self.download(to: zipFileURL, timeout: timeout)
  }
  
  /// Deletes any existing version of the zip file and re-downloads a new version.
  ///
  /// - Parameters:
  ///   - cliFolderURL: The folder where the zip file lives.
  ///   - timeout: The maximum time to wait before indicating that the download timed out, in seconds.
  static func forceRedownload(to cliFolderURL: URL, timeout: Double) throws {
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: cliFolderURL)
    try FileManager.default.apollo.deleteFile(at: zipFileURL)
    let apolloFolderURL = ApolloFilePathHelper.apolloFolderURL(fromCLIFolder: cliFolderURL)
    try FileManager.default.apollo.deleteFolder(at: apolloFolderURL)
    
    try self.download(to: zipFileURL, timeout: timeout)
  }
  
  /// Downloads the zip file of the Apollo CLI synchronously.
  ///
  /// - Parameters:
  ///   - zipFileURL: The URL where downloaded data should be saved.
  ///   - timeout: The maximum time to wait before indicating that the download timed out, in seconds.
  private static func download(to zipFileURL: URL, timeout: Double) throws {
    try FileManager.default.apollo.createContainingFolderIfNeeded(for: zipFileURL)

    CodegenLogger.log("Downloading zip file with the CLI...")

    let urlRequest = URLRequest(url: URL(string: CLIDownloader.downloadURLString)!)
    try URLDownloader().downloadSynchronously(with: urlRequest,
                                              to: zipFileURL,
                                              timeout: timeout)

    CodegenLogger.log("CLI zip file successfully downloaded!")
  }
}

#endif

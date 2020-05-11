import Foundation

// Only available on macOS
#if os(macOS)

/// Helper for downloading the CLI Zip file so we don't have to include it in the repo.
struct CLIDownloader {
  
  enum CLIDownloaderError: Error, LocalizedError {
    case badResponse(code: Int, response: String?)
    case emptyDataReceived
    case noDataReceived
    case downloadTimedOut(after: Double)
    case responseNotHTTPResponse
    
    var errorDescription: String? {
      switch self {
      case .badResponse(let code, let response):
        return "Recieved bad response from server (code \(code)): \(String(describing: response))"
      case .emptyDataReceived:
        return "Empty data was receieved from the server."
      case .noDataReceived:
        return "No data was received from the server."
      case .downloadTimedOut(let seconds):
        return "Download timed out after \(seconds) seconds."
      case .responseNotHTTPResponse:
        return "The response was not an HTTP Response, something's gone very wonky."
      }
    }
  }
  
  /// The URL string for getting the current version of the CLI
  static let downloadURLString = "https://install.apollographql.com/legacy-cli/darwin/2.27.2"
  
  /// Downloads the appropriate Apollo CLI in a zip file.
  ///
  /// - Parameters:
  ///   - cliFolderURL: The folder URL to download the zip file to.
  ///   - timeout: The maximum time to wait before indicating that the download timed out, in seconds.
  static func downloadIfNeeded(cliFolderURL: URL, timeout: Double) throws {
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: cliFolderURL)
    guard !FileManager.default.apollo_fileExists(at: zipFileURL) else {
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
  static func forceRedownload(cliFolderURL: URL, timeout: Double) throws {
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: cliFolderURL)
    try FileManager.default.apollo_deleteFile(at: zipFileURL)
    let apolloFolderURL = ApolloFilePathHelper.apolloFolderURL(fromCLIFolder: cliFolderURL)
    try FileManager.default.apollo_deleteFolder(at: apolloFolderURL)
    
    try self.download(to: zipFileURL, timeout: timeout)
  }
  
  /// Downloads the zip file of the Apollo CLI synchronously.
  ///
  /// - Parameters:
  ///   - zipFileURL: The URL where downloaded data should be saved.
  ///   - timeout: The maximum time to wait before indicating that the download timed out, in seconds.
  private static func download(to zipFileURL: URL, timeout: Double) throws {
    try FileManager.default.apollo_createContainingFolderIfNeeded(for: zipFileURL)
    
    CodegenLogger.log("Downloading zip file with the CLI...")
    let semaphore = DispatchSemaphore(value: 0)
    var errorToThrow: Error? = CLIDownloaderError.downloadTimedOut(after: timeout)
    URLSession.shared.dataTask(with: URL(string: CLIDownloader.downloadURLString)!) { data, response, error in
      defer {
        semaphore.signal()
      }
      if let error = error {
        errorToThrow = error
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        errorToThrow = CLIDownloaderError.responseNotHTTPResponse
        return
      }
      
      guard httpResponse.statusCode == 200 else {
        let dataAsString = String(bytes: data ?? Data(), encoding: .utf8)
        errorToThrow = CLIDownloaderError.badResponse(code: httpResponse.statusCode, response: dataAsString)
        return
      }
      
      guard let data = data else {
        errorToThrow = CLIDownloaderError.noDataReceived
        return
      }
      
      guard !data.isEmpty else {
        errorToThrow = CLIDownloaderError.emptyDataReceived
        return
      }
      
      do {
        try data.write(to: zipFileURL)
      } catch {
        errorToThrow = error
        return
      }
      
      // If we got here, it all worked and it's good to go!
      errorToThrow = nil
    }.resume()
    
    _ = semaphore.wait(timeout: .now() + timeout)
    
    if let throwMe = errorToThrow {
      throw throwMe
    } else {
      CodegenLogger.log("CLI zip file successfully downloaded!")
    }
  }
}

#endif

import Foundation

// Only available on macOS
#if os(macOS)

/// Wrapper for calling the bundled node-based Apollo CLI.
public struct ApolloCLI {

  enum ApolloCLIError: Error {
    case lockInitializationFailed(URL)
    case timedOutWaitingOnLock(URL)
  }
  
  /// Creates an instance of `ApolloCLI`, downloading and extracting if needed
  ///
  /// - Parameters:
  ///   - cliFolderURL: The URL to the folder which contains the zip file with the CLI.
  ///   - timeout: The maximum time to wait before indicating that the download timed out, in seconds.
  public static func createCLI(cliFolderURL: URL, timeout: Double) throws -> ApolloCLI {
    let lock = try waitForCLIFolderLock(cliFolderURL: cliFolderURL, timeout: timeout)
    defer { lock.unlock() }

    try CLIDownloader.downloadIfNeeded(cliFolderURL: cliFolderURL, timeout: timeout)
    
    if !(try CLIExtractor.validateSHASUMOfDownloadedFile(in: cliFolderURL)) {
      CodegenLogger.log("Downloaded zip file has incorrect SHASUM, forcing redownload")
      try CLIDownloader.forceRedownload(cliFolderURL: cliFolderURL, timeout: timeout)
    }
    
    let binaryFolderURL = try CLIExtractor.extractCLIIfNeeded(from: cliFolderURL)
    return ApolloCLI(binaryFolderURL: binaryFolderURL)
  }

  private static func waitForCLIFolderLock(cliFolderURL: URL, timeout: Double) throws -> NSDistributedLock {
    guard let lock = NSDistributedLock(path: cliFolderURL.path + ".lock") else {
      throw ApolloCLIError.lockInitializationFailed(cliFolderURL)
    }

    let maxPollCount = Int(timeout*2)
    var pollCount = 0

    repeat {
      if lock.try() {
        return lock

      } else {
        pollCount += 1

        if pollCount <= maxPollCount {
          usleep(500_000) // sleep 0.5 seconds
        } else {
          throw ApolloCLIError.timedOutWaitingOnLock(cliFolderURL)
        }
      }
    } while pollCount <= maxPollCount

    return lock
  }

  public let binaryFolderURL: URL
  
  /// Designated initializer
  ///
  /// - Parameter binaryFolderURL: The folder where the extracted binary files live.
  public init(binaryFolderURL: URL) {
    self.binaryFolderURL = binaryFolderURL
  }
  
  var scriptPath: String {
    return self.binaryFolderURL.path + "/run"
  }
  
  /// Runs a command with the bundled Apollo CLI
  ///
  /// NOTE: Will always run the `--version` command first for debugging purposes.
  /// - Parameter arguments: The arguments to hand to the CLI
  /// - Parameter folder: The folder to run the command from.
  public func runApollo(with arguments: [String],
                        from folder: URL? = nil) throws -> String {
    // Add the binary folder URL to $PATH so the script can find pre-compiled `node`
    let command = "export PATH=$PATH:'\(self.binaryFolderURL.path)'" +
      // Log out the version for debugging purposes
      " && '\(self.scriptPath)' --version" +
      // Set the final command to log out the passed-in arguments for debugging purposes
      " && set -x" +
      // Actually run the script with the given options.
      " && '\(self.scriptPath)' \(arguments.joined(separator: " "))"
    
    return try Basher.run(command: command, from: folder)
  }
}

#endif

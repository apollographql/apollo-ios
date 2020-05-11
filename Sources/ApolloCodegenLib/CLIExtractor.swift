import Foundation

// Only available on macOS
#if os(macOS)

/// Helper for extracting and validating the node-based Apollo CLI from a zip.
struct CLIExtractor {
  
  // MARK: - Extracting the binary
  
  enum CLIExtractorError: Error, LocalizedError {
    case noBinaryFolderAfterUnzipping(atURL: URL)
    case zipFileHasInvalidSHASUM(expectedSHASUM: String, gotSHASUM: String)
    case zipFileNotPresent(atURL: URL)
    
    var errorDescription: String? {
      switch self {
      case .noBinaryFolderAfterUnzipping(let url):
        return "Some kind of error occurred with unzipping and the binary folder could not be found at \(url)"
      case .zipFileHasInvalidSHASUM(let expectedSHASUM, let gotSHASUM):
        return "Error: The SHASUM of this zip file (\(gotSHASUM)) does not match the official released version from Apollo (\(expectedSHASUM))! This may present security issues. Terminating code generation."
      case .zipFileNotPresent(let url):
        return "Could not locate file to unzip at \(url). Please make sure you're passing in the correct URL for the scripts folder!"
      }
    }
  }
  
  static let expectedSHASUM = "08c45258b7cc1d4e6e28288930428922fd7dee9ccaad6e5be17dd5b79e6b1af4"
  
  /// Checks to see if the CLI has already been extracted and is the correct version, and extracts or re-extracts as necessary
  ///
  /// - Parameter cliFolderURL: The URL to the folder which contains the zip file with the CLI.
  /// - Parameter expectedSHASUM: The expected SHASUM. Defaults to the real expected SHASUM. This parameter exists mostly for testing.
  /// - Returns: The URL to the binary folder of the extracted CLI.
  static func extractCLIIfNeeded(from cliFolderURL: URL, expectedSHASUM: String = CLIExtractor.expectedSHASUM) throws -> URL {
    let apolloFolderURL = ApolloFilePathHelper.apolloFolderURL(fromCLIFolder: cliFolderURL)
    
    guard FileManager.default.apollo_folderExists(at: apolloFolderURL) else {
      CodegenLogger.log("Apollo folder doesn't exist, extracting CLI from zip file.")
      return try self.extractCLIFromZip(cliFolderURL: cliFolderURL)
    }
    
    guard try self.validateSHASUMInExtractedFile(apolloFolderURL: apolloFolderURL, expected: expectedSHASUM) else {
      CodegenLogger.log("SHASUM of extracted zip does not match expected, deleting existing folder and re-extracting.")
      try FileManager.default.apollo_deleteFolder(at: apolloFolderURL)
      return try self.extractCLIFromZip(cliFolderURL: cliFolderURL)
    }
    
    let binaryFolderURL = ApolloFilePathHelper.binaryFolderURL(fromApollo: apolloFolderURL)
    let binaryURL = ApolloFilePathHelper.binaryURL(fromBinaryFolder: binaryFolderURL)
    guard FileManager.default.apollo_fileExists(at: binaryURL) else {
      CodegenLogger.log("There was a valid `.shasum` file, but no binary at the expected path. Deleting existing apollo folder and re-extracting.", logLevel: .warning)
      try FileManager.default.apollo_deleteFolder(at: apolloFolderURL)
      return try self.extractCLIFromZip(cliFolderURL: cliFolderURL, expectedSHASUM: expectedSHASUM)
    }
    
    CodegenLogger.log("Binary already extracted!")
    return binaryFolderURL
  }
  
  /// Checks the `.shasum` file which was written out the last time the CLI
  /// was extracted to see if it matches the current version
  /// - Parameter apolloFolderURL: The URL to the extracted apollo folder.
  /// - Parameter expected: The expected SHASUM. Defaults to the real expected SHASUM. This parameter exists mostly for testing.
  /// - Returns: true if the shasums match, false if not.
  static func validateSHASUMInExtractedFile(apolloFolderURL: URL, expected: String = CLIExtractor.expectedSHASUM) throws -> Bool {
    let shasumFileURL = ApolloFilePathHelper.shasumFileURL(fromApollo: apolloFolderURL)
    guard FileManager.default.apollo_fileExists(at: shasumFileURL) else {
      return false
    }
    
    let contents = try String(contentsOf: shasumFileURL, encoding: .utf8)
    
    guard contents == expected else {
      return contents.hasPrefix(expected)
    }
    
    return true
  }
  
  /// Writes the SHASUM of the extracted version of the CLI to a file for faster checks to ensure we have the correct version.
  ///
  /// - Parameter apolloFolderURL: The URL to the extracted apollo folder.
  static func writeSHASUMToFile(apolloFolderURL: URL) throws {
    let shasumFileURL = ApolloFilePathHelper.shasumFileURL(fromApollo: apolloFolderURL)
    try CLIExtractor.expectedSHASUM.write(to: shasumFileURL,
                                          atomically: false,
                                          encoding: .utf8)
  }
  
  /// Extracts the CLI from a zip file in the scripts folder.
  ///
  /// - Parameter cliFolderURL: The URL to the folder which contains the zip file with the CLI.
  /// - Parameter expectedSHASUM: The expected SHASUM. Defaults to the real expected SHASUM. This parameter exists mostly for testing.
  /// - Returns: The URL for the binary folder post-extraction.
  static func extractCLIFromZip(cliFolderURL: URL, expectedSHASUM: String = CLIExtractor.expectedSHASUM) throws -> URL {
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromCLIFolder: cliFolderURL)

    try self.validateZipFileSHASUM(at: zipFileURL, expected: expectedSHASUM)
    
    CodegenLogger.log("Extracting CLI from zip file. This may take a second...")
    _ = try Basher.run(command: "tar xzf '\(zipFileURL.path)' -C '\(cliFolderURL.path)'", from: nil)
    
    let apolloFolderURL = ApolloFilePathHelper.apolloFolderURL(fromCLIFolder: cliFolderURL)
    let binaryFolderURL = ApolloFilePathHelper.binaryFolderURL(fromApollo: apolloFolderURL)
    
    guard FileManager.default.apollo_folderExists(at: binaryFolderURL) else {
      throw CLIExtractorError.noBinaryFolderAfterUnzipping(atURL: binaryFolderURL)
    }
    
    try self.writeSHASUMToFile(apolloFolderURL: apolloFolderURL)
    
    return binaryFolderURL
  }
  
  /// Checks that the file at the given URL matches the expected SHASUM.
  ///
  /// - Parameter zipFileURL: The url to the zip file containing the Apollo CLI.
  /// - Parameter expected: The expected SHASUM. Defaults to the real expected SHASUM. This parameter exists mostly for testing.
  static func validateZipFileSHASUM(at zipFileURL: URL, expected: String = CLIExtractor.expectedSHASUM) throws {
    let shasum = try FileManager.default.apollo_shasum(at: zipFileURL)
    print("SHASUM: \(shasum)")
    guard shasum == expected else {
      throw CLIExtractorError.zipFileHasInvalidSHASUM(expectedSHASUM: expected, gotSHASUM: shasum)
    }
  }
}

#endif

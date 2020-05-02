import Foundation

// Only available on macOS
#if os(macOS)

/// A wrapper to facilitate downloading a schema with the Apollo node CLI
public struct ApolloSchemaDownloader {
  
  /// Runs code generation from the given folder with the passed-in options
  ///
  /// - Parameters:
  ///   - cliFolderURL: The folder where the Apollo CLI is/should be downloaded.
  ///   - options: The `ApolloSchemaOptions` object to use to download the schema.
  /// - Returns: Output from a successful run
  @discardableResult
  public static func run(with cliFolderURL: URL,
                         options: ApolloSchemaOptions) throws -> String {
    try FileManager.default.apollo.createContainingFolderIfNeeded(for: options.outputURL)
    let cli = try ApolloCLI.createCLI(cliFolderURL: cliFolderURL, timeout: options.downloadTimeout)
    return try cli.runApollo(with: options.arguments)
  }
}

#endif

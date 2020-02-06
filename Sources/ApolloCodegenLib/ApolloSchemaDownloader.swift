import Foundation

/// A wrapper to facilitate downloading a schema with the Apollo node CLI
public struct ApolloSchemaDownloader {
  
  public enum SchemaDownloadError: Error, LocalizedError {
    case folderDoesNotExist(_ url: URL)
    
    public var localizedDescription: String {
      switch self {
      case .folderDoesNotExist(let url):
        return "Can't download schema from \(url) - there is no folder there!"
      }
    }
  }
  
  /// Runs code generation from the given folder with the passed-in options
  ///
  /// - Parameters:
  ///   - folder: The folder to run the script from
  ///   - cliFolderURL: The folder where the Apollo CLI is/should be downloaded.
  ///   - options: The `ApolloSchemaOptions` object to use to download the schema.
  public static func run(from folder: URL,
                         with cliFolderURL: URL,
                         options: ApolloSchemaOptions) throws -> String {
    guard FileManager.default.apollo_folderExists(at: folder) else {
      throw SchemaDownloadError.folderDoesNotExist(folder)
    }
    
    try FileManager.default.apollo_createContainingFolderIfNeeded(for: options.outputURL)
    
    let cli = try ApolloCLI.createCLI(cliFolderURL: cliFolderURL, timeout: options.downloadTimeout)
    return try cli.runApollo(with: options.arguments, from: folder)
  }
}

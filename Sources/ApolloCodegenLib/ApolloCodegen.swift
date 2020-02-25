import Foundation

/// A class to facilitate running code generation
@available(OSX, message: "Only available on macOS")
public class ApolloCodegen {
  
  /// Errors which can happen with code generation
  public enum CodegenError: Error, LocalizedError {
    case folderDoesNotExist(_ url: URL)
    
    public var errorDescription: String? {
      switch self {
      case .folderDoesNotExist(let url):
        return "Can't run codegen trying to run the command from \(url) because there is no folder there! This should be the folder which, at some depth, contains all your `.graphql` files."
      }
    }
  }
  
  /// Runs code generation from the given folder with the passed-in options
  ///
  /// - Parameters:
  ///   - folder: The folder to run the script from. Should be the folder that at some depth, contains all `.graphql` files.
  ///   - cliFolderURL: The folder where the Apollo CLI is/should be downloaded.
  ///   - options: The options object to use to run the code generation.
  /// - Returns: Output from a successful run
  @discardableResult
  public static func run(from folder: URL,
                         with cliFolderURL: URL,
                         options: ApolloCodegenOptions) throws -> String {
    guard FileManager.default.apollo_folderExists(at: folder) else {
      throw CodegenError.folderDoesNotExist(folder)
    }
    
    switch options.outputFormat {
    case .multipleFiles(let folderURL):
      try FileManager.default.apollo_createFolderIfNeeded(at: folderURL)
    case .singleFile(let fileURL):
      try FileManager.default.apollo_createContainingFolderIfNeeded(for: fileURL)
    }

    let cli = try ApolloCLI.createCLI(cliFolderURL: cliFolderURL, timeout: options.downloadTimeout)
    return try cli.runApollo(with: options.arguments, from: folder)
  }
}

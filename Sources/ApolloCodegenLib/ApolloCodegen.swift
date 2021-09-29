import Foundation

// Only available on macOS
#if os(macOS)

/// A class to facilitate running code generation
public class ApolloCodegen {
  
  /// Errors which can happen with code generation
  public enum CodegenError: Error, LocalizedError {
    case folderDoesNotExist(_ url: URL)
    case multipleFilesButNotDirectoryURL(_ url: URL)
    case singleFileButNotSwiftFileURL(_ url: URL)
    
    public var errorDescription: String? {
      switch self {
      case .folderDoesNotExist(let url):
        return "Can't run codegen trying to run the command from \(url) because there is no folder there! This should be the folder which, at some depth, contains all your `.graphql` files."
      case .multipleFilesButNotDirectoryURL(let url):
        return "Codegen is requesting multiple file generation, but the URL passed in (\(url)) is not a directory URL. Please check your URL and try again."
      case .singleFileButNotSwiftFileURL(let url):
        return "Codegen is requesting single file generation, but the URL passed in (\(url)) is a not a Swift file URL. Please check your URL and try again."
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
                         options: ApolloCodegenConfiguration) throws -> String {
    guard FileManager.default.apollo.folderExists(at: folder) else {
      throw CodegenError.folderDoesNotExist(folder)
    }

    #warning("TODO: Build folder structure from configuration")
    return "Not implemented!"
  }
}

#endif

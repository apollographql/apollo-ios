import Foundation

// Only available on macOS
#if os(macOS)

/// A class to facilitate running code generation
public class ApolloCodegen {
  static private let fileManager = FileManager.default.apollo

  /// Errors which can happen with code generation
  public enum Error: Swift.Error, LocalizedError {
    case invalidSchemaPath
    case invalidSchemaTypesPath
    case invalidOperationsPath
    case invalidOperationIdentifiersPath

    public var errorDescription: String {
      switch self {
      case .invalidSchemaPath:
        return "There was a problem evaluating the schema input path."
      case .invalidSchemaTypesPath:
        return "There was a problem evaluating the schema types output path."
      case .invalidOperationsPath:
        return "There was a problem evaluating the operations output path."
      case .invalidOperationIdentifiersPath:
        return "There was a problem evaluating the operation identifiers output path."
      }
    }

    public var recoverySuggestion: String {
      switch self {
      case .invalidSchemaPath:
        return "Check that the schema input path is an existing schema file containing SDL or JSON."
      case .invalidSchemaTypesPath:
        return "Check that the schema types output path exists and is a directory, or can be created."
      case .invalidOperationsPath:
        return "Check that the operations output path exists and is a directory, or can be created."
      case .invalidOperationIdentifiersPath:
        return "Check that the operations identifiers path is an existing file or can be created."
      }
    }
  }
  
  /// Executes the code generation engine with a specified configuration.
  ///
  /// - Parameters:
  ///   - configuration: The configuration to use to build the code generation.
  public static func build(with configuration: ApolloCodegenConfiguration) throws {
    try validate(configuration)
  }

  /// This is a preflight check to ensure that the specified configuration is valid before attempting to build the code generation output.
  static func validate(_ config: ApolloCodegenConfiguration) throws {

    CodegenLogger.log(String(describing: config), logLevel: .debug)

    // File inputs

    try testFile(at: config.input.schemaPath, throwing: .invalidSchemaPath, required: true)

    // File outputs - schema types

    try requireDirectory(at: config.output.schemaTypes.path, throwing: .invalidSchemaTypesPath)

    // File outputs - operations

    if case .absolute(let operationsOutputPath) = config.output.operations {
      try requireDirectory(at: operationsOutputPath, throwing: .invalidOperationsPath)
    }

    // File outputs - operation identifiers

    if let operationIdentifiersPath = config.output.operationIdentifiersPath {
      try testFile(at: operationIdentifiersPath, throwing: .invalidOperationIdentifiersPath)
    }
  }

  /// Tests that the given path exists and is a file, if required. If not then only if the path exists must be a file too.
  private static func testFile(at path: String, throwing error: Error, required: Bool = false) throws {
    let throwBlock = {
      CodegenLogger.log("\(path) must be a file!", logLevel: .error)
      CodegenLogger.log(error.recoverySuggestion, logLevel: .debug)

      throw error
    }

    if required {
      guard fileManager.fileExists(at: path) else { return try throwBlock() }
    } else {
      if fileManager.folderExists(at: path) { return try throwBlock() }
    }
  }

  /// Validates that if the given path exists it is a directory. If it does not exist it attempts to create it.
  private static func requireDirectory(at path: String, throwing error: Error) throws {
    if fileManager.fileExists(at: path) {
      CodegenLogger.log("\(path) must be a directory!", logLevel: .error)
      CodegenLogger.log(error.recoverySuggestion, logLevel: .debug)

      throw error
    }

    do {
      try fileManager.createFolderIfNeeded(at: path)
    } catch (let catchError) {
      CodegenLogger.log("\(path) cannot be created! \(catchError)", logLevel: .error)
      CodegenLogger.log(error.recoverySuggestion, logLevel: .debug)

      throw error
    }
  }
}

#endif

import Foundation

// Only available on macOS
#if os(macOS)

/// A class to facilitate running code generation
public class ApolloCodegen {
  static private let fileManager = FileManager.default.apollo

  public enum PathType {
    case schema
    case schemaTypes
    case operations
    case operationIdentifiers

    public var errorRecoverySuggestion: String {
      switch self {
      case .schema:
        return "Check that the schema input path is an existing schema file containing SDL or JSON."
      case .schemaTypes:
        return "Check that the schema types output path exists and is a directory, or can be created."
      case .operations:
        return "Check that the operations output path exists and is a directory, or can be created."
      case .operationIdentifiers:
        return "Check that the operations identifiers path is an existing file or can be created."
      }
    }
  }

  /// Errors which can happen with code generation
  public enum PathError: Swift.Error, LocalizedError, Equatable {
    case notAFile(PathType)
    case notADirectory(PathType)
    case folderCreationFailed(PathType, underlyingError: Error)

    public var errorDescription: String {
      switch self {
      case let .notAFile(pathType):
        return "\(pathType) path must be a file!"
      case let .notADirectory(pathType):
        return "\(pathType) path must be a folder!"
      case let .folderCreationFailed(pathType, underlyingError):
        return "\(pathType) folder cannot be created! Error: \(underlyingError)"
      }
    }

    public var recoverySuggestion: String {
      switch self {
      case let .notAFile(pathType),
        let .notADirectory(pathType),
        let .folderCreationFailed(pathType, _):
        return pathType.errorRecoverySuggestion
      }
    }

    public func logging(withPath path: String) -> PathError {
      CodegenLogger.log(self.logMessage(forPath: path), logLevel: .error)
      CodegenLogger.log(self.recoverySuggestion, logLevel: .debug)
      return self
    }

    private func logMessage(forPath path: String) -> String {
      self.errorDescription + "Path: \(path)"
    }

    public static func ==(lhs: PathError, rhs: PathError) -> Bool {
      lhs.errorDescription == rhs.errorDescription
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
    guard fileManager.existsAsFile(atPath: config.input.schemaPath) else {
      throw PathError.notAFile(.schema).logging(withPath: config.input.schemaPath)
    }

    // File outputs - schema types
    try requireDirectory(atPath: config.output.schemaTypes.path, ofType: .schemaTypes)

    // File outputs - operations
    if case .absolute(let operationsOutputPath) = config.output.operations {
      try requireDirectory(atPath: operationsOutputPath, ofType: .operations)
    }

    // File outputs - operation identifiers
    if let operationIdentifiersPath = config.output.operationIdentifiersPath {
      if fileManager.existsAsDirectory(atPath: operationIdentifiersPath) {
        throw PathError.notAFile(.operationIdentifiers).logging(withPath: operationIdentifiersPath)
      }
    }
  }

  /// Validates that if the given path exists it is a directory. If it does not exist it attempts to create it.
  private static func requireDirectory(atPath path: String, ofType pathType: PathType) throws {
    if fileManager.existsAsFile(atPath: path) {
      throw PathError.notADirectory(pathType).logging(withPath: path)
    }

    do {
      try fileManager.createDirectoryIfNeeded(at: path)
    } catch (let underlyingError) {
      throw PathError.folderCreationFailed(pathType, underlyingError: underlyingError)
        .logging(withPath: path)
    }
  }
}

#endif

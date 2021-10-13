import Foundation
import PathKit

// Only available on macOS
#if os(macOS)

/// A class to facilitate running code generation
public class ApolloCodegen {
  
  /// Errors which can happen with code generation
  public enum Error: Swift.Error, LocalizedError {
    case pathNotFound(_ path: String)
    case pathNotAFile(_ path: String)
    case pathNotADirectory(_ path: String)
    case cannotCreatePath(_ path: String)

    public var errorDescription: String? {
      switch self {
      case .pathNotFound(let path):
        return "\(path) cannot be found."
      case .pathNotAFile(let path):
        return "\(path) is not a file."
      case .pathNotADirectory(let path):
        return "\(path) is not a directory."
      case .cannotCreatePath(let path):
        return "Cannot create path at \(path)"
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
  private static func validate(_ config: ApolloCodegenConfiguration) throws {

    // File inputs

    let schemaInputPath = Path(config.input.schemaPath)

    guard schemaInputPath.exists else {
      throw Error.pathNotFound(schemaInputPath.string)
    }

    guard schemaInputPath.isFile else {
      throw Error.pathNotAFile(schemaInputPath.string)
    }

    // File outputs - schema types

    let schemaOutputPath = Path(config.output.schemaTypes.path)
    try validateDirectory(path: schemaOutputPath)

    // File outputs - operations

    if case .absolute(let path) = config.output.operations {
      let operationsOutputPath = Path(path)
      try validateDirectory(path: operationsOutputPath)
    }
  }

  private static func validateDirectory(path: Path) throws {
    switch (path.exists, path.isFile) {
    case (true, true):
      throw Error.pathNotADirectory(path.string)
    case (false, _):
      do {
        try path.mkpath()
      } catch {
        throw Error.cannotCreatePath(path.string)
      }
    default:
      break
    }
  }
}

#endif

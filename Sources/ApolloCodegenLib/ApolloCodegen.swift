import Foundation

// Only available on macOS
#if os(macOS)

/// A class to facilitate running code generation
public class ApolloCodegen {
  public enum Error: Swift.Error, LocalizedError {
    case validationFailed(atLines: [String])

    public var errorDescription: String? {
      switch self {
      case let .validationFailed(lines):
        return "Schema and Operation validation failed! Check \(lines)"
      }
    }
  }
  /// Executes the code generation engine with a specified configuration.
  ///
  /// - Parameters:
  ///   - configuration: The configuration to use to build the code generation.
  public static func build(with configuration: ApolloCodegenConfiguration) throws {
    try configuration.validate()

    let compilationResult = try compileResults(using: configuration.input)
    #warning("TODO - compilationResult will be passed into the next step")
  }

  static func compileResults(
    using input: ApolloCodegenConfiguration.FileInput
  ) throws -> CompilationResult {
    let frontend = try ApolloCodegenFrontend()

    let schemaURL = URL(fileURLWithPath: input.schemaPath)
    let graphqlSchema = try frontend.loadSchema(from: schemaURL)

    let matches = try Glob(input.searchPaths).match()
    let documents = try matches.map({ path in
      return try frontend.parseDocument(from: URL(fileURLWithPath: path))
    })
    let mergedDocument = try frontend.mergeDocuments(documents)

    let graphqlErrors = try frontend.validateDocument(schema: graphqlSchema, document: mergedDocument)
    guard graphqlErrors.isEmpty else {
      throw Error.validationFailed(atLines: graphqlErrors.flatMap({ $0.logLines }))
    }

    return try frontend.compile(schema: graphqlSchema, document: mergedDocument)
  }
}

#endif

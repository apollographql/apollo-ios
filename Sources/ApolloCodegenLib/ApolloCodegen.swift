import Foundation

// Only available on macOS
#if os(macOS)

/// A class to facilitate running code generation
public class ApolloCodegen {
  // MARK: Public

  /// Errors that can occur during code generation.
  public enum Error: Swift.Error, LocalizedError {
    /// An error occured during validation of the GraphQL schema or operations.
    case graphQLSourceValidationFailed(atLines: [String])

    public var errorDescription: String? {
      switch self {
      case let .graphQLSourceValidationFailed(lines):
        return "An error occured during validation of the GraphQL schema or operations! Check \(lines)"
      }
    }
  }

  /// Executes the code generation engine with a specified configuration.
  ///
  /// - Parameters:
  ///   - configuration: A configuration object that specifies inputs, outputs and behaviours used during code generation.
  public static func build(with configuration: ApolloCodegenConfiguration) throws {
    try configuration.validate()

    let compilationResult = try compileGraphQLResult(using: configuration.input)

    let ir = IR(
      schemaName: configuration.output.schemaTypes.moduleName,
      compilationResult: compilationResult
    )

    try generateSchemaFiles(
      for: ir.schema.referencedTypes,
      configuration: configuration.output.schemaTypes
    )
    #warning("TODO - generate operation/fragment files")
    #warning("TODO - generate package manager manifest")
  }

  static func compileGraphQLResult(
    using input: ApolloCodegenConfiguration.FileInput
  ) throws -> CompilationResult {
    let frontend = try GraphQLJSFrontend()

    let schemaURL = URL(fileURLWithPath: input.schemaPath)
    let graphqlSchema = try frontend.loadSchema(from: schemaURL)

    let matches = try Glob(input.searchPaths).match()
    let documents = try matches.map({ path in
      return try frontend.parseDocument(from: URL(fileURLWithPath: path))
    })
    let mergedDocument = try frontend.mergeDocuments(documents)

    let graphqlErrors = try frontend.validateDocument(schema: graphqlSchema, document: mergedDocument)
    guard graphqlErrors.isEmpty else {
      let errorlines = graphqlErrors.flatMap({ $0.logLines })
      CodegenLogger.log(String(describing: errorlines), logLevel: .error)
      throw Error.graphQLSourceValidationFailed(atLines: errorlines)
    }

    return try frontend.compile(schema: graphqlSchema, document: mergedDocument)
  }

  static func generateSchemaFiles(
    for referencedTypes: IR.Schema.ReferencedTypes,
    configuration: ApolloCodegenConfiguration.SchemaTypesFileOutput
  ) throws {
    let schemaTypesDirectory = configuration.modulePath

    try referencedTypes.objects.forEach { graphqlObject in
      try TypeFileGenerator.generateFile(for: graphqlObject, directoryPath: schemaTypesDirectory)
    }

    #warning("TODO - generate enum files")
    #warning("TODO - generate interface files")
    #warning("TODO - generate union files")
    #warning("TODO - generate schema file")
  }
}

#endif

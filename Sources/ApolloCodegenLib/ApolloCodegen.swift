import Foundation
import OrderedCollections

// Only available on macOS
#if os(macOS)

/// A class to facilitate running code generation
public class ApolloCodegen {

  // MARK: Public

  /// Errors that can occur during code generation.
  public enum Error: Swift.Error, LocalizedError {
    /// An error occured during validation of the GraphQL schema or operations.
    case graphQLSourceValidationFailure(atLines: [String])

    public var errorDescription: String? {
      switch self {
      case let .graphQLSourceValidationFailure(lines):
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

    let compilationResult = try compileGraphQLResult(configuration.input)

    let ir = IR(
      schemaName: configuration.output.schemaTypes.schemaName,
      compilationResult: compilationResult
    )

    try generateFiles(
      compilationResult: compilationResult,
      ir: ir,
      config: configuration
    )
  }

  // MARK: Internal

  /// Performs GraphQL source validation and compiles the schema and operation source documents. 
  static func compileGraphQLResult(
    _ config: ApolloCodegenConfiguration.FileInput
  ) throws -> CompilationResult {
    let frontend = try GraphQLJSFrontend()

    let schemaURL = URL(fileURLWithPath: config.schemaPath)
    let graphqlSchema = try frontend.loadSchema(from: schemaURL)

    let matches = try Glob(config.searchPaths).match()
    let documents = try matches.map({ path in
      return try frontend.parseDocument(from: URL(fileURLWithPath: path))
    })
    let mergedDocument = try frontend.mergeDocuments(documents)

    let graphqlErrors = try frontend.validateDocument(schema: graphqlSchema, document: mergedDocument)
    guard graphqlErrors.isEmpty else {
      let errorlines = graphqlErrors.flatMap({ $0.logLines })
      CodegenLogger.log(String(describing: errorlines), logLevel: .error)
      throw Error.graphQLSourceValidationFailure(atLines: errorlines)
    }

    return try frontend.compile(schema: graphqlSchema, document: mergedDocument)
  }

  /// Generates Swift files for the compiled schema, ir and configured output structure.
  static func generateFiles(
    compilationResult: CompilationResult,
    ir: IR,
    config: ApolloCodegenConfiguration,
    fileManager: FileManager = FileManager.default
  ) throws {
    for graphQLObject in ir.schema.referencedTypes.objects {
      try autoreleasepool {
        try ObjectFileGenerator.generate(
          graphQLObject,
          directoryPath: config.output.resolvePath(.object),
          fileManager: fileManager
        )
      }
    }

    for graphQLEnum in ir.schema.referencedTypes.enums {
      try autoreleasepool {
        try EnumFileGenerator.generate(
          graphQLEnum,
          directoryPath: config.output.resolvePath(.enum),
          fileManager: fileManager
        )
      }
    }

    for graphQLInterface in ir.schema.referencedTypes.interfaces {
      try autoreleasepool {
        try InterfaceFileGenerator.generate(
          graphQLInterface,
          directoryPath: config.output.resolvePath(.interface),
          fileManager: fileManager
        )
      }
    }

    for graphQLUnion in ir.schema.referencedTypes.unions {
      try autoreleasepool {
        try UnionFileGenerator.generate(
          graphQLUnion,
          moduleName: config.output.schemaTypes.schemaName,
          directoryPath: config.output.resolvePath(.union),
          fileManager: fileManager
        )
      }
    }

    for graphQLInputObject in ir.schema.referencedTypes.inputObjects {
      try autoreleasepool {
        try InputObjectFileGenerator.generate(
          graphQLInputObject,
          directoryPath: config.output.resolvePath(.inputObject),
          fileManager: fileManager
        )
      }
    }

    try SchemaFileGenerator.generate(
      ir.schema,
      directoryPath: config.output.resolvePath(.schema),
      fileManager: fileManager
    )

    for fragment in compilationResult.fragments {
      try autoreleasepool {
        let irFragment = ir.build(fragment: fragment)
        try FragmentFileGenerator.generate(
          irFragment,
          schema: ir.schema,
          config: config.output,
          directoryPath: config.output.resolvePath(.fragment(fragment)),
          fileManager: fileManager
        )
      }
    }

    for operation in compilationResult.operations {
      try autoreleasepool {
        let irOperation = ir.build(operation: operation)
        try OperationFileGenerator.generate(
          irOperation,
          schema: ir.schema,
          config: config,
          directoryPath: config.output.resolvePath(.operation(operation)),
          fileManager: fileManager
        )
      }
    }

    try SchemaModuleFileGenerator.generate(
      config.output.schemaTypes,
      fileManager: fileManager
    )
  }
}

#endif

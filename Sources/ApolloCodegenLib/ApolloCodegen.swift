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

    let compilationResult = try compileGraphQLResult(using: configuration.input)

    let ir = IR(
      schemaName: configuration.output.schemaTypes.moduleName,
      compilationResult: compilationResult
    )

    try generateFiles(
      for: ir.schema.referencedTypes,
      config: configuration
    )

    let modulePath = configuration.output.schemaTypes.path
    try SchemaFileGenerator(
      schema: ir.schema,
      directoryPath: modulePath
    ).generateFile()

    try generateFiles(
      for: compilationResult,
      ir: ir,
      config: configuration
    )

    try SchemaModuleFileGenerator(configuration.output.schemaTypes)
      .generateFile()
  }

  // MARK: Internal

  /// Performs GraphQL source validation and compiles the schema and operation source documents. 
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
      throw Error.graphQLSourceValidationFailure(atLines: errorlines)
    }

    return try frontend.compile(schema: graphqlSchema, document: mergedDocument)
  }

  /// Generates files for referenced schema types.
  static func generateFiles(
    for referencedTypes: IR.Schema.ReferencedTypes,
    config: ApolloCodegenConfiguration
  ) throws {
    for graphQLObject in referencedTypes.objects {
      try autoreleasepool {
        try ObjectFileGenerator.generate(
          graphQLObject,
          directoryPath: config.output.schemaTypes.path
        )
      }
    }

    for graphQLEnum in referencedTypes.enums {
      try autoreleasepool {
        try EnumFileGenerator.generate(
          graphQLEnum,
          directoryPath: config.output.schemaTypes.path
        )
      }
    }

    for graphQLInterface in referencedTypes.interfaces {
      try autoreleasepool {
        try InterfaceFileGenerator.generate(
          graphQLInterface,
          directoryPath: config.output.schemaTypes.path
        )
      }
    }

    for graphQLUnion in referencedTypes.unions {
      try autoreleasepool {
        try UnionFileGenerator.generate(
          graphQLUnion,
          moduleName: config.output.schemaTypes.moduleName,
          directoryPath: config.output.schemaTypes.path
        )
      }
    }

    for graphQLInputObject in referencedTypes.inputObjects {
      try autoreleasepool {
        try InputObjectFileGenerator.generate(
          graphQLInputObject,
          directoryPath: config.output.schemaTypes.moduleName
        )
      }
    }
  }

  /// Generates files for operation and fragment types.
  static func generateFiles(
    for compilationResult: CompilationResult,
    ir: IR,
    config: ApolloCodegenConfiguration
  ) throws {
    for fragment in compilationResult.fragments {
      try autoreleasepool {
        let irFragment = ir.build(fragment: fragment)
        try FragmentFileGenerator.generate(
          irFragment,
          schema: ir.schema,
          config: config,
          directoryPath: config.output.schemaTypes.path
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
          directoryPath: config.output.schemaTypes.path
        )
      }
    }
  }
}

#endif

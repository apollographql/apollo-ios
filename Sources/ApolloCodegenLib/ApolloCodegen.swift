import Foundation
import OrderedCollections
import ApolloUtils

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

    let referenceConfig = ReferenceWrapped(value: configuration)
    let compilationResult = try compileGraphQLResult(referenceConfig)

    let ir = IR(
      schemaName: referenceConfig.output.schemaTypes.schemaName,
      compilationResult: compilationResult
    )

    try generateFiles(
      compilationResult: compilationResult,
      ir: ir,
      config: referenceConfig
    )
  }

  // MARK: Internal

  /// Performs GraphQL source validation and compiles the schema and operation source documents. 
  static func compileGraphQLResult(
    _ config: ReferenceWrapped<ApolloCodegenConfiguration>
  ) throws -> CompilationResult {
    let frontend = try GraphQLJSFrontend()

    let schemaURL = URL(fileURLWithPath: config.input.schemaPath)
    let graphqlSchema = try frontend.loadSchema(from: schemaURL)

    let matches = try Glob(config.input.searchPaths).match()
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
    config: ReferenceWrapped<ApolloCodegenConfiguration>,
    fileManager: FileManager = FileManager.default
  ) throws {
    for graphQLObject in ir.schema.referencedTypes.objects {
      try autoreleasepool {
        try ObjectFileGenerator(graphqlObject: graphQLObject)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    for graphQLEnum in ir.schema.referencedTypes.enums {
      try autoreleasepool {
        try EnumFileGenerator(graphqlEnum: graphQLEnum)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    for graphQLInterface in ir.schema.referencedTypes.interfaces {
      try autoreleasepool {
        try InterfaceFileGenerator(graphqlInterface: graphQLInterface)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    for graphQLUnion in ir.schema.referencedTypes.unions {
      try autoreleasepool {
        try UnionFileGenerator(
          graphqlUnion: graphQLUnion,
          schemaName: config.output.schemaTypes.schemaName
        ).generate(
          forConfig: config,
          fileManager: fileManager
        )
      }
    }

    for graphQLInputObject in ir.schema.referencedTypes.inputObjects {
      try autoreleasepool {
        try InputObjectFileGenerator(graphqlInputObject: graphQLInputObject)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    for graphQLScalar in ir.schema.referencedTypes.customScalars {
      try autoreleasepool {
        try CustomScalarFileGenerator(graphqlScalar: graphQLScalar)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    try SchemaFileGenerator(schema: ir.schema)
      .generate(forConfig: config, fileManager: fileManager)

    for fragment in compilationResult.fragments {
      try autoreleasepool {
        let irFragment = ir.build(fragment: fragment)
        try FragmentFileGenerator(irFragment: irFragment, schema: ir.schema)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    for operation in compilationResult.operations {
      try autoreleasepool {
        let irOperation = ir.build(operation: operation)
        try OperationFileGenerator(irOperation: irOperation, schema: ir.schema, config: config)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    try SchemaModuleFileGenerator.generate(config, fileManager: fileManager)
  }
}

#endif

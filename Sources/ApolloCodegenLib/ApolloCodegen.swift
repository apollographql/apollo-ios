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
    let compilationResult = try compileGraphQLResult(
      referenceConfig,
      experimentalFeatures: configuration.experimentalFeatures
    )

    let ir = IR(
      schemaName: referenceConfig.schemaName,
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
    _ config: ReferenceWrapped<ApolloCodegenConfiguration>,
    experimentalFeatures: ApolloCodegenConfiguration.ExperimentalFeatures = .init()
  ) throws -> CompilationResult {
    let frontend = try GraphQLJSFrontend()

    let graphQLSchema = try createSchema(config, frontend)
    let operationsDocument = try createOperationsDocument(config, frontend, experimentalFeatures)

    let graphqlErrors = try frontend.validateDocument(
      schema: graphQLSchema,
      document: operationsDocument
    )

    guard graphqlErrors.isEmpty else {
      let errorlines = graphqlErrors.flatMap({ $0.logLines })
      CodegenLogger.log(String(describing: errorlines), logLevel: .error)
      throw Error.graphQLSourceValidationFailure(atLines: errorlines)
    }

    return try frontend.compile(schema: graphQLSchema, document: operationsDocument)
  }

  private static func createSchema(
    _ config: ReferenceWrapped<ApolloCodegenConfiguration>,
    _ frontend: GraphQLJSFrontend
  ) throws -> GraphQLSchema {
    let matches = try Glob(config.input.schemaSearchPaths).match()
    let sources = try matches.map { try frontend.makeSource(from: URL(fileURLWithPath: $0)) }
    return try frontend.loadSchema(from: sources)
  }

  private static func createOperationsDocument(
    _ config: ReferenceWrapped<ApolloCodegenConfiguration>,
    _ frontend: GraphQLJSFrontend,
    _ experimentalFeatures: ApolloCodegenConfiguration.ExperimentalFeatures
  ) throws -> GraphQLDocument {
    let matches = try Glob(config.input.operationSearchPaths).match()
    let documents = try matches.map({ path in
      return try frontend.parseDocument(
        from: URL(fileURLWithPath: path),
        experimentalClientControlledNullability: experimentalFeatures.clientControlledNullability
      )
    })
    return try frontend.mergeDocuments(documents)
  }

  /// Generates Swift files for the compiled schema, ir and configured output structure.
  static func generateFiles(
    compilationResult: CompilationResult,
    ir: IR,
    config: ReferenceWrapped<ApolloCodegenConfiguration>,
    fileManager: FileManager = FileManager.default
  ) throws {
    for fragment in compilationResult.fragments {
      try autoreleasepool {
        let irFragment = ir.build(fragment: fragment)
        try FragmentFileGenerator(irFragment: irFragment, schema: ir.schema, config: config)
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

    for graphQLObject in ir.schema.referencedTypes.objects {
      try autoreleasepool {
        try ObjectFileGenerator(
          graphqlObject: graphQLObject,
          config: config
        ).generate(
          forConfig: config,
          fileManager: fileManager
        )

        if config.output.testMocks != .none {
          try MockObjectFileGenerator(
            graphqlObject: graphQLObject,
            ir: ir,
            config: config
          ).generate(
            forConfig: config,
            fileManager: fileManager
          )
        }
      }
    }

    for graphQLEnum in ir.schema.referencedTypes.enums {
      try autoreleasepool {
        try EnumFileGenerator(graphqlEnum: graphQLEnum, config: config)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    for graphQLInterface in ir.schema.referencedTypes.interfaces {
      try autoreleasepool {
        try InterfaceFileGenerator(graphqlInterface: graphQLInterface, config: config)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    for graphQLUnion in ir.schema.referencedTypes.unions {
      try autoreleasepool {
        try UnionFileGenerator(
          graphqlUnion: graphQLUnion,
          schemaName: config.schemaName,
          config: config
        ).generate(
          forConfig: config,
          fileManager: fileManager
        )

        if config.output.testMocks != .none {
          try MockUnionFileGenerator(
            graphqlUnion: graphQLUnion,
            ir: ir,
            config: config
          ).generate(
            forConfig: config,
            fileManager: fileManager
          )
        }
      }
    }

    for graphQLInputObject in ir.schema.referencedTypes.inputObjects {
      try autoreleasepool {
        try InputObjectFileGenerator(
          graphqlInputObject: graphQLInputObject,
          schema: ir.schema,
          config: config
        ).generate(
          forConfig: config,
          fileManager: fileManager
        )
      }
    }

    for graphQLScalar in ir.schema.referencedTypes.customScalars {
      try autoreleasepool {
        try CustomScalarFileGenerator(graphqlScalar: graphQLScalar, config: config)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    try SchemaFileGenerator(schema: ir.schema, config: config)
      .generate(forConfig: config, fileManager: fileManager)

    try SchemaModuleFileGenerator.generate(config, fileManager: fileManager)
  }
}

#endif

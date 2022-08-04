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
    case testMocksInvalidSwiftPackageConfiguration

    public var errorDescription: String? {
      switch self {
      case let .graphQLSourceValidationFailure(lines):
        return "An error occured during validation of the GraphQL schema or operations! Check \(lines)"
      case .testMocksInvalidSwiftPackageConfiguration:
        return "Schema Types must be generated with module type 'swiftPackageManager' to generate a swift package for test mocks."
      }
    }
  }

  /// Executes the code generation engine with a specified configuration.
  ///
  /// - Parameters:
  ///   - configuration: A configuration object that specifies inputs, outputs and behaviours used
  ///     during code generation.
  ///   - rootURL: The root `URL` to resolve relative `URL`s in the configuration's paths against.
  ///     If `nil`, the current working directory of the executing process will be used.
  public static func build(
    with configuration: ApolloCodegenConfiguration,
    withRootURL rootURL: URL? = nil
  ) throws {
    let configContext = ConfigurationContext(
      config: configuration,
      rootURL: rootURL
    )
    let compilationResult = try compileGraphQLResult(
      configContext,
      experimentalFeatures: configuration.experimentalFeatures
    )

    try validate(config: configContext)

    let ir = IR(
      schemaName: configContext.schemaName,
      compilationResult: compilationResult
    )

    try generateFiles(
      compilationResult: compilationResult,
      ir: ir,
      config: configContext
    )
  }

  // MARK: Internal

  @dynamicMemberLookup
  class ConfigurationContext {
    let config: ApolloCodegenConfiguration
    let pluralizer: Pluralizer
    let rootURL: URL?

    init(
      config: ApolloCodegenConfiguration,
      rootURL: URL? = nil
    ) {
      self.config = config
      self.pluralizer = Pluralizer(rules: config.options.additionalInflectionRules)
      self.rootURL = rootURL?.standardizedFileURL
    }

    subscript<T>(dynamicMember keyPath: KeyPath<ApolloCodegenConfiguration, T>) -> T {
      config[keyPath: keyPath]
    }
  }

  /// Performs validation against deterministic errors that will cause code generation to fail.
  static func validate(config: ConfigurationContext) throws {
    if case .swiftPackage = config.output.testMocks,
        config.output.schemaTypes.moduleType != .swiftPackageManager {
      throw Error.testMocksInvalidSwiftPackageConfiguration
    }
  }

  /// Performs GraphQL source validation and compiles the schema and operation source documents.
  static func compileGraphQLResult(
    _ config: ConfigurationContext,
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

    return try frontend.compile(
      schema: graphQLSchema,
      document: operationsDocument,
      experimentalLegacySafelistingCompatibleOperations: experimentalFeatures.legacySafelistingCompatibleOperations
    )
  }

  private static func createSchema(
    _ config: ConfigurationContext,
    _ frontend: GraphQLJSFrontend
  ) throws -> GraphQLSchema {
    let matches = try Glob(config.input.schemaSearchPaths, relativeTo: config.rootURL).match()
    let sources = try matches.map { try frontend.makeSource(from: URL(fileURLWithPath: $0)) }
    return try frontend.loadSchema(from: sources)
  }

  private static func createOperationsDocument(
    _ config: ConfigurationContext,
    _ frontend: GraphQLJSFrontend,
    _ experimentalFeatures: ApolloCodegenConfiguration.ExperimentalFeatures
  ) throws -> GraphQLDocument {
    let matches = try Glob(config.input.operationSearchPaths, relativeTo: config.rootURL).match()
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
    config: ConfigurationContext,
    fileManager: ApolloFileManager = .default
  ) throws {
    for fragment in compilationResult.fragments {
      try autoreleasepool {
        let irFragment = ir.build(fragment: fragment)
        try FragmentFileGenerator(irFragment: irFragment, schema: ir.schema, config: config)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    var operationIDsFileGenerator = OperationIdentifiersFileGenerator(config: config)

    for operation in compilationResult.operations {
      try autoreleasepool {
        let irOperation = ir.build(operation: operation)
        try OperationFileGenerator(irOperation: irOperation, schema: ir.schema, config: config)
          .generate(forConfig: config, fileManager: fileManager)

        operationIDsFileGenerator?.collectOperationIdentifier(irOperation)
      }
    }

    try operationIDsFileGenerator?.generate(fileManager: fileManager)
    operationIDsFileGenerator = nil

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

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
    case inputSearchPathInvalid(path: String)
    case schemaNameConflict(name: String)
    case cannotLoadSchema
    case cannotLoadOperations

    public var errorDescription: String? {
      switch self {
      case let .graphQLSourceValidationFailure(lines):
        return "An error occured during validation of the GraphQL schema or operations! Check \(lines)"
      case .testMocksInvalidSwiftPackageConfiguration:
        return "Schema Types must be generated with module type 'swiftPackageManager' to generate a swift package for test mocks."
      case let .inputSearchPathInvalid(path):
        return "Input search path '\(path)' is invalid. Input search paths must include a file extension component. (eg. '.graphql')"
      case let .schemaNameConflict(name):
        return "Schema name \(name) conflicts with name of a type in your GraphQL schema. Please choose a different schema name. Suggestions: \(name)Schema, \(name)GraphQL, \(name)API"
      case .cannotLoadSchema:
        return "A GraphQL schema could not be found. Please verify the schema search paths."
      case .cannotLoadOperations:
        return "No GraphQL operations could be found. Please verify the operation search paths."
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
    try build(with: configuration, rootURL: rootURL)
  }

  internal static func build(
    with configuration: ApolloCodegenConfiguration,
    rootURL: URL? = nil,
    fileManager: ApolloFileManager = .default
  ) throws {

    let configContext = ConfigurationContext(
      config: configuration,
      rootURL: rootURL
    )

    try validate(config: configContext)

    let compilationResult = try compileGraphQLResult(
      configContext,
      experimentalFeatures: configuration.experimentalFeatures
    )

    try validate(schemaName: configContext.schemaName, compilationResult: compilationResult)

    let ir = IR(
      schemaName: configContext.schemaName,
      compilationResult: compilationResult
    )

    var existingGeneratedFilePaths = configuration.options.pruneGeneratedFiles ?
    try findExistingGeneratedFilePaths(
      config: configContext,
      fileManager: fileManager
    ) : []

    try generateFiles(
      compilationResult: compilationResult,
      ir: ir,
      config: configContext,
      fileManager: fileManager
    )

    if configuration.options.pruneGeneratedFiles {
      try deleteExtraneousGeneratedFiles(
        from: &existingGeneratedFilePaths,
        afterCodeGenerationUsing: fileManager
      )
    }
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

    for searchPath in config.input.schemaSearchPaths {
      try validate(inputSearchPath: searchPath)
    }
    for searchPath in config.input.operationSearchPaths {
      try validate(inputSearchPath: searchPath)
    }
  }

  static private func validate(inputSearchPath: String) throws {
    guard inputSearchPath.contains(".") && !inputSearchPath.hasSuffix(".") else {
      throw Error.inputSearchPathInvalid(path: inputSearchPath)
    }
  }

  static func validate(schemaName: String, compilationResult: CompilationResult) throws {
    guard
      !compilationResult.referencedTypes.contains(where: { namedType in
        namedType.swiftName == schemaName.firstUppercased
      }),
      !compilationResult.fragments.contains(where: { fragmentDefinition in
        fragmentDefinition.name == schemaName.firstUppercased
      })
    else {
      throw Error.schemaNameConflict(name: schemaName)
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
    let validationOptions = ValidationOptions(config: config)

    let graphqlErrors = try frontend.validateDocument(
      schema: graphQLSchema,
      document: operationsDocument,
      validationOptions: validationOptions
    )

    guard graphqlErrors.isEmpty else {
      let errorlines = graphqlErrors.flatMap({ $0.logLines })
      CodegenLogger.log(String(describing: errorlines), logLevel: .error)
      throw Error.graphQLSourceValidationFailure(atLines: errorlines)
    }

    return try frontend.compile(
      schema: graphQLSchema,
      document: operationsDocument,
      experimentalLegacySafelistingCompatibleOperations: experimentalFeatures.legacySafelistingCompatibleOperations,
      validationOptions: validationOptions
    )
  }

  private static func createSchema(
    _ config: ConfigurationContext,
    _ frontend: GraphQLJSFrontend
  ) throws -> GraphQLSchema {
    let matches = try Glob(config.input.schemaSearchPaths, relativeTo: config.rootURL).match()

    guard !matches.isEmpty else {
      throw Error.cannotLoadSchema
    }

    let sources = try matches.map { try frontend.makeSource(from: URL(fileURLWithPath: $0)) }
    return try frontend.loadSchema(from: sources)
  }

  private static func createOperationsDocument(
    _ config: ConfigurationContext,
    _ frontend: GraphQLJSFrontend,
    _ experimentalFeatures: ApolloCodegenConfiguration.ExperimentalFeatures
  ) throws -> GraphQLDocument {
    let matches = try Glob(config.input.operationSearchPaths, relativeTo: config.rootURL).match()

    guard !matches.isEmpty else {
      throw Error.cannotLoadOperations
    }

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
          config: config
        ).generate(
          forConfig: config,
          fileManager: fileManager
        )
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

    if config.output.testMocks != .none {
      try MockUnionsFileGenerator(
        ir: ir,
        config: config
      )?.generate(
        forConfig: config,
        fileManager: fileManager
      )
      try MockInterfacesFileGenerator(
        ir: ir,
        config: config
      )?.generate(
        forConfig: config,
        fileManager: fileManager
      )
    }

    try SchemaMetadataFileGenerator(schema: ir.schema, config: config)
      .generate(forConfig: config, fileManager: fileManager)
    try SchemaConfigurationFileGenerator(schema: ir.schema, config: config)
      .generate(forConfig: config, fileManager: fileManager)

    try SchemaModuleFileGenerator.generate(config, fileManager: fileManager)
  }

  private static func findExistingGeneratedFilePaths(
    config: ConfigurationContext,
    fileManager: ApolloFileManager = .default
  ) throws -> Set<String> {
    var globs: [Glob] = []
    globs.append(Glob(
      ["\(config.output.schemaTypes.path)/**/*.graphql.swift"],
      relativeTo: config.rootURL
    ))

    switch config.output.operations {
    case .inSchemaModule: break

    case let .absolute(operationsPath):
      globs.append(Glob(
        ["\(operationsPath)/**/*.graphql.swift"],
        relativeTo: config.rootURL
      ))

    case let .relative(subpath):
      let searchPaths = config.input.operationSearchPaths.map { searchPath -> String in
        let startOfLastPathComponent = searchPath.lastIndex(of: "/") ?? searchPath.firstIndex(of: ".")!
        var path = searchPath.prefix(upTo: startOfLastPathComponent)
        if let subpath = subpath {
          path += "/\(subpath)"
        }
        path += "/*.graphql.swift"
        return path.description
      }

      globs.append(Glob(
        searchPaths,
        relativeTo: config.rootURL
      ))
    }

    switch config.output.testMocks {
    case let .absolute(testMocksPath):
      globs.append(Glob(
        ["\(testMocksPath)/**/*.graphql.swift"],
        relativeTo: config.rootURL
      ))
    default: break
    }

    return try globs.reduce(into: []) { partialResult, glob in
      partialResult.formUnion(try glob.match())
    }
  }

  static func deleteExtraneousGeneratedFiles(
    from oldGeneratedFilePaths: inout Set<String>,
    afterCodeGenerationUsing fileManager: ApolloFileManager
  ) throws {
    oldGeneratedFilePaths.subtract(fileManager.writtenFiles)
    for path in oldGeneratedFilePaths {
      try fileManager.deleteFile(atPath: path)
    }
  }

}

#endif

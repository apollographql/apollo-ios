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
      directoryPath: configuration.output.schemaTypes.path
    )

    let modulePath = configuration.output.schemaTypes.path
    try fileGenerators(for: ir.schema.referencedTypes.objects, directoryPath: modulePath)
      .forEach({ try $0.generateFile() })

    try fileGenerators(for: ir.schema.referencedTypes.interfaces, directoryPath: modulePath)
      .forEach({ try $0.generateFile() })
    try fileGenerators(
        for: ir.schema.referencedTypes.unions,
        moduleName: configuration.output.schemaTypes.moduleName,
        directoryPath: modulePath
      ).forEach({ try $0.generateFile() })
    try fileGenerators(for: ir.schema.referencedTypes.inputObjects, directoryPath: modulePath)
      .forEach({ try $0.generateFile() })
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
    directoryPath: String
  ) throws {
    for graphQLEnum in referencedTypes.enums {
      try autoreleasepool {
        try EnumFileGenerator.generate(graphQLEnum, directoryPath: directoryPath)
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

  static func fileGenerators(
    for objectTypes: OrderedSet<GraphQLObjectType>,
    directoryPath path: String
  ) -> [TypeFileGenerator] {
    return objectTypes.map({ graphqlObjectType in
      TypeFileGenerator(objectType: graphqlObjectType, directoryPath: path)
    })
  }

  static func fileGenerators(
    for interfaceTypes: OrderedSet<GraphQLInterfaceType>,
    directoryPath path: String
  ) -> [InterfaceFileGenerator] {
    return interfaceTypes.map({ graphqlInterfaceType in
      InterfaceFileGenerator(interfaceType: graphqlInterfaceType, directoryPath: path)
    })
  }

  static func fileGenerators(
    for unionTypes: OrderedSet<GraphQLUnionType>,
    moduleName: String,
    directoryPath path: String
  ) -> [UnionFileGenerator] {
    return unionTypes.map({ graphqlUnionType in
      UnionFileGenerator(unionType: graphqlUnionType, moduleName: moduleName, directoryPath: path)
    })
  }

  static func fileGenerators(
    for unionTypes: OrderedSet<GraphQLInputObjectType>,
    directoryPath path: String
  ) -> [InputObjectFileGenerator] {
    return unionTypes.map({ graphqlInputObjectType in
      InputObjectFileGenerator(inputObjectType: graphqlInputObjectType, directoryPath: path)
    })
  }
  
}

#endif

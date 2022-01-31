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

    let modulePath = configuration.output.schemaTypes.path
    try fileGenerators(for: ir.schema.referencedTypes.objects, directoryPath: modulePath)
      .forEach({ try $0.generateFile() })
    try fileGenerators(for: ir.schema.referencedTypes.enums, directoryPath: modulePath)
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

    for fragment in compilationResult.fragments {
      let irFragment = ir.build(fragment: fragment)
      try FragmentFileGenerator(
        fragment: irFragment,
        schema: ir.schema,
        config: configuration,
        directoryPath: modulePath
      ).generateFile()
    }

    for operation in compilationResult.operations {
      let irOperation = ir.build(operation: operation)
      try OperationFileGenerator(
        operation: irOperation,
        schema: ir.schema,
        config: configuration,
        directoryPath: modulePath
      ).generateFile()
    }

    try SchemaModuleFileGenerator(configuration.output.schemaTypes)
      .generateFile()
  }

  // MARK: Internal

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

  static func fileGenerators(
    for objectTypes: OrderedSet<GraphQLObjectType>,
    directoryPath path: String
  ) -> [TypeFileGenerator] {
    return objectTypes.map({ graphqlObjectType in
      TypeFileGenerator(objectType: graphqlObjectType, directoryPath: path)
    })
  }

  static func fileGenerators(
    for enumTypes: OrderedSet<GraphQLEnumType>,
    directoryPath path: String
  ) -> [EnumFileGenerator] {
    return enumTypes.map({ graphqlEnumType in
      EnumFileGenerator(enumType: graphqlEnumType, directoryPath: path)
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

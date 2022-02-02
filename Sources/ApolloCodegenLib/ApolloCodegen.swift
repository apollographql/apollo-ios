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
      schemaName: configuration.output.schemaTypes.moduleName,
      compilationResult: compilationResult
    )

    for graphQLObject in ir.schema.referencedTypes.objects {
      try autoreleasepool {
        try ObjectFileGenerator.generate(
          graphQLObject,
          directoryPath: configuration.output.schemaTypes.path
        )
      }
    }

    for graphQLEnum in ir.schema.referencedTypes.enums {
      try autoreleasepool {
        try EnumFileGenerator.generate(
          graphQLEnum,
          directoryPath: configuration.output.schemaTypes.path
        )
      }
    }

    for graphQLInterface in ir.schema.referencedTypes.interfaces {
      try autoreleasepool {
        try InterfaceFileGenerator.generate(
          graphQLInterface,
          directoryPath: configuration.output.schemaTypes.path
        )
      }
    }

    for graphQLUnion in ir.schema.referencedTypes.unions {
      try autoreleasepool {
        try UnionFileGenerator.generate(
          graphQLUnion,
          moduleName: configuration.output.schemaTypes.moduleName,
          directoryPath: configuration.output.schemaTypes.path
        )
      }
    }

    for graphQLInputObject in ir.schema.referencedTypes.inputObjects {
      try autoreleasepool {
        try InputObjectFileGenerator.generate(
          graphQLInputObject,
          directoryPath: configuration.output.schemaTypes.path
        )
      }
    }

    try SchemaFileGenerator.generate(
      ir.schema,
      directoryPath: configuration.output.schemaTypes.path
    )

    for fragment in compilationResult.fragments {
      try autoreleasepool {
        let irFragment = ir.build(fragment: fragment)
        try FragmentFileGenerator.generate(
          irFragment,
          schema: ir.schema,
          config: configuration.output,
          directoryPath: configuration.output.schemaTypes.path
        )
      }
    }

    for operation in compilationResult.operations {
      try autoreleasepool {
        let irOperation = ir.build(operation: operation)
        try OperationFileGenerator.generate(
          irOperation,
          schema: ir.schema,
          config: configuration,
          directoryPath: configuration.output.schemaTypes.path
        )
      }
    }

    try SchemaModuleFileGenerator.generate(configuration.output.schemaTypes
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
}

#endif

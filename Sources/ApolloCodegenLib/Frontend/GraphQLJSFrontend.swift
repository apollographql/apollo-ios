import Foundation
import JavaScriptCore

public final class GraphQLJSFrontend {
  private let bridge: JavaScriptBridge
  private let library: JavaScriptObject

  public init() throws {
    let bridge = try JavaScriptBridge()
    self.bridge = bridge

    try bridge.throwingJavaScriptErrorIfNeeded {
      bridge.context.evaluateScript(ApolloCodegenFrontendBundle)
    }

    self.library = bridge.fromJSValue(bridge.context.globalObject["ApolloCodegenFrontend"])

    bridge.register(GraphQLSource.self, forJavaScriptClass: "Source", from: library)
    bridge.register(GraphQLError.self, from: library)
    bridge.register(GraphQLSchemaValidationError.self, from: library)
    bridge.register(GraphQLSchema.self, from: library)
    bridge.register(GraphQLScalarType.self, from: library)
    bridge.register(GraphQLEnumType.self, from: library)
    bridge.register(GraphQLInputObjectType.self, from: library)
    bridge.register(GraphQLObjectType.self, from: library)
    bridge.register(GraphQLInterfaceType.self, from: library)
    bridge.register(GraphQLUnionType.self, from: library)
  }  

  /// Load a schema by parsing  an introspection result.
  public func loadSchema(from sources: [GraphQLSource]) throws -> GraphQLSchema {
    return try library.call("loadSchemaFromSources", with: sources)
  }

  /// Take a loaded GQL schema and print it as SDL.
  public func printSchemaAsSDL(schema: GraphQLSchema) throws -> String {
      return try library.call("printSchemaToSDL", with: schema)
    }

  private lazy var sourceConstructor: JavaScriptObject = {
    self.bridge.fromJSValue(library["Source"])
  }()

  /// Create a `GraphQLSource` object from a string.
  public func makeSource(_ body: String, filePath: String) throws -> GraphQLSource {
    return try sourceConstructor.construct(with: body, filePath)
  }

  /// Create a `GraphQLSource` object by reading from a file.
  public func makeSource(from fileURL: URL) throws -> GraphQLSource {
    precondition(fileURL.isFileURL)

    let body = try String(contentsOf: fileURL)
    return try makeSource(body, filePath: fileURL.path)
  }

  /// Parses a GraphQL document from a source, returning a reference to the parsed AST that can be passed on to validation and compilation.
  /// Syntax errors will result in throwing a `GraphQLError`.
  public func parseDocument(
    _ source: GraphQLSource,
    experimentalClientControlledNullability: Bool = false
  ) throws -> GraphQLDocument {
    return try library.call(
      "parseOperationDocument",
      with: source,
      experimentalClientControlledNullability
    )
  }

  /// Parses a GraphQL document from a file, returning a reference to the parsed AST that can be passed on to validation and compilation.
  /// Syntax errors will result in throwing a `GraphQLError`.
  public func parseDocument(
    from fileURL: URL,
    experimentalClientControlledNullability: Bool = false
  ) throws -> GraphQLDocument {
    return try parseDocument(
      try makeSource(from: fileURL),
      experimentalClientControlledNullability: experimentalClientControlledNullability
    )
  }

  /// Validation and compilation take a single document, but you can merge documents, and operations and fragments will remember their source.
  public func mergeDocuments(_ documents: [GraphQLDocument]) throws -> GraphQLDocument {
    return try library.call("mergeDocuments", with: documents)
  }

  /// Validate a GraphQL document and return any validation errors as `GraphQLError`s.
  public func validateDocument(
    schema: GraphQLSchema,
    document: GraphQLDocument,
    validationOptions: ValidationOptions
  ) throws -> [GraphQLError] {
    return try library.call(
      "validateDocument",
      with: schema,
      document,
      ValidationOptions.Bridged(from: validationOptions, bridge: self.bridge)
    )
  }

  /// Compiles a GraphQL document into an intermediate representation that is more suitable for analysis and code generation.
  public func compile(
    schema: GraphQLSchema,
    document: GraphQLDocument,
    experimentalLegacySafelistingCompatibleOperations: Bool = false
  ) throws -> CompilationResult {
    return try library.call(
      "compileDocument",
      with: schema, document, experimentalLegacySafelistingCompatibleOperations
    )
  }
}

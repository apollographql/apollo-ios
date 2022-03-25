import Foundation
import JavaScriptCore

public final class GraphQLJSFrontend {
#if SWIFT_PACKAGE
  private static let bundle = Bundle.module
  private static let libraryURL = bundle.url(forResource: "ApolloCodegenFrontend.bundle",
                                             withExtension: "js")!
#else
  private static let bundle = Bundle(for: GraphQLJSFrontend.self)
  private static let libraryURL = bundle.url(forResource: "ApolloCodegenFrontend.bundle",
                                             withExtension: "js",
                                             subdirectory: "dist")!
#endif

  private static let librarySource = try! String.init(contentsOf: libraryURL)

  private let bridge: JavaScriptBridge
  private let library: JavaScriptObject

  public init() throws {
    let bridge = try JavaScriptBridge()
    self.bridge = bridge

    try bridge.throwingJavaScriptErrorIfNeeded {
      bridge.context.evaluateScript(Self.librarySource, withSourceURL: Self.libraryURL)
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

  /// Load a schema by parsing either an introspection result or SDL based on the file extension.
  public func loadSchema(from fileURL: URL) throws -> GraphQLSchema {
    precondition(fileURL.isFileURL)

    if fileURL.pathExtension == "json" {
      let introspectionResult = try String(contentsOf: fileURL)
      return try loadSchemaFromIntrospectionResult(introspectionResult)
    } else {
      let source = try makeSource(from: fileURL)
      return try loadSchemaFromSDL(source)
    }
  }

  /// Load a schema by parsing  an introspection result.
  public func loadSchemaFromIntrospectionResult(_ introspectionResult: String) throws -> GraphQLSchema {
    return try library.call("loadSchemaFromIntrospectionResult", with: introspectionResult)
  }

  /// Load a schema by parsing SDL.
  public func loadSchemaFromSDL(_ source: GraphQLSource) throws -> GraphQLSchema {
    return try library.call("loadSchemaFromSDL", with: source)
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
      "parseDocument",
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
    return try library.call(
      "parseDocument",
      with: makeSource(from: fileURL),
      experimentalClientControlledNullability
    )
  }

  /// Validation and compilation take a single document, but you can merge documents, and operations and fragments will remember their source.
  public func mergeDocuments(_ documents: [GraphQLDocument]) throws -> GraphQLDocument {
    return try library.call("mergeDocuments", with: documents)
  }

  /// Validate a GraphQL document and return any validation errors as `GraphQLError`s.
  public func validateDocument(schema: GraphQLSchema, document: GraphQLDocument) throws -> [GraphQLError] {
    return try library.call("validateDocument", with: schema, document)
  }

  /// Compiles a GraphQL document into an intermediate representation that is more suitable for analysis and code generation.
  public func compile(schema: GraphQLSchema, document: GraphQLDocument) throws -> CompilationResult {
    return try library.call("compileDocument", with: schema, document)
  }
}

import Foundation
import JavaScriptCore

public final class ApolloCodegenFrontend {
  static let bundle = Bundle(for: ApolloCodegenFrontend.self)
  private static let libraryURL = bundle.url(forResource: "ApolloCodegenFrontend.bundle", withExtension: "js")!
  private static let librarySource = try! String.init(contentsOf: libraryURL)
  
  private let virtualMachine = JSVirtualMachine()
  private let context: JSContext
  private let bridge: JavaScriptBridge
  
  private let library: JavaScriptObject
  
  public init() throws {
    let context = JSContext(virtualMachine: virtualMachine)!
    self.context = context
    bridge = JavaScriptBridge(context: context)
    
    try bridge.throwingJavaScriptErrorIfNeeded {
      context.evaluateScript(Self.librarySource, withSourceURL: Self.libraryURL)
    }
    
    library = bridge.fromJSValue(context.globalObject["ApolloCodegenFrontend"])
    
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
  
  public func loadSchemaFromIntrospectionResult(_ introspectionResult: String) throws -> GraphQLSchema {
    return try library.call("loadSchemaFromIntrospectionResult", with: introspectionResult)
  }
  
  public func loadSchemaFromSDL(_ source: GraphQLSource) throws -> GraphQLSchema {
    return try library.call("loadSchemaFromSDL", with: source)
  }
  
  private lazy var sourceConstructor: JavaScriptObject = bridge.fromJSValue(library["Source"])
  
  public func makeSource(_ body: String, filePath: String) throws -> GraphQLSource {
    return try sourceConstructor.construct(with: body, filePath)
  }
  
  public func makeSource(from fileURL: URL) throws -> GraphQLSource {
    precondition(fileURL.isFileURL)
    
    let body = try String(contentsOf: fileURL)
    return try makeSource(body, filePath: fileURL.path)
  }
  
  public func parseDocument(_ source: GraphQLSource) throws -> GraphQLDocument {
    return try library.call("parseDocument", with: source)
  }
  
  public func mergeDocuments(_ documents: [GraphQLDocument]) throws -> GraphQLDocument {
    return try library.call("mergeDocuments", with: documents)
  }
  
  public func validateDocument(schema: GraphQLSchema, document: GraphQLDocument) throws -> [GraphQLError] {
    return try library.call("validateDocument", with: schema, document)
  }
  
  public func compile(schema: GraphQLSchema, document: GraphQLDocument) throws -> CompilationResult {
    return try library.call("compileDocument", with: schema, document)
  }
}

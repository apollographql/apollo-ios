import Foundation
@testable import ApolloCodegenLib

extension GraphQLJSFrontend {

  public func compile(
    schema: String,
    document: String,
    config: ApolloCodegen.ConfigurationContext
  ) throws -> CompilationResult {
    let schemaSource = try makeSource(schema, filePath: "")
    let documentSource = try makeSource(document, filePath: "")

    let schema = try loadSchema(from: [schemaSource])
    let document = try parseDocument(
      documentSource,
      experimentalClientControlledNullability: config.experimentalFeatures.clientControlledNullability
    )

    return try compile(
      schema: schema,
      document: document,
      validationOptions: ValidationOptions(config: config)
    )
  }

  public func compile(
    schema: String,
    document: String,
    enableCCN: Bool = false
  ) throws -> CompilationResult {
    let config = ApolloCodegen.ConfigurationContext(
      config: .mock(experimentalFeatures: .init(clientControlledNullability: enableCCN)))

    return try compile(
      schema: schema,
      document: document,
      config: config
    )
  }

  public func compile(
    schema: String,
    documents: [String],
    config: ApolloCodegen.ConfigurationContext
  ) throws -> CompilationResult {
    let schemaSource = try makeSource(schema, filePath: "")
    let schema = try loadSchema(from: [schemaSource])

    let documents: [GraphQLDocument] = try documents.enumerated().map {
      let source = try makeSource($0.element, filePath: "Doc_\($0.offset)")
      return try parseDocument(
        source,
        experimentalClientControlledNullability: config.experimentalFeatures.clientControlledNullability
      )
    }

    let mergedDocument = try mergeDocuments(documents)
    return try compile(
      schema: schema,
      document: mergedDocument,
      validationOptions: ValidationOptions(config: config)
    )
  }

  public func compile(
    schema: String,
    documents: [String],
    enableCCN: Bool = false
  ) throws -> CompilationResult {
    let config = ApolloCodegen.ConfigurationContext(
      config: .mock(experimentalFeatures: .init(clientControlledNullability: enableCCN)))

    return try compile(
      schema: schema,
      documents: documents,
      config: config
    )
  }

  public func compile(
    schemaJSON: String,
    document: String,
    config: ApolloCodegen.ConfigurationContext
  ) throws -> CompilationResult {    
    let documentSource = try makeSource(document, filePath: "")
    let schemaSource = try makeSource(schemaJSON, filePath: "schema.json")
    
    let schema = try loadSchema(from: [schemaSource])
    let document = try parseDocument(
      documentSource,
      experimentalClientControlledNullability: config.experimentalFeatures.clientControlledNullability)

    return try compile(
      schema: schema,
      document: document,
      validationOptions: ValidationOptions(config: config)
    )
  }

  public func compile(
    schemaJSON: String,
    document: String,
    enableCCN: Bool = false
  ) throws -> CompilationResult {
    let config = ApolloCodegen.ConfigurationContext(
      config: .mock(experimentalFeatures: .init(clientControlledNullability: enableCCN)))

    return try compile(
      schemaJSON: schemaJSON,
      document: document,
      config: config
    )
  }

}

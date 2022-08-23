import Foundation
import OrderedCollections

/// Generates a file containing schema metadata used by the GraphQL executor at runtime.
struct SchemaMetadataFileGenerator: FileGenerator {
  /// Source IR schema.
  let schema: IR.Schema
  /// Shared codegen configuration
  let config: ApolloCodegen.ConfigurationContext

  var template: TemplateRenderer { SchemaMetadataTemplate(schema: schema, config: config) }
  var target: FileTarget { .schema }
  var fileName: String { "SchemaMetadata.swift" }
}

import Foundation
import OrderedCollections
import ApolloUtils

/// Generates a file containing schema metadata used by the GraphQL executor at runtime.
struct SchemaFileGenerator: FileGenerator {
  /// Source IR schema.
  let schema: IR.Schema
  /// Shared codegen configuration
  let config: ApolloCodegen.ConfigurationContext

  var template: TemplateRenderer { SchemaTemplate(schema: schema, config: config) }
  var target: FileTarget { .schema }
  var fileName: String { "Schema.swift" }
}

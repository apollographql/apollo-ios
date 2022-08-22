import Foundation
import OrderedCollections

/// Generates a file containing schema metadata used by the GraphQL executor at runtime.
struct SchemaCacheKeyResolutionFileGenerator: FileGenerator {
  /// Source IR schema.
  let schema: IR.Schema
  /// Shared codegen configuration
  let config: ApolloCodegen.ConfigurationContext

  var template: TemplateRenderer { SchemaCacheKeyResolutionTemplate(schema: schema, config: config) }
  var overwrite: Bool { false }
  var target: FileTarget { .schema }
  var fileName: String { "Schema+CacheKeyResolution.swift" }
}

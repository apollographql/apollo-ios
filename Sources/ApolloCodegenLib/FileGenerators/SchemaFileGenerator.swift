import Foundation
import OrderedCollections

/// Generates a file containing schema metadata used by the GraphQL executor at runtime.
struct SchemaFileGenerator: FileGenerator {
  /// Source IR schema.
  let schema: IR.Schema

  var template: TemplateRenderer { SchemaTemplate(schema: schema) }
  var target: FileTarget { .schema }
  var fileName: String { "Schema.swift" }
}

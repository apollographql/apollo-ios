import Foundation

/// Renders the Cache Key Resolution extension for a generated schema.
struct SchemaConfigurationTemplate: TemplateRenderer {

  /// Source IR schema.
  let schema: IR.Schema
  /// Shared codegen configuration
  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .schemaFile(type: .schemaConfiguration)

  var headerTemplate: TemplateString? {
    HeaderCommentTemplate.editableFileHeader(
      fileCanBeEditedTo: """
      configure cache key resolution for objects in your schema.
      """
    )
  }

  var template: TemplateString {
    """
    public extension \(schema.name.firstUppercased).Schema {
      static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
        // Implement this function to configure cache key resolution for your schema types.
        return nil
      }
    }

    """
  }
}

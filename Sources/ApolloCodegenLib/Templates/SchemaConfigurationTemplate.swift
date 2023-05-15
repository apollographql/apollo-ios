import Foundation

/// Renders the Cache Key Resolution extension for a generated schema.
struct SchemaConfigurationTemplate: TemplateRenderer {
  /// Shared codegen configuration
  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .schemaFile(type: .schemaConfiguration)

  var headerTemplate: TemplateString? {
    HeaderCommentTemplate.editableFileHeader(
      fileCanBeEditedTo: """
      provide custom configuration for a generated GraphQL schema.
      """
    )
  }

  var template: TemplateString {
    return """
    \(accessControlModifier(for: .parent, in: target))enum SchemaConfiguration: \
    \(config.ApolloAPITargetName).SchemaConfiguration {
      \(accessControlModifier(for: .member, in: target))\
    static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
        // Implement this function to configure cache key resolution for your schema types.
        return nil
      }
    }

    """
  }
}

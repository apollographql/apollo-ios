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
    let accessLevel = embeddedAccessControlModifier(target: target)

    return """
    \(accessLevel)enum SchemaConfiguration: \
    \(config.ApolloAPITargetName).SchemaConfiguration {
      \(accessLevel)\
    static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
        // Implement this function to configure cache key resolution for your schema types.
        return nil
      }
    }

    """
  }
}

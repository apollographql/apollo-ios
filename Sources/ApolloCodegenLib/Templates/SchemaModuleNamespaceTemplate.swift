import Foundation

/// Provides the format to define a namespace that is used to wrap other templates to prevent
/// naming collisions in Swift code.
struct SchemaModuleNamespaceTemplate: TemplateRenderer {

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .moduleFile

  var template: TemplateString {
    TemplateString("""
    public enum \(config.schemaNamespace.firstUppercased) { }

    """)
  }
}

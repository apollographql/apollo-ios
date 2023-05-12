import Foundation

/// Provides the format to define a namespace that is used to wrap other templates to prevent
/// naming collisions in Swift code.
struct SchemaModuleNamespaceTemplate: TemplateRenderer {

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .moduleFile

  var template: TemplateString {
    TemplateString("""
    \(accessControlModifier(target: target, definition: .namespace))\
    enum \(config.schemaNamespace.firstUppercased) { }

    """)
  }
}

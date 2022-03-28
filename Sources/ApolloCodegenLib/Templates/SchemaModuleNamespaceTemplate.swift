import Foundation

struct SchemaModuleNamespaceTemplate: TemplateRenderer {
  let namespace: String

  var target: TemplateTarget { .moduleFile }

  var template: TemplateString {
    TemplateString("""
    public enum \(namespace) { }
    """)
  }
}

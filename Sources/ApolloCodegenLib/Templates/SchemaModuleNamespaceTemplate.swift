import Foundation

struct SchemaModuleNamespaceTemplate {
  let moduleName: String

  func render() -> String {
    TemplateString("""
    
    """).description
  }
}

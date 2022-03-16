import Foundation

struct SchemaModuleNamespaceTemplate {
  enum Definition {
    static func render(_ moduleName: String) -> String {
      TemplateString("""
      public enum \(moduleName) { }
      """).description
    }
  }

  }
}

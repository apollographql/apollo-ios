import OrderedCollections
import Foundation

struct SchemaTypeFieldsTemplate {

  static func render(fields: [GraphQLField], schemaName: String) -> TemplateString {
    return """
    \(fields.map {
      "@Field(\"\($0.name)\") public var \($0.name): \($0.type.rendered(containedInNonNull: true, inSchemaNamed: schemaName))?"
    }, separator: "\n")
    """
  }
  
}

import OrderedCollections
import Foundation
struct SchemaTypeFieldsTemplate {

  let ir: IR

  func render(type: FieldCollectable) -> TemplateString {
    guard let fields = fields(for: type) else { return "" }
    
    return """
    \(fields.map {
      "@Field(\"\($0.name)\") public var \($0.name): \($0.type.rendered(containedInNonNull: true, in: ir.schema))?"
    }, separator: "\n")
    """
  }

  private func fields(for type: FieldCollectable) -> [GraphQLField]? {
    ir.fieldCollector.collectedFields(for: type)?.sorted { $0.name < $1.name }
  }
  
}

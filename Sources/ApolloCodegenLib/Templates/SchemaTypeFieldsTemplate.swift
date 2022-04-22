import OrderedCollections
struct SchemaTypeFieldsTemplate {

  let ir: IR

  func render(type: GraphQLCompositeType) -> TemplateString {
    guard let fields = fields(for: type) else { return "" }
    
    return """
    \(fields.map {
      "@Field(\"\($0.name)\") public var \($0.name): \($0.type.rendered(containedInNonNull: true, in: ir.schema))?"
    }, separator: "\n")
    """
  }

  private func fields(for type: GraphQLCompositeType) -> [GraphQLField]? {
    guard let referencedFields = ir.fieldCollector.collectedFields(for: type) else {
      return nil
    }

    let schemaFields: [String: GraphQLField]

    switch type {
    case let objectType as GraphQLObjectType:
      schemaFields = objectType.fields

    case let interfaceType as GraphQLInterfaceType:
      schemaFields = interfaceType.fields

    default:
      return nil
    }

    var fieldsToRender: [GraphQLField] = []

    for fieldName in referencedFields {
      fieldsToRender.append(schemaFields[fieldName].unsafelyUnwrapped)
    }

    return fieldsToRender
  }
  
}

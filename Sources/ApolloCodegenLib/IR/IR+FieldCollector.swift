protocol FieldCollectable: GraphQLInterfaceImplementingType {
  var fields: [String: GraphQLField] { get }
}

extension GraphQLObjectType: FieldCollectable {}
extension GraphQLInterfaceType: FieldCollectable {}

extension IR {

  class FieldCollector {

    typealias ReferencedFields = Set<GraphQLField>

    private var collectedFields: [GraphQLCompositeType: ReferencedFields] = [:]

    func add<T: Sequence>(
      fields: T,
      to type: FieldCollectable
    ) where T.Element == CompilationResult.Field {
      for field in fields {
        add(field: field, to: type)
      }
    }

    func add(
      field: CompilationResult.Field,
      to type: FieldCollectable
    ) {
      add(fieldNamed: field.name, to: type)
    }

    private func add(
      fieldNamed name: String,
      to type: FieldCollectable
    ) {
      var fields = collectedFields[type] ?? []
      guard let field = type.fields[name] else { return }
      add(field, to: &fields)
      collectedFields.updateValue(fields, forKey: type)
    }

    private func add(
      _ field: GraphQLField,
      to referencedFields: inout ReferencedFields
    ) {
      referencedFields.insert(field)
    }

    func collectedFields(for type: FieldCollectable) -> ReferencedFields? {
      var fields = collectedFields[type] ?? []

      for interface in type.interfaces {
        if let interfaceFields = collectedFields[interface] {
          fields.formUnion(interfaceFields)
        }
      }

      return fields
    }
    
  }

}

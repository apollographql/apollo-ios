extension IR {

  class FieldCollector {

    typealias ReferencedFields = Set<String>

    private var collectedFields: [GraphQLCompositeType: ReferencedFields] = [:]

    func add<T: Sequence>(
      fields: T,
      to type: GraphQLCompositeType
    ) where T.Element == CompilationResult.Field {
      for field in fields {
        add(field: field, to: type)
      }
    }

    func add(
      field: CompilationResult.Field,
      to type: GraphQLCompositeType
    ) {
      add(fieldNamed: field.name, to: type)
    }

    private func add(
      fieldNamed name: String,
      to type: GraphQLCompositeType
    ) {
      var fields = collectedFields[type] ?? []
      add(fieldNamed: name, to: &fields)
      collectedFields.updateValue(fields, forKey: type)
    }

    private func add(
      fieldNamed name: String,
      to referencedFields: inout ReferencedFields
    ) {
      referencedFields.insert(name)
    }

    func collectedFields(for type: GraphQLCompositeType) -> ReferencedFields? {
      var fields = collectedFields[type] ?? []

      if let type = type as? GraphQLInterfaceImplementingType {
        for interface in type.interfaces {
          if let interfaceFields = collectedFields[interface] {
            fields.formUnion(interfaceFields)
          }
        }
      }

      return fields
    }
    
  }

}

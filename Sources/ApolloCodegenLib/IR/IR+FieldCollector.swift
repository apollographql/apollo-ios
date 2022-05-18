extension IR {

  class FieldCollector {

    private var collectedFields: [GraphQLCompositeType: [String: GraphQLType]] = [:]

    func add<T: Sequence>(
      fields: T,
      to type: GraphQLInterfaceImplementingType
    ) where T.Element == CompilationResult.Field {
      for field in fields {
        add(field: field, to: type)
      }
    }

    func add(
      field: CompilationResult.Field,
      to type: GraphQLInterfaceImplementingType
    ) {
      var fields = collectedFields[type] ?? [:]
      add(field, to: &fields)
      collectedFields.updateValue(fields, forKey: type)
    }

    private func add(
      _ field: CompilationResult.Field,
    to referencedFields: inout [String: GraphQLType]
    ) {
      let key = field.responseKey
      if !referencedFields.keys.contains(key) {
        referencedFields[key] = field.type
      }
    }

    func collectedFields(
      for type: GraphQLInterfaceImplementingType
    ) -> [(String, GraphQLType)] {
      var fields = collectedFields[type] ?? [:]

      for interface in type.interfaces {
        if let interfaceFields = collectedFields[interface] {
          fields.merge(interfaceFields) { field, _ in field }
        }
      }

      return fields.sorted { $0.0 < $1.0 }
    }


  }

}

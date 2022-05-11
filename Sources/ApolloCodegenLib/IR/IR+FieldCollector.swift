protocol FieldCollectable: GraphQLInterfaceImplementingType {
  var fields: [String: GraphQLField] { get }
}

extension GraphQLObjectType: FieldCollectable {}
extension GraphQLInterfaceType: FieldCollectable {}

extension IR {

  class FieldCollector {

    private var collectedFields: [GraphQLCompositeType: [FieldHashKey: GraphQLField]] = [:]

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
      var fields = collectedFields[type] ?? [:]
      guard let field = type.fields[name] else { return }
      add(field, to: &fields)
      collectedFields.updateValue(fields, forKey: type)
    }

    private func add(
      _ field: GraphQLField,
    to referencedFields: inout [FieldHashKey: GraphQLField]
    ) {
      let key = FieldHashKey(field)
      if !referencedFields.keys.contains(key) {
        referencedFields[key] = field
      }
    }

    func collectedFieldsWithCovariantFields(
      for type: GraphQLObjectType
    ) -> ([GraphQLField], covariantFields: Set<GraphQLField>) {
      var covariantFields: Set<GraphQLField> = []

      let fields = collectFields(for: type, handleMergedInterfaceFields: { field, interfaceField in
        if field.type != interfaceField.type {
          covariantFields.insert(field)
        }
      })

      return (fields, covariantFields)
    }

    func collectedFields(
      for type: FieldCollectable
    ) -> [GraphQLField] {
      collectFields(for: type, handleMergedInterfaceFields: nil)
    }

    private func collectFields(
      for type: FieldCollectable,
      handleMergedInterfaceFields: ((GraphQLField, GraphQLField) -> Void)?
    ) -> [GraphQLField] {
      var fields = collectedFields[type] ?? [:]

      for interface in type.interfaces {
        if let interfaceFields = collectedFields[interface] {
          fields.merge(interfaceFields) { field, interfaceField in
            handleMergedInterfaceFields?(field, interfaceField)
            return field
          }
        }
      }

      return fields.values.sorted { $0.name < $1.name }
    }

  }

  fileprivate struct FieldHashKey: Hashable {
    let hash: Int

    init(_ field: GraphQLField) {
      var hasher = Hasher()
      hasher.combine(field.name)
      hasher.combine(field.arguments)
      self.hash = hasher.finalize()
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(hash)
    }
  }

}

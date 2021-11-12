import Foundation

@dynamicMemberLookup
struct ASTField: Equatable {
  enum FieldType: Equatable {
    case scalar(GraphQLType)
    case entity(EntityFieldData)
  }

  struct EntityFieldData: Equatable {
    let type: GraphQLType
    let selectionSet: CompilationResult.SelectionSet
    let enclosingEntityMergedSelectionBuilder: MergedSelectionBuilder
  }

  let underlyingField: CompilationResult.Field
  let type: FieldType

  init(_ field: CompilationResult.Field,
       enclosingEntityMergedSelectionBuilder: MergedSelectionBuilder? = nil) {
    self.underlyingField = field
    self.type = FieldType(
      self.underlyingField,
      enclosingScopeMergedSelectionBuilder: enclosingEntityMergedSelectionBuilder
    )
  }

  subscript<V>(dynamicMember keyPath: KeyPath<CompilationResult.Field, V>) -> V {
    get {
      underlyingField[keyPath: keyPath]
    }
  }

  static func ==(lhs: ASTField, rhs: ASTField) -> Bool {
    lhs.underlyingField == rhs.underlyingField &&
    lhs.type == rhs.type
  }
}

extension ASTField.FieldType {
  init(_ field: CompilationResult.Field,
       enclosingScopeMergedSelectionBuilder: MergedSelectionBuilder?) {
    switch field.type.namedType {
    case is GraphQLScalarType, is GraphQLEnumType:
      self = .scalar(field.type)

    case is GraphQLCompositeType:
      guard let selectionSet = field.selectionSet else {
        fatalError("Invalid field: \(field). An object type field must contain a selection set.")
      }
      guard let enclosingScopeMergedSelectionBuilder = enclosingScopeMergedSelectionBuilder else {
        fatalError("enclosingScopeMergedSelectionBuilder must be provided for object type field.")
      }

      self = .entity(
        ASTField.EntityFieldData(
          type: field.type,
          selectionSet: selectionSet,
          enclosingEntityMergedSelectionBuilder: enclosingScopeMergedSelectionBuilder
        )
      )

    default:
      fatalError("Field \(field) must have a base type of scalar, enum, interface, union, or object. Got \(field.type.namedType)")
    }
  }
}

extension ASTField.EntityFieldData {
  static func == (lhs: ASTField.EntityFieldData, rhs: ASTField.EntityFieldData) -> Bool {
    lhs.selectionSet == rhs.selectionSet &&
    lhs.enclosingEntityMergedSelectionBuilder === rhs.enclosingEntityMergedSelectionBuilder
  }
}

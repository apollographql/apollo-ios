import Foundation

@dynamicMemberLookup
struct ASTField: Equatable {
  let underlyingField: CompilationResult.Field

  init(_ field: CompilationResult.Field) {
    self.underlyingField = field
  }

  subscript<V>(dynamicMember keyPath: KeyPath<CompilationResult.Field, V>) -> V {
    get {
      underlyingField[keyPath: keyPath]
    }
  }

  static func ==(lhs: ASTField, rhs: ASTField) -> Bool {
    lhs.underlyingField == rhs.underlyingField
  }
}

enum ASTFieldType: Equatable {
  case scalar(CompilationResult.Field)
  case entity(ASTField)

  init(_ field: CompilationResult.Field) {
    switch field.type.namedType {
    case is GraphQLScalarType,
      is GraphQLEnumType:
      self = .scalar(field)
    case is GraphQLCompositeType:
      self = .entity(ASTField(field))
    default:
      fatalError("Field \(field) must have a base type of scalar, enum, interface, union, or object. Got \(field.type.namedType)")
    }
  }

  var underlyingField: CompilationResult.Field {
    switch self {
    case let .scalar(field): return field
    case let .entity(astField): return astField.underlyingField
    }
  }
}

import Foundation

extension IR {

  @dynamicMemberLookup
  class Field: Equatable {
    let underlyingField: CompilationResult.Field

    fileprivate init(_ field: CompilationResult.Field) {
      self.underlyingField = field
    }

    subscript<V>(dynamicMember keyPath: KeyPath<CompilationResult.Field, V>) -> V {
      underlyingField[keyPath: keyPath]
    }

    static func ==(lhs: Field, rhs: Field) -> Bool {
      lhs.underlyingField == rhs.underlyingField
    }
  }

  final class ScalarField: Field {
    override init(_ field: CompilationResult.Field) {
      super.init(field)
    }
  }

  final class EntityField: Field {
    let selectionSet: SelectionSet

    init(_ field: CompilationResult.Field, selectionSet: SelectionSet) {
      self.selectionSet = selectionSet
      super.init(field)
    }

    static func ==(lhs: EntityField, rhs: EntityField) -> Bool {
      lhs.underlyingField == rhs.underlyingField &&
      lhs.selectionSet == rhs.selectionSet
    }
  }

}

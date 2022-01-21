import Foundation

extension IR {

  class Field: Equatable, CustomDebugStringConvertible {
    let underlyingField: CompilationResult.Field

    fileprivate init(_ field: CompilationResult.Field) {
      self.underlyingField = field
    }

    static func ==(lhs: Field, rhs: Field) -> Bool {
      lhs.underlyingField == rhs.underlyingField
    }

    var debugDescription: String {
      underlyingField.debugDescription
    }
  }

  final class ScalarField: Field {
    override init(_ field: CompilationResult.Field) {
      super.init(field)
    }
  }

  final class EntityField: Field {
    let selectionSet: SelectionSet
    var entity: Entity { selectionSet.typeInfo.entity }

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

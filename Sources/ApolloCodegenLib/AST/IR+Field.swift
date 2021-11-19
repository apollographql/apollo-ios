import Foundation

extension IR {

  @dynamicMemberLookup
  struct Field: Equatable {
    let underlyingField: CompilationResult.Field
    let selectionSet: SelectionSet?

    init(_ field: CompilationResult.Field, selectionSet: SelectionSet?) {
      self.underlyingField = field
      self.selectionSet = selectionSet
    }

    subscript<V>(dynamicMember keyPath: KeyPath<CompilationResult.Field, V>) -> V {
      underlyingField[keyPath: keyPath]
    }

    static func ==(lhs: Field, rhs: Field) -> Bool {
      lhs.underlyingField == rhs.underlyingField &&
      lhs.selectionSet == rhs.selectionSet
    }
  }

}

import Foundation

protocol SelectionMergable: ScopedSelectionSetHashable {
  var _selectionSet:CompilationResult.SelectionSet? { get }
  func merging(_: CompilationResult.SelectionSet) -> Self
}

extension CompilationResult.SelectionSet: SelectionMergable {

  var _selectionSet: CompilationResult.SelectionSet? { self }

  /// Returns a `Field` with the selections of the `newSelectionSet` merged in,
  /// removing duplicates.
  ///
  /// - Note: If no changes were made the same `SelectionSet` is returned.
  func merging(
    _ newSelectionSet: CompilationResult.SelectionSet
  ) -> Self {
    let selectionsToMerge = newSelectionSet.selections.filter { !selections.contains($0) }

    guard !selectionsToMerge.isEmpty else { return self }

    let copy = self.copy()
    copy.selections += selectionsToMerge
    return copy
  }

  private func copy() -> Self {
    return Self(parentType: self.parentType,
                selections: self.selections)
  }

}

extension CompilationResult.Field: SelectionMergable {

  var _selectionSet: CompilationResult.SelectionSet? { self.selectionSet }

  /// Returns a `Field` with the selections of the `newSelectionSet` merged in,
  /// removing duplicates.
  ///
  /// - Note: If no changes were made the same `Field` is returned.
  func merging(_ newSelectionSet: CompilationResult.SelectionSet) -> Self {
    guard let existingSelectionSet = selectionSet else {
      let copy = self.copy()
      copy.selectionSet = newSelectionSet
      return copy
    }

    let mergedSelectionSet = existingSelectionSet.merging(newSelectionSet)
    guard mergedSelectionSet !== existingSelectionSet else { return self }

    let copy = self.copy()
    copy.selectionSet = mergedSelectionSet
    return copy
  }

  private func copy() -> Self {
    return Self(
      name: self.name,
      alias: self.alias,
      arguments: self.arguments,
      type: self.type,
      selectionSet: self.selectionSet,
      deprecationReason: self.deprecationReason,
      description: self.description)
  }

}

extension IR.Field: SelectionMergable {
  var _selectionSet: CompilationResult.SelectionSet? {
    underlyingField.selectionSet
  }

  func merging(_ newSelectionSet: CompilationResult.SelectionSet) -> IR.Field {
    switch self.type {
    case .scalar:
      fatalError("Selection sets should never be merged into a scalar or enum type field.")

    case .entity:
      return IR.Field(self.underlyingField.merging(newSelectionSet))
    }
  }

}

extension CompilationResult.Selection: SelectionMergable {

  var _selectionSet: CompilationResult.SelectionSet? {
    switch self {
    case let .field(selection as SelectionMergable),
      let .inlineFragment(selection as SelectionMergable):
      return selection._selectionSet

    case let .fragmentSpread(fragment):
      return fragment.selectionSet
    }
  }

  func merging(_ newSelectionSet: CompilationResult.SelectionSet) -> Self {
    switch self {
    case let .field(field):
      return .field(field.merging(newSelectionSet))

    case let .inlineFragment(selectionSet):
      return .inlineFragment(selectionSet.merging(newSelectionSet))

    case .fragmentSpread:
      fatalError("Selections sets should never be merged into named fragments.")
    }
  }

}

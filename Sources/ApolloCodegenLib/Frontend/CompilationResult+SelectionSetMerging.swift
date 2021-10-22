import Foundation

extension CompilationResult.SelectionSet {

  /// Returns a `SelectionSet` with the `newSelections` merged in, removing duplicates.
  ///
  /// - Note: If no changes were made the same `SelectionSet` is returned.
  func merging(
    _ newSelections: [CompilationResult.Selection]
  ) -> CompilationResult.SelectionSet {
    let selectionsToMerge = newSelections.filter { !selections.contains($0) }

    guard !selectionsToMerge.isEmpty else { return self }

    let copy = self.copy()
    copy.selections += selectionsToMerge
    return copy
  }

  private func copy() -> CompilationResult.SelectionSet {
    return CompilationResult.SelectionSet(parentType: self.parentType,
                                          selections: self.selections)
  }

}

extension CompilationResult.Field {

  /// Returns a `Field` with the selections of the `newSelectionSet` merged in,
  /// removing duplicates.
  ///
  /// - Note: If no changes were made the same `Field` is returned.
  func merging(_ newSelectionSet: CompilationResult.SelectionSet) -> CompilationResult.Field {
    guard let existingSelectionSet = selectionSet else {
      let copy = self.copy()
      copy.selectionSet = newSelectionSet
      return copy
    }

    let mergedSelectionSet = existingSelectionSet.merging(newSelectionSet.selections)
    guard mergedSelectionSet !== existingSelectionSet else { return self }

    let copy = self.copy()
    copy.selectionSet = mergedSelectionSet
    return copy
  }

  private func copy() -> CompilationResult.Field {
    return CompilationResult.Field(
      name: self.name,
      alias: self.alias,
      arguments: self.arguments,
      type: self.type,
      selectionSet: self.selectionSet,
      deprecationReason: self.deprecationReason,
      description: self.description)
  }

}

extension CompilationResult.Selection {

  func merging(_ newSelectionSet: CompilationResult.SelectionSet) -> CompilationResult.Selection {
    switch self {
    case let .field(field):
      return .field(field.merging(newSelectionSet))

    case let .inlineFragment(selectionSet):
      return .inlineFragment(selectionSet.merging(newSelectionSet.selections))

    case .fragmentSpread:
      fatalError("Selections sets should never be merged into named fragments.")
    }
  }

}

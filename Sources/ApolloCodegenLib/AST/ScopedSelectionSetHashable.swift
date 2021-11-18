import Foundation

protocol ScopedSelectionSetHashable {

  /// A hash value that will be the same for any selections that should be merged in a given scope.
  /// This is not the same as equivalence. Rather objects with an equal `hashForSelectionSetScope`
  /// are considered to be equivalent only if they exist within the same "scope".
  ///
  /// A "scope" is a group of selection sets that all represent the same entity.
  /// A scope can include selections from a selection set along with any selections from it's
  /// parent, siblings, fragments spreads, or other selections sets on the same entity that match
  /// the selection set's parent type.
  var hashForSelectionSetScope: String { get }
}

extension CompilationResult.Selection: ScopedSelectionSetHashable {
  var hashForSelectionSetScope: String {
    switch self {
    case let .field(selection as ScopedSelectionSetHashable),
      let .inlineFragment(selection as ScopedSelectionSetHashable),
      let .fragmentSpread(selection as ScopedSelectionSetHashable):
      return selection.hashForSelectionSetScope
    }
  }
}

extension CompilationResult.Field: ScopedSelectionSetHashable {
  var hashForSelectionSetScope: String {
    return responseKey
  }
}

extension IR.Field: ScopedSelectionSetHashable {
  var hashForSelectionSetScope: String {
    underlyingField.hashForSelectionSetScope
  }
}

extension CompilationResult.SelectionSet: ScopedSelectionSetHashable {
  var hashForSelectionSetScope: String {
#warning("What if there is a field with the same name as a type? Do we get a conflict? Write a test for this.")
    return parentType.name
  }
}

extension CompilationResult.FragmentDefinition: ScopedSelectionSetHashable {
  var hashForSelectionSetScope: String {
    return name
  }
}

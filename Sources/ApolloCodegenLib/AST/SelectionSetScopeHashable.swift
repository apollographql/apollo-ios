import Foundation

protocol SelectionSetScopeHashable {

  /// A hash value that will be the same for any selections that should be merged in a given scope.
  /// This is not the same as equivalence.
  ///
  /// A "scope" can include selections from a selection set along with any selections from it's
  /// parent, siblings, fragments spreads, or other selections sets on the same entity that match
  /// the selection set's parent type.
  var hashForSelectionSetScope: AnyHashable { get }
}

extension CompilationResult.Selection: SelectionSetScopeHashable {
  var hashForSelectionSetScope: AnyHashable {
    switch self {
    case let .field(selection as SelectionSetScopeHashable),
      let .inlineFragment(selection as SelectionSetScopeHashable),
      let .fragmentSpread(selection as SelectionSetScopeHashable):
      return selection.hashForSelectionSetScope
    }
  }
}

extension CompilationResult.Field: SelectionSetScopeHashable {
  var hashForSelectionSetScope: AnyHashable {
    return responseKey
  }
}

extension CompilationResult.SelectionSet: SelectionSetScopeHashable {
  var hashForSelectionSetScope: AnyHashable {
    return parentType.name
  }
}

extension CompilationResult.FragmentSpread: SelectionSetScopeHashable {
  var hashForSelectionSetScope: AnyHashable {
    return fragment.hashForSelectionSetScope
  }
}

extension CompilationResult.FragmentDefinition: SelectionSetScopeHashable {
  var hashForSelectionSetScope: AnyHashable {
    return name
  }
}

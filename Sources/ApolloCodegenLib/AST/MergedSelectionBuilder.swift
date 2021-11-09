import Foundation
import OrderedCollections

/// An object that collects the selections for the type scopes for a tree of `ASTSelectionSet`s and
/// computes the merged selections for each `ASTSelectionSet` in the tree.
///
/// A single `MergedSelectionBuilder` should be shared between a parent `ASTSelectionSet` and all
/// of its children (all selection sets that represent the same entity).
///
/// Conversely, a `MergedSelectionBuilder` should **not** be shared with `ASTSelectionSet`s
/// representing a different entity. Each new root parent `ASTSelectionSet` should create a new
/// `MergedSelectionBuilder` for its child tree.
class MergedSelectionBuilder {
  private(set) var selectionsForScopes: OrderedDictionary<TypeScope, SortedSelections> = [:]
  private(set) var fieldSelectionMergedScopes: [String: MergedSelectionBuilder] = [:]

  func add(_ selections: SortedSelections, forScope typeScope: TypeScope) {
    if var existingSelections = selectionsForScopes[typeScope] {
      existingSelections.mergeIn(selections)
      selectionsForScopes[typeScope] = existingSelections

    } else {
      selectionsForScopes.updateValue(selections, forKey: typeScope, insertingAt: 0)
    }
  }

  func mergedSelections(for selectionSet: ASTSelectionSet) -> SortedSelections {
    let targetScope = selectionSet.scopeDescriptor
    var mergedSelections = selectionSet.selections
    for (scope, selections) in selectionsForScopes {
      if targetScope.matches(scope) {
        merge(selections, into: &mergedSelections)
      }
    }
    return mergedSelections
  }

  /// Does not merge in type cases, since we do not merge type cases across scopes.
  func merge(_ selections: SortedSelections, into mergedSelections: inout SortedSelections) {
    mergedSelections.mergeIn(selections.fields)
    for fragment in selections.fragments.values {
      mergedSelections.mergeIn(fragment)
      mergedSelections.mergeIn(fragment.selectionSet.selections)
    }
  }

}

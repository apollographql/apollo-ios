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

extension GraphQLCompositeType: ScopedSelectionSetHashable {
  var hashForSelectionSetScope: String {
    name
  }
}

extension IR.Field: ScopedSelectionSetHashable {
  var hashForSelectionSetScope: String {
    underlyingField.responseKey
  }
}

extension IR.FragmentSpread: ScopedSelectionSetHashable {
  var hashForSelectionSetScope: String {
    definition.name
  }
}

#warning("TODO: remove?")
//extension IR.InclusionCondition: ScopedSelectionSetHashable {
//  var hashForSelectionSetScope: String {
//    "\(isInverted ? "!" : "")$\(variable)"
//  }
//}
//
//extension IR.InclusionConditions: ScopedSelectionSetHashable {
//  var hashForSelectionSetScope: String {
//    hashValue
//  }
//
////  private static func hash(for group: OrderedSet<IR.InclusionCondition>) -> String {
////
////  }
//}
//
//extension IR.ScopeCondition: ScopedSelectionSetHashable {
//  var hashForSelectionSetScope: String {
//    switch {
//    case let .type(type): return type.hashForSelectionSetScope
//    case let .inclusion(condition): return condition.hashForSelectionSetScope
//    }
//  }
//}

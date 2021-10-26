import Foundation
import ApolloUtils
import OrderedCollections

class SelectionSetScope: CustomDebugStringConvertible, Equatable {
  typealias Selection = CompilationResult.Selection
  typealias SelectionSet = CompilationResult.SelectionSet
  typealias SelectionDictionary = OrderedDictionary<String, Selection>
  typealias ChildTypeCaseDictionary = OrderedDictionary<String, SelectionSetScope>

  let type: GraphQLCompositeType

  weak private(set) var parent: SelectionSetScope?

  private(set) var selections: SelectionDictionary = [:]

  private(set) var children: ChildTypeCaseDictionary = [:]

  lazy var mergedSelections: MergedSelections = MergedSelections.compute(forScope: self)

  /// All of the selections on the selection set that are fields. Does not traverse children.
  lazy var fieldSelections: [Selection] = {
    selections.compactMap {
      switch $0.value.self {
      case .field: return $0.value
      default: return nil
      }
    }
  }()

  // MARK: - Initialization

  convenience init(selectionSet: CompilationResult.SelectionSet, parent: SelectionSetScope?) {
    self.init(selections: selectionSet.selections,
              type: selectionSet.parentType,
              parent: parent)
  }

  init(selections: [Selection], type: GraphQLCompositeType, parent: SelectionSetScope?) {
    self.parent = parent
    self.type = type
    (self.selections, self.children) = computeSelectionsAndChildren(from: selections)
  }

  private func computeSelectionsAndChildren(
    from selections: [Selection]
  ) -> (SelectionDictionary, ChildTypeCaseDictionary) {
    var computedSelections: SelectionDictionary = [:]
    var computedChildSelectionSets: OrderedDictionary<String, SelectionSet> = [:]

    func appendOrMergeIntoSelections(_ selection: Selection) {
      let keyInScope = selection.hashForSelectionSetScope
      if let existingValue = computedSelections[keyInScope],
         let selectionSetToMerge = selection.selectionSet {
        computedSelections[keyInScope] = existingValue.merging(selectionSetToMerge)

      } else {
        computedSelections[keyInScope] = selection
      }
    }

    func appendOrMergeIntoChildren(_ selectionSet: SelectionSet) {
      let keyInScope = selectionSet.hashForSelectionSetScope
      if let existingValue = computedChildSelectionSets[keyInScope] {
        computedChildSelectionSets[keyInScope] = existingValue.merging(selectionSet.selections)

      } else {
        computedChildSelectionSets[keyInScope] = selectionSet
      }
    }

    for selection in selections {
      switch selection {
      case .field:
        appendOrMergeIntoSelections(selection)
        
      case let .inlineFragment(typeCaseSelectionSet):
        appendOrMergeIntoSelections(selection)
        appendOrMergeIntoChildren(typeCaseSelectionSet)

      case let .fragmentSpread(fragment):
        func shouldMergeFragmentDirectly() -> Bool {
          if fragment.type == type { return true }

          if let implementingType = type as? GraphQLInterfaceImplementingType,
             let fragmentInterface = fragment.type as? GraphQLInterfaceType,
             implementingType.implements(fragmentInterface) {
            return true
          }

          return false
        }

        if shouldMergeFragmentDirectly() {
          computedSelections[selection.hashForSelectionSetScope] = selection

        } else {
          let selectionSetEnclosingFragment = SelectionSet(
            parentType: fragment.type,
            selections: [selection]
          )
          let typeCaseForFragment = Selection.inlineFragment(selectionSetEnclosingFragment)

          appendOrMergeIntoSelections(typeCaseForFragment)
          appendOrMergeIntoChildren(selectionSetEnclosingFragment)
        }
      }
    }

    let computedChildren = computedChildSelectionSets.mapValues {
      SelectionSetScope(selections: $0.selections, type: $0.parentType, parent: self)
    }
    return (computedSelections, computedChildren)
  }

  static func == (lhs: SelectionSetScope, rhs: SelectionSetScope) -> Bool {
    return lhs.parent == rhs.parent &&
    lhs.type == rhs.type &&
    lhs.selections == rhs.selections
  }

  var debugDescription: String {
    var desc = type.debugDescription
    if !children.isEmpty {
      desc += " {"
      children.values.forEach { child in
        desc += "\n  \(indented: child.debugDescription)"
      }
      desc += "\n\(indented: "}")"
    }
    return desc
  }
}

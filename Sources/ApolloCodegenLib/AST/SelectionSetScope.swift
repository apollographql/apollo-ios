import Foundation
import ApolloUtils
import OrderedCollections

class SelectionSetScope: CustomDebugStringConvertible {
  typealias Selection = CompilationResult.Selection
  typealias Field = CompilationResult.Field

  let type: GraphQLCompositeType

  weak private(set) var parent: SelectionSetScope?

  private(set) var children: [SelectionSetScope] = []

  private(set) var selections: OrderedDictionary<AnyHashable, Selection> = [:]

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
  ) -> (OrderedDictionary<AnyHashable, Selection>, [SelectionSetScope]) {
    var computedSelections: OrderedDictionary<AnyHashable, Selection> = [:]
    var computedChildren: [SelectionSetScope] = []

    func appendOrMergeIntoSelections(_ selection: Selection) {
      let keyInScope = selection.hashForSelectionSetScope

      if let existingValue = computedSelections[keyInScope],
         let selectionSetToMerge = selection.selectionSet {
        computedSelections[keyInScope] = existingValue.merging(selectionSetToMerge)

      } else {
        computedSelections[keyInScope] = selection
      }
    }

    for selection in selections {
      switch selection {
      case .field:
        appendOrMergeIntoSelections(selection)
        
      case let .inlineFragment(selectionSet):
        appendOrMergeIntoSelections(selection)
        computedChildren.append(SelectionSetScope(selectionSet: selectionSet, parent: self))

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
          let typeCaseForFragment = Selection.inlineFragment(
            CompilationResult.SelectionSet(
              parentType: fragment.type,
              selections: [selection]
            ))
          appendOrMergeIntoSelections(typeCaseForFragment)          

          computedChildren.append(
            SelectionSetScope(
            selections: [.fragmentSpread(fragment)],
            type: fragment.type,
            parent: self))
        }
      }
    }
    return (computedSelections, computedChildren)
  }

  var debugDescription: String {
    var desc = type.debugDescription
    if !children.isEmpty {
      desc += " {"
      children.forEach { child in
        desc += "\n  \(indented: child.debugDescription)"
      }
      desc += "\n\(indented: "}")"
    }
    return desc
  }
}

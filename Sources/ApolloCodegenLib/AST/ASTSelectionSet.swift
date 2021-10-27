import Foundation
import ApolloUtils
import OrderedCollections

class ASTSelectionSet: CustomDebugStringConvertible, Equatable {
  typealias Selection = CompilationResult.Selection
  typealias SelectionSet = CompilationResult.SelectionSet
  typealias ChildTypeCaseDictionary = OrderedDictionary<String, ASTSelectionSet>

  let type: GraphQLCompositeType

  weak private(set) var parent: ASTSelectionSet?

  private(set) var selections: SortedSelections = SortedSelections()

  private(set) var children: ChildTypeCaseDictionary = [:]

  private(set) lazy var scopeDescriptor = TypeScopeDescriptor.descriptor(for: self)

  let selectionCollector: ScopeSelectionCollector

  lazy var mergedSelections: SortedSelections = selectionCollector.mergedSelections(for: self)

  // MARK: - Initialization

  convenience init(selectionSet: CompilationResult.SelectionSet, parent: ASTSelectionSet?) {
    self.init(selections: selectionSet.selections,
              type: selectionSet.parentType,
              parent: parent)
  }

  init(selections: [Selection], type: GraphQLCompositeType, parent: ASTSelectionSet?) {
    self.parent = parent
    self.type = type
    self.selectionCollector = parent?.selectionCollector ?? ScopeSelectionCollector()

    computeSelectionsAndChildren(from: selections)
//    if parent == nil {
//      MergedSelectionBuilder.buildMergedSelections(withRootScope: self)
//    }
  }

  private func computeSelectionsAndChildren(from selections: [Selection]) {
    var computedChildSelectionSets: OrderedDictionary<String, SelectionSet> = [:]

    func appendOrMergeIntoChildren(_ selectionSet: SelectionSet) {
      let keyInScope = selectionSet.hashForSelectionSetScope
      if let existingValue = computedChildSelectionSets[keyInScope] {
        computedChildSelectionSets[keyInScope] = existingValue.merging(selectionSet)

      } else {
        computedChildSelectionSets[keyInScope] = selectionSet
      }
    }

    for selection in selections {
      switch selection {
      case let .field(field):
        self.selections.mergeIn(field)
        
      case let .inlineFragment(typeCaseSelectionSet):
        self.selections.mergeIn(typeCase: typeCaseSelectionSet)
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
          self.selections.mergeIn(fragment)

        } else {
          let typeCaseForFragment = SelectionSet(
            parentType: fragment.type,
            selections: [selection]
          )

          self.selections.mergeIn(typeCase: typeCaseForFragment)
          appendOrMergeIntoChildren(typeCaseForFragment)
        }
      }
    }

    selectionCollector.add(self.selections, forScope: self.scopeDescriptor.scope)

    self.children = computedChildSelectionSets.mapValues {
      ASTSelectionSet(selections: $0.selections, type: $0.parentType, parent: self)
    }
  }

  static func == (lhs: ASTSelectionSet, rhs: ASTSelectionSet) -> Bool {
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

import Foundation
import OrderedCollections

class SelectionSetScope {
  typealias Selection = CompilationResult.Selection
  typealias Field = CompilationResult.Field

  weak var parent: SelectionSetScope?

  private(set) var children: [SelectionSetScope]? = nil

  let type: GraphQLCompositeType

  let selections: OrderedSet<Selection>

  init(selectionSet: CompilationResult.SelectionSet, parent: SelectionSetScope?) {
    self.parent = parent
    self.type = selectionSet.parentType

    self.selections = OrderedSet(selectionSet.selections)

    self.children = selectionSet.selections.compactMap {
      switch $0 {
      case let .inlineFragment(fragment):
        return SelectionSetScope(selectionSet: fragment.selectionSet, parent: self)
      default:
        return nil
      }
    }

//    self.children = all type case selections in selections array
  }

  /// All of the selections on the selection set that are fields. Does not traverse children.
  lazy var fieldSelections: [Selection] = {
    selections.compactMap {
      switch $0.self {
      case .field: return $0
      default: return nil
      }
    }
  }()

  lazy var mergedSelections: OrderedSet<Selection>? = {
    var selections = selections

    if let parent = parent {
      selections.append(contentsOf: parent.fieldSelections)

      if let siblings = parent.children {
        for sibling in siblings {
          if let siblingSelections = selectionsToMerge(from: sibling) {
            selections.append(contentsOf: siblingSelections)
          }
        }
      }
    }

    if let children = children {

    }
    return selections.isEmpty ? nil : selections
  }()

  private func selectionsToMerge(from other: SelectionSetScope) -> OrderedSet<Selection>? {
    guard other !== self else { return nil }
    
    switch (self.type, other.type) {
    case let (selfType as GraphQLObjectType, otherType as GraphQLObjectType)
      where selfType.name == otherType.name:
      return other.selections

    case let (selfType as GraphQLObjectType, otherType as GraphQLInterfaceType)
      where selfType.interfaces.contains { $0.name == otherType.name }:
      return other.selections
//
//    case let (selfType as GraphQLObjectType, otherType as GraphQLUnionType):
//      return otherType.types.contains { $0.name == selfType.name }
//
//
//    case let (selfType as GraphQLInterfaceType, otherType as GraphQLObjectType):
//      return otherType.interfaces.contains { $0.name == selfType.name }
//
//    case let (selfType as GraphQLInterfaceType, otherType as GraphQLInterfaceType):
//      return false
    default: return nil
    }
  }
}

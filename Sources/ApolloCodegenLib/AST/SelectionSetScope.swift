import Foundation
import OrderedCollections

class SelectionSetScope {
  typealias Selection = CompilationResult.Selection

  weak var parent: SelectionSetScope?

  let children: [SelectionSetScope]?

  let type: GraphQLCompositeType

  let selections: OrderedSet<Selection>?

  init(selectionSet: CompilationResult.SelectionSet, parent: SelectionSetScope?) {
    self.parent = parent
    self.type = selectionSet.parentType
    self.selections = OrderedSet(selectionSet.selections)
    self.children = []
//    self.children = all type case selections in selections array
  }

  lazy var mergedSelections: OrderedSet<Selection>? = { // lazy var?
    var selections: OrderedSet<Selection> = selections ?? []

    if let parent = parent {
      if let parentSelections = parent.selections {
        selections.append(contentsOf: parentSelections)
      }

      if let siblings = parent.children {
        for sibling in siblings {
          if sibling === self { continue }

        }
      }
    }

    if let children = children {

    }
    return selections.isEmpty ? nil : selections
  }()

  private func shouldMergeSelections(of otherType: GraphQLCompositeType) -> Bool {
    switch (self.type, otherType) {
    case let (selfType as GraphQLObjectType, otherType as GraphQLObjectType):
      return selfType.name == otherType.name

    case let (selfType as GraphQLObjectType, otherType as GraphQLInterfaceType):
      return selfType.interfaces.contains { $0.name == otherType.name }

    case let (selfType as GraphQLObjectType, otherType as GraphQLUnionType):
      return otherType.types.contains { $0.name == selfType.name }


    case let (selfType as GraphQLInterfaceType, otherType as GraphQLObjectType):
      return otherType.interfaces.contains { $0.name == selfType.name }

    case let (selfType as GraphQLInterfaceType, otherType as GraphQLInterfaceType):
      return false
    default: return false
    }
  }
}

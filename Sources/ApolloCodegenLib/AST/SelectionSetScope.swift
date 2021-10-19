import Foundation
import OrderedCollections

class SelectionSetScope {
  typealias Selection = CompilationResult.Selection
  typealias Field = CompilationResult.Field
  typealias TypeCase = CompilationResult.InlineFragment
  typealias Fragment = CompilationResult.FragmentDefinition

  struct MergedSelections {
    let fields: OrderedSet<Field>
    let typeCases: OrderedSet<TypeCase>
    let fragments: OrderedSet<Fragment>
  }

  weak var parent: SelectionSetScope?

  private(set) var children: [SelectionSetScope] = []

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

  #warning("TODO: Make this return sorted MergedSelections struct")
  lazy var mergedSelections: OrderedSet<Selection>? = {
    var selections = selections

    if let parentMergedSelections = selectionsToMerge(fromParent: parent) {
      selections.append(contentsOf: parentMergedSelections)
    }

    return selections.isEmpty ? nil : selections
  }()

  private func selectionsToMerge(fromParent parent: SelectionSetScope?) -> [Selection]? {
    guard let parent = parent else { return nil }
    var selections: [Selection] = parent.fieldSelections

    if let recursiveParentSelections = selectionsToMerge(fromParent: parent.parent) {
      selections = recursiveParentSelections + selections
    }

    for sibling in parent.children {
      selections.append(contentsOf: selectionsToMerge(fromSibling: sibling))
    }

    return selections
  }

  private func selectionsToMerge(fromSibling other: SelectionSetScope) -> [Selection] {
    guard other !== self else { return [] }
    
    switch (self.type, other.type) {
    case let (selfType as GraphQLObjectType, otherType as GraphQLObjectType)
      where selfType.name == otherType.name:
      return other.fieldSelections + other.children.flatMap { self.selectionsToMerge(fromSibling: $0) }

    case let (selfType as GraphQLObjectType, otherType as GraphQLInterfaceType)
      where selfType.interfaces.contains { $0.name == otherType.name }:
      return other.fieldSelections

    case (is GraphQLObjectType, is GraphQLUnionType):
      return other.children.flatMap { self.selectionsToMerge(fromSibling: $0) }
//
//
//    case let (selfType as GraphQLInterfaceType, otherType as GraphQLObjectType):
//      return otherType.interfaces.contains { $0.name == selfType.name }
//
    case let (selfType as GraphQLInterfaceType, otherType as GraphQLInterfaceType)
      where selfType.interfaces.contains { $0.name == otherType.name }:
      return other.fieldSelections

//    case let (selfType as GraphQLUnionType, otherType as GraphQLObjectType):
//      return other.children.flatMap { self.selectionsToMerge(from: $0) }

    default: return []
    }
  }
}

//fileprivate protocol SelectionMergeable: GraphQLCompositeType {
//  var shouldMergeFieldsOfType
//}



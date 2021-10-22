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
      case let .inlineFragment(selectionSet):
        appendOrMergeIntoSelections(selection)
        computedChildren.append(SelectionSetScope(selectionSet: selectionSet, parent: self))

      case let .fragmentSpread(fragment):
        func shouldMergeFragmentDirectly() -> Bool {
          if fragment.fragment.type == type { return true }

          if let implementingType = type as? GraphQLInterfaceImplementingType,
             let fragmentInterface = fragment.fragment.type as? GraphQLInterfaceType,
             implementingType.implements(fragmentInterface) {
            return true
          }

          return false
        }

        if shouldMergeFragmentDirectly() {
          computedSelections[selection.hashForSelectionSetScope] = selection

        } else {
          let typeCaseForFragment = Selection.inlineFragment(fragment.fragment.selectionSet)
          computedSelections[selection.hashForSelectionSetScope] = typeCaseForFragment

          computedChildren.append(
            SelectionSetScope(
            selections: [.fragmentSpread(fragment)],
            type: fragment.fragment.type,
            parent: self))
        }

      case .field:
        appendOrMergeIntoSelections(selection)
      }
    }
    return (computedSelections, computedChildren)
  }

  /// All of the selections on the selection set that are fields. Does not traverse children.
  lazy var fieldSelections: [Selection] = {
    selections.compactMap {
      switch $0.value.self {
      case .field: return $0.value
      default: return nil
      }
    }
  }()

  lazy var mergedSelections: MergedSelections = {
    var selections = MergedSelections(selections)

    if let parentMergedSelections = selectionsToMerge(fromParent: parent) {
      selections.mergeIn(parentMergedSelections)
    }

    return selections
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

struct MergedSelections: Equatable {
  typealias Selection = CompilationResult.Selection
  typealias Field = CompilationResult.Field
  typealias TypeCase = CompilationResult.SelectionSet
  typealias Fragment = CompilationResult.FragmentDefinition

  fileprivate(set) var fields: OrderedDictionary<AnyHashable, Field> = [:]
  fileprivate(set) var typeCases: OrderedDictionary<AnyHashable, TypeCase> = [:]
  fileprivate(set) var fragments: OrderedDictionary<AnyHashable, Fragment> = [:]

  init() {}

  init(
    fields: OrderedDictionary<AnyHashable, Field> = [:],
    typeCases: OrderedDictionary<AnyHashable, TypeCase> = [:],
    fragments: OrderedDictionary<AnyHashable, Fragment> = [:]
  ) {
    self.fields = fields
    self.typeCases = typeCases
    self.fragments = fragments
  }

  init(
    fields: [Field] = [],
    typeCases: [TypeCase] = [],
    fragments: [Fragment] = []
  ) {
    mergeIn(fields)
    mergeIn(typeCases)
    mergeIn(fragments)
  }

  init(_ selections: [CompilationResult.Selection]) {
    mergeIn(selections)
  }

  init(_ selections: OrderedDictionary<AnyHashable, Selection>) {
    mergeIn(selections.values.elements)
  }

  var isEmpty: Bool {
    fields.isEmpty && typeCases.isEmpty && fragments.isEmpty
  }

  // MARK: Selection Merging

  mutating func mergeIn(_ selections: [Selection]) {
    for selection in selections {
      switch selection {
      case let .field(field): mergeIn(field)

      case let .inlineFragment(fragment):
        typeCases[fragment.hashForSelectionSetScope] = fragment

      case let .fragmentSpread(fragment):
        fragments[fragment.hashForSelectionSetScope] = fragment.fragment
        mergeIn(fragment.fragment.selectionSet.selections)
      }
    }
  }

  mutating func mergeIn(_ field: Field) {
    fields[field.hashForSelectionSetScope] = field
  }

  mutating func mergeIn(_ fields: [Field]) {
    fields.forEach { mergeIn($0) }
  }

  mutating func mergeIn(_ typeCase: TypeCase) {
    typeCases[typeCase.hashForSelectionSetScope] = typeCase
  }

  mutating func mergeIn(_ typeCases: [TypeCase]) {
    typeCases.forEach { mergeIn($0) }
  }

  mutating func mergeIn(_ fragment: Fragment) {
    fragments[fragment.hashForSelectionSetScope] = fragment
  }

  mutating func mergeIn(_ fragments: [Fragment]) {
    fragments.forEach { mergeIn($0) }
  }

  static func ==(lhs: MergedSelections, rhs: MergedSelections) -> Bool {
    lhs.fields == rhs.fields &&
    lhs.typeCases == rhs.typeCases &&
    lhs.fragments == rhs.fragments
  }
}

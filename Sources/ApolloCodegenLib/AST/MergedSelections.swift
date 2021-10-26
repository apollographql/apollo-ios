import Foundation
import OrderedCollections

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
      case let .inlineFragment(fragment): mergeIn(fragment)
      case let .fragmentSpread(fragment): mergeIn(fragment)
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
    mergeIn(fragment.selectionSet.selections)
  }

  mutating func mergeIn(_ fragments: [Fragment]) {
    fragments.forEach { mergeIn($0) }
  }

  // MARK: Computation

  static func compute(forScope scope: SelectionSetScope) -> MergedSelections {
    var selections = MergedSelections(scope.selections)

    if let parentMergedSelections = selectionsToMerge(intoScope: scope, fromParent: scope.parent) {
      selections.mergeIn(parentMergedSelections)
    }

    return selections
  }

  private static func selectionsToMerge(
    intoScope scope: SelectionSetScope,
    fromParent parent: SelectionSetScope?
  ) -> [Selection]? {
    guard let parent = parent else { return nil }
    var selections: [Selection] = parent.fieldSelections

    if let recursiveParentSelections = selectionsToMerge(intoScope: scope,
                                                         fromParent: parent.parent) {
      selections = recursiveParentSelections + selections
    }

    for sibling in parent.children {
      selections.append(contentsOf: selectionsToMerge(intoScope: scope, fromSibling: sibling))
    }

    return selections
  }

  private static func selectionsToMerge(
    intoScope scope: SelectionSetScope,
    fromSibling other: SelectionSetScope
  ) -> [Selection] {
    guard other !== scope else { return [] }

    switch (scope.type, other.type) {
    case let (scopeType as GraphQLObjectType, otherType as GraphQLObjectType)
      where scopeType.name == otherType.name:
      return other.fieldSelections + other.children.flatMap {
        self.selectionsToMerge(intoScope: scope, fromSibling: $0)
      }

    case let (selfType as GraphQLObjectType, otherType as GraphQLInterfaceType)
      where selfType.interfaces.contains { $0.name == otherType.name }:
      return other.fieldSelections

    case (is GraphQLObjectType, is GraphQLUnionType):
      return other.children.flatMap {
        self.selectionsToMerge(intoScope: scope, fromSibling: $0)
      }
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

  // MARK: - Equatable Conformance

  static func ==(lhs: MergedSelections, rhs: MergedSelections) -> Bool {
    lhs.fields == rhs.fields &&
    lhs.typeCases == rhs.typeCases &&
    lhs.fragments == rhs.fragments
  }
}

import Foundation
import OrderedCollections
import ApolloAPI

typealias TypeScope = Set<GraphQLCompositeType>

struct TypeScopeDescriptor {
  let scope: TypeScope!

  private init() {
    self.scope = nil
  }

  private init(scope: TypeScope) {
    self.scope = scope
  }

  static func descriptor(for selectionSet: ASTSelectionSet) -> TypeScopeDescriptor {
    let allTypes = selectionSet.compilationResult.referencedTypes
    let parentDescriptor = selectionSet.parent?.scopeDescriptor ?? TypeScopeDescriptor()
    return parentDescriptor.appending(selectionSet.type, givenAllTypes: allTypes)
  }

  func matches(_ otherScope: TypeScope) -> Bool {
    otherScope.isSubset(of: self.scope)
  }

  func appending(
    _ newType: GraphQLCompositeType,
    givenAllTypes allTypes: CompilationResult.ReferencedTypes
  ) -> TypeScopeDescriptor {
    if let scope = scope, scope.contains(newType) { return self }

    var newScope = self.scope ?? []
    newScope.insert(newType)
    if let newType = newType as? GraphQLInterfaceImplementingType {
      newScope.formUnion(newType.interfaces)
      #warning("Do we need to recursively form union with each interfaces other interfaces? Test this.")
    }

    if let newType = newType as? GraphQLObjectType {
      newScope.formUnion(allTypes.unions(including: newType))
    }

    return TypeScopeDescriptor(scope: newScope)
  }
}

class ScopeSelectionCollector {
  var selectionsForScopes: [TypeScope: SortedSelections] = [:]

  init() {}

  func add(_ selections: SortedSelections, forScope typeScope: TypeScope) {
    if var selectionsForScope = selectionsForScopes[typeScope] {
      selectionsForScope.mergeIn(selections)
      selectionsForScopes[typeScope] = selectionsForScope

    } else {
      selectionsForScopes[typeScope] = selections
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

//    for otherScope in selectionSet.scopeDescriptor.otherMatchingScopes {
//      if let otherScopeSelections = selectionsForScopes[otherScope] {
//        merge(otherScopeSelections, into: &mergedSelections)
//      }
//    }

    return mergedSelections
  }

  /// Does not merge in type cases, since we do not merge type cases across scopes.
  func merge(_ selections: SortedSelections, into mergedSelections: inout SortedSelections) {
    mergedSelections.mergeIn(selections.fields)
    mergedSelections.mergeIn(selections.fragments)
  }

}

struct SortedSelections: Equatable, CustomDebugStringConvertible {
  typealias Selection = CompilationResult.Selection
  typealias Field = CompilationResult.Field
  typealias TypeCase = CompilationResult.SelectionSet
  typealias Fragment = CompilationResult.FragmentDefinition

  fileprivate(set) var fields: OrderedDictionary<String, Field> = [:]
  fileprivate(set) var typeCases: OrderedDictionary<String, TypeCase> = [:]
  fileprivate(set) var fragments: OrderedDictionary<String, Fragment> = [:]

  init() {}

  init(
    fields: OrderedDictionary<String, Field> = [:],
    typeCases: OrderedDictionary<String, TypeCase> = [:],
    fragments: OrderedDictionary<String, Fragment> = [:]
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
    mergeIn(typeCases: typeCases)
    mergeIn(fragments)
  }

  init(_ selections: [Selection]) {
    mergeIn(selections)
  }

  init(_ selections: OrderedDictionary<String, Selection>) {
    mergeIn(selections.values.elements)
  }

  var isEmpty: Bool {
    fields.isEmpty && typeCases.isEmpty && fragments.isEmpty
  }

  // MARK: Selection Merging

  @inlinable mutating func mergeIn(_ selections: SortedSelections) {
    mergeIn(selections.fields)
    mergeIn(typeCases: selections.typeCases)
    mergeIn(selections.fragments)
  }

  @inlinable mutating func mergeIn<T: Sequence>(_ selections: T) where T.Element == Selection {
    for selection in selections {
      mergeIn(selection)
    }
  }

  @inlinable mutating func mergeIn(_ selection: Selection) {
    switch selection {
    case let .field(field): mergeIn(field)
    case let .inlineFragment(typeCase): mergeIn(typeCase: typeCase)
    case let .fragmentSpread(fragment): mergeIn(fragment)
    }
  }

  @inlinable mutating func mergeIn(_ field: Field) {
    appendOrMerge(field, into: &fields)
  }

  @inlinable mutating func mergeIn<T: Sequence>(_ fields: T) where T.Element == Field {
    fields.forEach { mergeIn($0) }
  }

  @inlinable mutating func mergeIn(_ fields: OrderedDictionary<String, Field>) {
    mergeIn(fields.values)
  }

  @inlinable mutating func mergeIn(typeCase: TypeCase) {
    appendOrMerge(typeCase, into: &typeCases)
  }

  @inlinable mutating func mergeIn<T: Sequence>(typeCases: T) where T.Element == TypeCase {
    typeCases.forEach { mergeIn(typeCase: $0) }
  }

  @inlinable mutating func mergeIn(typeCases: OrderedDictionary<String, TypeCase>) {
    mergeIn(typeCases: typeCases.values)
  }

  @inlinable mutating func mergeIn(_ fragment: Fragment) {
    fragments[fragment.hashForSelectionSetScope] = fragment
//    mergeIn(fragment.selectionSet.selections)
  }

  @inlinable mutating func mergeIn<T: Sequence>(_ fragments: T) where T.Element == Fragment {
    fragments.forEach { mergeIn($0) }
  }

  @inlinable mutating func mergeIn(_ fragments: OrderedDictionary<String, Fragment>) {
    mergeIn(fragments.values)
  }

  private func appendOrMerge<T: SelectionMergable>(
    _ selection: T,
    into dict: inout OrderedDictionary<String, T>
  ) {
    let keyInScope = selection.hashForSelectionSetScope
    if let existingValue = dict[keyInScope] {
       if let selectionSetToMerge = selection._selectionSet {
         dict[keyInScope] = existingValue.merging(selectionSetToMerge)
       }
    } else {
      dict[keyInScope] = selection
    }
  }

  // MARK: Computation

//  static func compute(forScope scope: ASTSelectionSet) -> SortedSelections {
//    let selections = SortedSelections(scope.selections)
//
//    if let parentMergedSelections = selectionsToMerge(intoScope: scope, fromParent: scope.parent) {
//      selections.mergeIn(parentMergedSelections)
//    }
//
//    return selections
//  }
//
//  private static func selectionsToMerge(
//    intoScope scope: ASTSelectionSet,
//    fromParent parent: ASTSelectionSet?
//  ) -> [Selection]? {
//    guard let parent = parent else { return nil }
//    var selections: [Selection] = parent.fieldSelections
//
//    if let recursiveParentSelections = selectionsToMerge(intoScope: scope,
//                                                         fromParent: parent.parent) {
//      selections = recursiveParentSelections + selections
//    }
//
//    for sibling in parent.children.values {
//      selections.append(contentsOf: selectionsToMerge(intoScope: scope, fromSibling: sibling))
//    }
//
//    return selections
//  }
//
//  private static func selectionsToMerge(
//    intoScope scope: ASTSelectionSet,
//    fromSibling other: ASTSelectionSet
//  ) -> [Selection] {
//    guard other !== scope else { return [] }
//
//    switch (scope.type, other.type) {
//    case let (scopeType as GraphQLObjectType, otherType as GraphQLObjectType)
//      where scopeType.name == otherType.name:
//      return other.fieldSelections + other.children.values.flatMap {
//        self.selectionsToMerge(intoScope: scope, fromSibling: $0)
//      }
//
//    case let (selfType as GraphQLObjectType, otherType as GraphQLInterfaceType)
//      where selfType.interfaces.contains { $0.name == otherType.name }:
//      return other.fieldSelections
//
//    case (is GraphQLObjectType, is GraphQLUnionType):
//      return other.children.values.flatMap {
//        self.selectionsToMerge(intoScope: scope, fromSibling: $0)
//      }
////
////
////    case let (selfType as GraphQLInterfaceType, otherType as GraphQLObjectType):
////      return otherType.interfaces.contains { $0.name == selfType.name }
////
//    case let (selfType as GraphQLInterfaceType, otherType as GraphQLInterfaceType)
//      where selfType.interfaces.contains { $0.name == otherType.name }:
//      return other.fieldSelections
//
////    case let (selfType as GraphQLUnionType, otherType as GraphQLObjectType):
////      return other.children.flatMap { self.selectionsToMerge(from: $0) }
//
//    default: return []
//    }
//  }

  // MARK: - Equatable Conformance

  static func ==(lhs: SortedSelections, rhs: SortedSelections) -> Bool {
    lhs.fields == rhs.fields &&
    lhs.typeCases == rhs.typeCases &&
    lhs.fragments == rhs.fragments
  }

  var debugDescription: String {
    "Fields: \(fields.values.elements) \n TypeCases: \(typeCases.values.elements) \n Fragments: \(fragments.values.elements)"
  }
}

//class MergedSelectionBuilder {
//  class Scope {
////    let type: GraphQLCompositeType
//    let selectionSetScope: ASTSelectionSet
//    let mergedSelections: MergedSelections
//    var childScopes: [GraphQLCompositeType: Scope] = [:]
//
//    init(selectionSetScope: ASTSelectionSet) {
//      self.selectionSetScope = selectionSetScope
//      self.mergedSelections = MergedSelections(selectionSetScope.selections)
//      selectionSetScope.mergedSelections = self.mergedSelections
//    }
//
//    func childScope(for selectionSetScope: ASTSelectionSet) -> Scope {
//      return self.childScopes[selectionSetScope.type] ?? {
//        let childScope = Scope(selectionSetScope: selectionSetScope)
//        childScope.mergedSelections.mergeIn(self.selectionSetScope.fieldSelections)
//        self.childScopes[selectionSetScope.type] = childScope
//        return childScope
//      }()
//    }
//  }
//
//  var rootScope: Scope!
//
//  private init(root: ASTSelectionSet) {
//    self.rootScope = Scope(selectionSetScope: root)
//  }
//
//  static func buildMergedSelections(withRootScope root: ASTSelectionSet) {
//    guard root.parent == nil else {
//      fatalError("MergedSelectionBuilder can only be initialized with a root scope.")
//    }
//
//    let builder = MergedSelectionBuilder(root: root)
//
//    for child in root.children.values {
//      _ = builder.createMergedSelections(for: child, in: builder.rootScope)
//    }
//  }
//
//  func createMergedSelections(for child: ASTSelectionSet, in currentScope: Scope) -> Scope {
//    let scope = currentScope.childScope(for: child)
//
//    if let childType = child.type as? GraphQLInterfaceImplementingType {
//      for interface in childType.interfaces {
//        if let matchingScope = currentScope.childScopes[interface] {
//          scope.mergedSelections.mergeIn(matchingScope.selectionSetScope.selections.values)
//        }
//      }
//    }
//
//    return scope
//  }
//}

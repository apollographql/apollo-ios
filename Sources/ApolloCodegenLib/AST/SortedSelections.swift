import Foundation
import OrderedCollections

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

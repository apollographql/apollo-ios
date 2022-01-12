import Foundation
import OrderedCollections

protocol SelectionCollection: CustomDebugStringConvertible {
  typealias Field = IR.Field
  typealias TypeCase = IR.SelectionSet
  typealias Fragment = IR.FragmentSpread

  var fields: OrderedDictionary<String, Field> { get }
  var typeCases: OrderedDictionary<String, TypeCase> { get }
  var fragments: OrderedDictionary<String, Fragment> { get }

  init()

  mutating func mergeIn(_ field: Field)
  mutating func mergeIn(_ typeCase: TypeCase)
  mutating func mergeIn(_ fragment: Fragment)
}

extension SelectionCollection {

  init(
    fields: [Field] = [],
    typeCases: [TypeCase] = [],
    fragments: [Fragment] = []
  ) {
    self.init()
    mergeIn(fields)
    mergeIn(typeCases)
    mergeIn(fragments)
  }

  init(
    fields: OrderedDictionary<String, Field> = [:],
    typeCases: OrderedDictionary<String, TypeCase> = [:],
    fragments: OrderedDictionary<String, Fragment> = [:]
  ) {
    self.init()
    mergeIn(fields)
    mergeIn(typeCases)
    mergeIn(fragments)
  }

  var isEmpty: Bool {
    fields.isEmpty && typeCases.isEmpty && fragments.isEmpty
  }

  mutating func mergeIn(
    _ selections: SelectionCollection,
    mergeFields: Bool = true,
    mergeTypeCases: Bool = true,
    mergeFragments: Bool = true
  ) {
    if mergeFields { mergeIn(selections.fields) }
    if mergeTypeCases { mergeIn(selections.typeCases) }
    if mergeFragments { mergeIn(selections.fragments) }
  }

  mutating func mergeIn<T: Sequence>(_ fields: T) where T.Element == Field {
    fields.forEach { mergeIn($0) }
  }

  mutating func mergeIn(_ fields: OrderedDictionary<String, Field>) {
    mergeIn(fields.values)
  }

  mutating func mergeIn<T: Sequence>(_ typeCases: T) where T.Element == TypeCase {
    typeCases.forEach { mergeIn($0) }
  }

  mutating func mergeIn(_ typeCases: OrderedDictionary<String, TypeCase>) {
    mergeIn(typeCases.values)
  }

  mutating func mergeIn<T: Sequence>(_ fragments: T) where T.Element == Fragment {
    fragments.forEach { mergeIn($0) }
  }

  mutating func mergeIn(_ fragments: OrderedDictionary<String, Fragment>) {
    mergeIn(fragments.values)
  }

  // MARK: - Equatable Conformance

  static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.fields == rhs.fields &&
    lhs.typeCases == rhs.typeCases &&
    lhs.fragments == rhs.fragments
  }

  var debugDescription: String {
    """
    Fields: \(fields.values.elements)
    TypeCases: \(typeCases.values.elements.map(\.parentType))
    Fragments: \(fragments.values.elements.map(\.definition.name))
    """
  }
}

extension IR {
  struct SortedSelections: SelectionCollection, Equatable {
    fileprivate(set) var fields: OrderedDictionary<String, Field> = [:]
    fileprivate(set) var typeCases: OrderedDictionary<String, TypeCase> = [:]
    fileprivate(set) var fragments: OrderedDictionary<String, Fragment> = [:]

    // MARK: Merge In - Field

    mutating func mergeIn(_ field: Field) {
      let keyInScope = field.hashForSelectionSetScope
 
      if let existingField = fields[keyInScope] as? EntityField {
        if let field = field as? EntityField {
          existingField.selectionSet.selections.mergeIn(field.selectionSet.selections)
        }

      } else {
        fields[keyInScope] = field
      }
    }

    // MARK: Merge In - TypeCase

    mutating func mergeIn(_ typeCase: TypeCase) {
      let keyInScope = typeCase.hashForSelectionSetScope

      if let existingTypeCase = typeCases[keyInScope] {
        existingTypeCase.selections.mergeIn(typeCase.selections)

      } else {
        typeCases[keyInScope] = typeCase
      }
    }

    // MARK: Merge In - Fragment

    mutating func mergeIn(_ fragment: Fragment) {
      fragments[fragment.hashForSelectionSetScope] = fragment
    }
  }

}

import Foundation
import OrderedCollections
import ApolloUtils

extension IR {
  class SortedSelections: Equatable, CustomDebugStringConvertible {

    typealias Field = IR.Field
    typealias TypeCase = IR.SelectionSet
    typealias Fragment = IR.FragmentSpread

    fileprivate(set) var fields: OrderedDictionary<String, Field> = [:]
    fileprivate(set) var typeCases: OrderedDictionary<String, TypeCase> = [:]
    fileprivate(set) var fragments: OrderedDictionary<String, Fragment> = [:]

    init() {}

    init(
      fields: [Field] = [],
      typeCases: [TypeCase] = [],
      fragments: [Fragment] = []
    ) {
      mergeIn(fields)
      mergeIn(typeCases)
      mergeIn(fragments)
    }

    init(
      fields: OrderedDictionary<String, Field> = [:],
      typeCases: OrderedDictionary<String, TypeCase> = [:],
      fragments: OrderedDictionary<String, Fragment> = [:]
    ) {
      mergeIn(fields.values)
      mergeIn(typeCases.values)
      mergeIn(fragments.values)
    }

    var isEmpty: Bool {
      fields.isEmpty && typeCases.isEmpty && fragments.isEmpty
    }

    // MARK: Merge In

    func mergeIn(_ field: IR.Field) {
      let keyInScope = field.hashForSelectionSetScope

      if let existingField = fields[keyInScope] as? EntityField {
        if let field = field as? EntityField {
          existingField.selectionSet.directSelections!.mergeIn(field.selectionSet.directSelections!)
        }

      } else {
        fields[keyInScope] = field
      }
    }

    func mergeIn<T: Sequence>(_ fields: T) where T.Element == Field {
      fields.forEach { mergeIn($0) }
    }

    func mergeIn(_ typeCase: TypeCase) {
      let keyInScope = typeCase.hashForSelectionSetScope

      if let existingTypeCase = typeCases[keyInScope] {
        existingTypeCase.directSelections!.mergeIn(typeCase.directSelections!)

      } else {
        typeCases[keyInScope] = typeCase
      }
    }

    func mergeIn<T: Sequence>(_ typeCases: T) where T.Element == TypeCase {
      typeCases.forEach { mergeIn($0) }
    }

    func mergeIn(_ fragment: Fragment) {
      fragments[fragment.hashForSelectionSetScope] = fragment
    }

    func mergeIn<T: Sequence>(_ fragments: T) where T.Element == Fragment {
      fragments.forEach { mergeIn($0) }
    }

    func mergeIn(_ selections: SortedSelections) {
      mergeIn(selections.fields.values)
      mergeIn(selections.typeCases.values)
      mergeIn(selections.fragments.values)
    }

    static func == (lhs: IR.SortedSelections, rhs: IR.SortedSelections) -> Bool {
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

}

extension IR {
  struct ShallowSelections: Equatable, CustomDebugStringConvertible
  {
    typealias Field = IR.Field    
    typealias Fragment = IR.FragmentSpread

    fileprivate(set) var fields: OrderedDictionary<String, Field> = [:]
    fileprivate(set) var fragments: OrderedDictionary<String, Fragment> = [:]

    init() {}

    var isEmpty: Bool {
      fields.isEmpty && fragments.isEmpty
    }

    mutating func mergeIn(_ field: Field) {
      let keyInScope = field.hashForSelectionSetScope
      fields[keyInScope] = field
    }

    mutating func mergeIn<T: Sequence>(_ fields: T) where T.Element == Field {
      fields.forEach { mergeIn($0) }
    }

    mutating func mergeIn(_ fragment: Fragment) {
      fragments[fragment.hashForSelectionSetScope] = fragment
    }

    mutating func mergeIn<T: Sequence>(_ fragments: T) where T.Element == Fragment {
      fragments.forEach { mergeIn($0) }
    }

    mutating func mergeIn(_ selections: SortedSelections) {
      mergeIn(selections.fields.values)
      mergeIn(selections.fragments.values)
    }

    var debugDescription: String {
      """
      Fields: \(fields.values.elements)
      Fragments: \(fragments.values.elements.map(\.definition.name))
      """
    }
  }

}

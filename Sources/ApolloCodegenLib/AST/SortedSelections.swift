import Foundation
import OrderedCollections

extension IR {
#warning("TODO: copy on write!!!")
  struct SortedSelections: Equatable, CustomDebugStringConvertible {
    typealias Field = IR.Field
    typealias TypeCase = IR.SelectionSet
    typealias Fragment = IR.FragmentSpread

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
      mergeIn(typeCases)
      mergeIn(fragments)
    }

    var isEmpty: Bool {
      fields.isEmpty && typeCases.isEmpty && fragments.isEmpty
    }

    // MARK: Selection Merging

    mutating func mergeIn(
      _ selections: SortedSelections,
      mergeFields: Bool = true,
      mergeTypeCases: Bool = true,
      mergeFragments: Bool = true
    ) {
      if mergeFields { mergeIn(selections.fields) }
      if mergeTypeCases { mergeIn(selections.typeCases) }
      if mergeFragments { mergeIn(selections.fragments) }
    }

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

    mutating func mergeIn<T: Sequence>(_ fields: T) where T.Element == Field {
      fields.forEach { mergeIn($0) }
    }

    mutating func mergeIn(_ fields: OrderedDictionary<String, Field>) {
      mergeIn(fields.values)
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

    mutating func mergeIn<T: Sequence>(_ typeCases: T) where T.Element == TypeCase {
      typeCases.forEach { mergeIn($0) }
    }

    mutating func mergeIn(_ typeCases: OrderedDictionary<String, TypeCase>) {
      mergeIn(typeCases.values)
    }

    // MARK: Merge In - Fragment

    mutating func mergeIn(_ fragment: Fragment) {
      fragments[fragment.hashForSelectionSetScope] = fragment
    }

    mutating func mergeIn<T: Sequence>(_ fragments: T) where T.Element == Fragment {
      fragments.forEach { mergeIn($0) }
    }

    mutating func mergeIn(_ fragments: OrderedDictionary<String, Fragment>) {
      mergeIn(fragments.values)
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

}

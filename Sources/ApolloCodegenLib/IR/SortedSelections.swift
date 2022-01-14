import Foundation
import OrderedCollections
import ApolloUtils

protocol FieldMergable {
  typealias Field = IR.Field

  mutating func mergeIn(_ field: Field)
}

extension FieldMergable {
  mutating func mergeIn<T: Sequence>(_ fields: T) where T.Element == Field {
    fields.forEach { mergeIn($0) }
  }

  mutating func mergeIn(_ fields: OrderedDictionary<String, Field>) {
    mergeIn(fields.values)
  }
}

protocol TypeCaseMergable {
  typealias TypeCase = IR.SelectionSet

  mutating func mergeIn(_ typeCase: TypeCase)
}

extension TypeCaseMergable {
  mutating func mergeIn<T: Sequence>(_ typeCases: T) where T.Element == TypeCase {
    typeCases.forEach { mergeIn($0) }
  }

  mutating func mergeIn(_ typeCases: OrderedDictionary<String, TypeCase>) {
    mergeIn(typeCases.values)
  }
}

protocol FragmentMergable {
  typealias Fragment = IR.FragmentSpread

  mutating func mergeIn(_ fragment: Fragment)
}

extension FragmentMergable {
  mutating func mergeIn<T: Sequence>(_ fragments: T) where T.Element == Fragment {
    fragments.forEach { mergeIn($0) }
  }

  mutating func mergeIn(_ fragments: OrderedDictionary<String, Fragment>) {
    mergeIn(fragments.values)
  }
}

protocol SelectionMergable: FieldMergable, TypeCaseMergable, FragmentMergable {
  var fields: OrderedDictionary<String, Field> { get }
  var typeCases: OrderedDictionary<String, TypeCase> { get }
  var fragments: OrderedDictionary<String, Fragment> { get }
}

extension IR {
  struct SortedSelections: SelectionMergable, Equatable, CustomDebugStringConvertible {
    fileprivate(set) var fields: OrderedDictionary<String, Field> = [:]
    fileprivate(set) var typeCases: OrderedDictionary<String, TypeCase> = [:]
    fileprivate(set) var fragments: OrderedDictionary<String, Fragment> = [:]

    init() {}

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

    // MARK: Merge In

    mutating func mergeIn(_ field: Field) {
      let keyInScope = field.hashForSelectionSetScope
 
      if let existingField = fields[keyInScope] as? EntityField {
        if let field = field as? EntityField {
          existingField.selectionSet.directSelections.mergeIn(field.selectionSet.directSelections)
        }

      } else {
        fields[keyInScope] = field
      }
    }

    mutating func mergeIn(_ typeCase: TypeCase) {
      let keyInScope = typeCase.hashForSelectionSetScope

      if let existingTypeCase = typeCases[keyInScope] {
        existingTypeCase.directSelections.mergeIn(typeCase.directSelections)

      } else {
        typeCases[keyInScope] = typeCase
      }
    }

    mutating func mergeIn(_ fragment: Fragment) {
      fragments[fragment.hashForSelectionSetScope] = fragment
    }

    mutating func mergeIn(_ selections: SelectionMergable) {
      mergeIn(selections.fields)
      mergeIn(selections.typeCases)
      mergeIn(selections.fragments)
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
  struct ShallowSelections:
    FieldMergable, FragmentMergable, Equatable, CustomDebugStringConvertible
  {
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

    mutating func mergeIn(_ fragment: Fragment) {
      fragments[fragment.hashForSelectionSetScope] = fragment
    }

    mutating func mergeIn(_ selections: SelectionMergable) {
      mergeIn(selections.fields)
      mergeIn(selections.fragments)
    }

    var debugDescription: String {
      """
      Fields: \(fields.values.elements)
      Fragments: \(fragments.values.elements.map(\.definition.name))
      """
    }
  }

}

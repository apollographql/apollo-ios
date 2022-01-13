import Foundation
import OrderedCollections

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

protocol SelectionCollection: FieldMergable, TypeCaseMergable, FragmentMergable {
  var fields: OrderedDictionary<String, Field> { get }
  var typeCases: OrderedDictionary<String, TypeCase> { get }
  var fragments: OrderedDictionary<String, Fragment> { get }
}

extension SelectionCollection {

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

  // MARK: - Equatable Conformance
}

extension IR {
  struct SortedSelections: SelectionCollection, Equatable, CustomDebugStringConvertible {
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

    // MARK: Merge In - Field

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

    // MARK: Merge In - TypeCase

    mutating func mergeIn(_ typeCase: TypeCase) {
      let keyInScope = typeCase.hashForSelectionSetScope

      if let existingTypeCase = typeCases[keyInScope] {
        existingTypeCase.directSelections.mergeIn(typeCase.directSelections)

      } else {
        typeCases[keyInScope] = typeCase
      }
    }

    // MARK: Merge In - Fragment

    mutating func mergeIn(_ fragment: Fragment) {
      fragments[fragment.hashForSelectionSetScope] = fragment
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

import ApolloUtils

extension IR {
//  /// Represents the selections that can be accessed on a `SelectionSet`.
//  ///
//  /// - Precondition: The `selections` for all `SelectionSet`s in the operation must be
//  /// completed prior to initialization and merging of fields into `MergedSelections`.
//  /// Otherwise, the merged selections will be incomplete.
//  class Selections {
//    let directSelections: SortedSelections
//
//    lazy var mergedSelections: ShallowSelections = {
//
//      return _mergedSelections
//    }
//    private var _mergedSelections: ShallowSelections = ShallowSelections()
//
//    /// The `typePath` of the `SelectionSet` the `MergedSelections` belong to.
//    ///
//    /// Used to set the type path for fields that are merged in that do not exist in the
//    /// initial selections.
////    let typePath: LinkedList<TypeScopeDescriptor>
//
//    init(directSelections: SortedSelections) {
//      self.directSelections = directSelections
//    }
//
//    func mergeIn(_ field: IR.Field) {
//      guard !directSelections.fields.keys
//              .contains(field.hashForSelectionSetScope) else { return }
//      mergedSelections.mergeIn(field)
//    }
//
//    func mergeIn(_ fragment: IR.FragmentSpread) {
//      guard !directSelections.fragments.keys
//              .contains(fragment.hashForSelectionSetScope) else { return }
//      mergedSelections.mergeIn(fragment)
//    }
//  }

  struct ShallowSelections:
    FieldMergable, FragmentMergable, Equatable, CustomDebugStringConvertible
  {
    fileprivate(set) var fields: OrderedDictionary<String, Field> = [:]
    fileprivate(set) var fragments: OrderedDictionary<String, Fragment> = [:]

    init() {}

    mutating func mergeIn(_ field: Field) {
      let keyInScope = field.hashForSelectionSetScope
      fields[keyInScope] = field
    }

    mutating func mergeIn(_ fragment: Fragment) {
      fragments[fragment.hashForSelectionSetScope] = fragment
    }

    mutating func mergeIn(_ selections: SortedSelections) {
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

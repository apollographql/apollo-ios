import Foundation
import OrderedCollections

protocol SelectionCollection: CustomDebugStringConvertible {
  typealias Field = IR.Field
  typealias TypeCase = IR.SelectionSet
  typealias Fragment = IR.FragmentSpread

  var fields: OrderedDictionary<String, Field> { get }
  var typeCases: OrderedDictionary<String, TypeCase> { get }
  var fragments: OrderedDictionary<String, Fragment> { get }

  mutating func mergeIn(_ field: Field)
  mutating func mergeIn(_ typeCase: TypeCase)
  mutating func mergeIn(_ fragment: Fragment)
}

extension SelectionCollection {

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

import ApolloUtils

extension IR {
  /// Represents the selections that can be accessed on a `SelectionSet`.
  ///
  /// - Precondition: The `selections` for all `SelectionSet`s in the operation must be
  /// completed prior to initialization and merging of fields into `MergedSelections`.
  /// Otherwise, the merged selections will be incomplete.
  struct MergedSelections: SelectionCollection, Equatable {
    fileprivate(set) var fields: OrderedDictionary<String, Field>
    fileprivate(set) var typeCases: OrderedDictionary<String, TypeCase>
    fileprivate(set) var fragments: OrderedDictionary<String, Fragment>

    /// The `typePath` of the `SelectionSet` the `MergedSelections` belong to.
    ///
    /// Used to set the type path for fields that are merged in that do not exist in the
    /// initial selections.
    let typePath: LinkedList<TypeScopeDescriptor>

    init(selectionSet: SelectionSet) {
      self.typePath = selectionSet.typePath
      self.fields = selectionSet.selections.fields
      self.typeCases = selectionSet.selections.typeCases
      self.fragments = selectionSet.selections.fragments
    }

    // MARK: Merge In - Field

    mutating func mergeIn(_ field: Field) {
      let keyInScope = field.hashForSelectionSetScope
      if fields.keys.contains(keyInScope) { return }

      if let field = field as? EntityField {
        let scopedField = copy(field: field, inScope: self.typePath)
        fields[keyInScope] = scopedField
      } else {
        #warning("Test & implement merged only scalar fields!")
        return
      }
    }

    private func copy(
      field: EntityField,
      inScope scope: LinkedList<TypeScopeDescriptor>
    ) -> EntityField {
      let selectionSet = IR.SelectionSet(
        entity: field.entity,
        parentType: field.selectionSet.parentType,
        typePath: scope.appending(field.selectionSet.typeScope)
      )
      selectionSet.selections = field.selectionSet.selections

      let scopedField = EntityField(field.underlyingField, selectionSet: selectionSet)
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

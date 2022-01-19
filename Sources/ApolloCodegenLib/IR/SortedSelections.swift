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

    func mergeIn(_ field: Field) {
      fatalError("Must be overridden by subclasses!")
    }

    func mergeIn(_ typeCase: TypeCase) {
      fatalError("Must be overridden by subclasses!")
    }

    func mergeIn(_ fragment: Fragment) {
      fatalError("Must be overridden by subclasses!")
    }

    func mergeIn<T: Sequence>(_ fields: T) where T.Element == Field {
      fields.forEach { mergeIn($0) }
    }

    func mergeIn<T: Sequence>(_ typeCases: T) where T.Element == TypeCase {
      typeCases.forEach { mergeIn($0) }
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
      TypeCases: \(typeCases.values.elements.map(\.typeInfo.parentType))
      Fragments: \(fragments.values.elements.map(\.definition.name))
      """
    }

    var readOnlyView: ReadOnly {
      ReadOnly(value: self)
    }

    struct ReadOnly {
      fileprivate let value: SortedSelections

      var fields: OrderedDictionary<String, Field> { value.fields }
      var typeCases: OrderedDictionary<String, TypeCase> { value.typeCases }
      var fragments: OrderedDictionary<String, Fragment> { value.fragments }
    }
  }


  class DirectSelections: SortedSelections {

    override func mergeIn(_ field: Field) {
      let keyInScope = field.hashForSelectionSetScope

      if let existingField = fields[keyInScope] as? EntityField {
        if let field = field as? EntityField {
          existingField.selectionSet.selections.direct!
            .mergeIn(field.selectionSet.selections.direct!)
        }

      } else {
        fields[keyInScope] = field
      }
    }

    override func mergeIn(_ typeCase: TypeCase) {
      let keyInScope = typeCase.hashForSelectionSetScope

      if let existingTypeCase = typeCases[keyInScope] {
        existingTypeCase.selections.direct!
          .mergeIn(typeCase.selections.direct!)

      } else {
        typeCases[keyInScope] = typeCase
      }
    }

    override func mergeIn(_ fragment: Fragment) {
      fragments[fragment.hashForSelectionSetScope] = fragment
    }

  }

  class MergedSelections: SortedSelections {

    let directSelections: DirectSelections.ReadOnly?
    let typeInfo: SelectionSet.TypeInfo

    init(
      directSelections: DirectSelections.ReadOnly?,
      typeInfo: SelectionSet.TypeInfo
    ) {
      self.directSelections = directSelections
      self.typeInfo = typeInfo
      super.init()
    }

    func mergeIn(_ selections: IR.ShallowSelections) {
      selections.fields.values.forEach { self.mergeIn($0) }
      selections.fragments.values.forEach { self.mergeIn($0) }
    }

    override func mergeIn(_ field: IR.Field) {
      let keyInScope = field.hashForSelectionSetScope
      if let directSelections = directSelections,
          directSelections.fields.keys.contains(keyInScope) {
        return
      }

      let fieldToMerge: IR.Field
      if let entityField = field as? IR.EntityField {
        fieldToMerge = createShallowlyMergedNestedEntityField(from: entityField)

      } else {
        fieldToMerge = field
      }

      fields[keyInScope] = fieldToMerge
    }

    private func createShallowlyMergedNestedEntityField(from field: IR.EntityField) -> IR.EntityField {
      let newSelectionSet = IR.SelectionSet(
        entity: field.entity,
        parentType: field.selectionSet.typeInfo.parentType,
        typePath: self.typeInfo.typePath.appending(field.selectionSet.typeInfo.typeScope),
        mergedSelectionsOnly: true
      )
      return IR.EntityField(field.underlyingField, selectionSet: newSelectionSet)
    }

    override func mergeIn(_ fragment: IR.FragmentSpread) {
      let keyInScope = fragment.hashForSelectionSetScope

      if let directSelections = directSelections,
          directSelections.fragments.keys.contains(keyInScope) {
        return
      }

      fragments[keyInScope] = fragment
    }

//    override func mergeIn(_ field: Field) {
//      let keyInScope = field.hashForSelectionSetScope
//
//      if let existingField = fields[keyInScope] as? EntityField {
//        if let field = field as? EntityField {
//          existingField.selectionSet.directSelections!.mergeIn(field.selectionSet.directSelections!)
//        }
//
//      } else {
//        fields[keyInScope] = field
//      }
//    }
//
//    override func mergeIn(_ typeCase: TypeCase) {
//      let keyInScope = typeCase.hashForSelectionSetScope
//
//      if let existingTypeCase = typeCases[keyInScope] {
//        existingTypeCase.directSelections!.mergeIn(typeCase.directSelections!)
//
//      } else {
//        typeCases[keyInScope] = typeCase
//      }
//    }

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
      fields[field.hashForSelectionSetScope] = field
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
